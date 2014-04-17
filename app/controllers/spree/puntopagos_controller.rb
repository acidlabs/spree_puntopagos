module Spree
  class PuntopagosController < StoreController
    skip_before_filter :verify_authenticity_token
    helper 'spree/checkout'

    before_filter :load_data
    before_filter :load_log_file

    # POST spree/puntopagos/confirmation
    def confirmation
      Rails.logger.send(@order.number).info("#{__FILE__}:#{__LINE__} POST: Confirmation received!")

      Rails.logger.send(@order.number).info("#{__FILE__}:#{__LINE__} Params: #{params}")
      Rails.logger.send(@order.number).info("#{__FILE__}:#{__LINE__} Headers: #{request.headers}")

      provider = @payment_method.provider.new
      response, message = provider.valid_notification?(request.headers, params)

      Rails.logger.send(@order.number).info("#{__FILE__}:#{__LINE__} Checking Notification...")

      # This methods requires the headers as a hash and the params object as a hash
      if response
        Rails.logger.send(@order.number).info("#{__FILE__}:#{__LINE__} Notification: success!")
        @payment.update_attributes puntopagos_params: params['puntopago']

        capture_payment
      else
        Rails.logger.send(@order.number).info("#{__FILE__}:#{__LINE__} Notification: failure!")
        @payment.update_attributes puntopagos_params: message

        if ['processing', 'failed'].include?(@payment.state)
          Rails.logger.send(@order.number).info("#{__FILE__}:#{__LINE__} Warning - Can't failure! Payment with state: #{@payment.state}")
        else
          Rails.logger.send(@order.number).info("#{__FILE__}:#{__LINE__} Failuring! Payment from state: #{@payment.state}")
          @payment.started_processing!
          @payment.failure!
          Rails.logger.send(@order.number).info("#{__FILE__}:#{__LINE__} Failure! Payment to state: #{@payment.state}")
        end
      end

      render nothing: true
    end

    # GET spree/puntopagos/success
    def success
      Rails.logger.send(@order.number).info("#{__FILE__}:#{__LINE__} GET: success view!")

      # To clean the Cart
      Rails.logger.send(@order.number).info("#{__FILE__}:#{__LINE__} Clean Cart: #{session[:order_id]}")
      session[:order_id] = nil
      @current_order     = nil

      if ['failed', 'invalid'].include?(@payment.state)
        # Reviso si el pago no se completo correctamente
        Rails.logger.send(@order.number).info("#{__FILE__}:#{__LINE__} Payment is not correctly!, redirecting to: #{puntopagos_error_path(@payment.token)}")
        redirect_to puntopagos_error_path(@payment.token) and return
      end

      unless capture_payment
        # Si no se pudo capturar el payment
        Rails.logger.send(@order.number).info("#{__FILE__}:#{__LINE__} Can't capture payment!, redirecting to: #{puntopagos_error_path(@payment.token)}")
        redirect_to puntopagos_error_path(@payment.token) and return
      end

      # NOTA: Si llego aca significa que logro capturar el payment y cambiar el estado de la orden

      Rails.logger.send(@order.number).info("#{__FILE__}:#{__LINE__} Payment captured!")

      if @order.completed?
        Rails.logger.send(@order.number).info("#{__FILE__}:#{__LINE__} Order completed! redirecting to #{completion_route}")

        # Si ya se completo la orden
        flash.notice = Spree.t(:order_processed_successfully)
        redirect_to completion_route and return
      else
        Rails.logger.send(@order.number).info("#{__FILE__}:#{__LINE__} Order is not into complete state, redirecting to #{checkout_state_path(@order.state)}")

        # Seteo el flash con los errores de la orden
        flash[:error] = @order.errors.full_messages.join("\n") if @order.errors.any?

        # Avanzo al siguiente paso del flujo
        # ó
        # Deja la orden en un paso que se muestren los errores
        redirect_to checkout_state_path(@order.state) and return
      end
    end

    # GET spree/puntopagos/error
    def error
      Rails.logger.send(@order.number).info("#{__FILE__}:#{__LINE__} GET: error view!")

      unless @order.completed?
        Rails.logger.send(@order.number).info("#{__FILE__}:#{__LINE__} Restore Cart: #{@order.id}")
        # To restore the Cart
        session[:order_id] = @order.id
        @current_order     = @order
      end

      if ['processing', 'completed'].include?(@payment.state) or capture_payment
        # Reviso si el pago se completo con exito
        # ó
        # Si logro capturar el payment

        Rails.logger.send(@order.number).info("#{__FILE__}:#{__LINE__} Payment successfully captured!, redirecting to: #{puntopagos_success_path(@payment.token)}")

        redirect_to puntopagos_success_path(@payment.token) and return
      # else
        # En este caso dejo que muestre la vista de error
      end
    end

    private
      # Carga los datos necesarios
      def load_data
        @payment = Spree::Payment.find_by_token(params[:token])

        # Verifico que se encontro el payment
        redirect_to spree.cart_path and return unless @payment

        @payment_method = @payment.payment_method
        @order          = @payment.order
      end

      def load_log_file
        begin
          MultiLogger.add_logger(@order.number)
        rescue Exception => e
          Rails.logger.info("Logger #{@order.number}.log already initialized")
        end
      end

      # Same as CheckoutController#completion_route
      def completion_route
        spree.order_path(@order)
      end

      def capture_payment
        Rails.logger.send(@order.number).info("#{__FILE__}:#{__LINE__} Start capture payment process!")

        if ['failed', 'invalid'].include?(@payment.state)
          Rails.logger.send(@order.number).info("#{__FILE__}:#{__LINE__} Can't capture payment, payment already on #{@payment.state} state!")
          return false
        end

        begin
          # Reviso si puedo capturar el payment
          if ['processing', 'completed'].include?(@payment.state)
            Rails.logger.send(@order.number).info("#{__FILE__}:#{__LINE__} Can't capture payment, payment already captured, payment state: #{@payment.state}!")
          else
            @payment.capture!
          end

          # Envio la orden al siguiente estado
          unless @order.completed?
            Rails.logger.send(@order.number).info("#{__FILE__}:#{__LINE__} Sending order to next state! (current: #{@order.state})")

            @order.next!
          end

          Rails.logger.send(@order.number).info("#{__FILE__}:#{__LINE__} Payment successfully captured!")

          return true
        rescue Core::GatewayError => error
          Rails.logger.send(@order.number).info("#{__FILE__}:#{__LINE__} An error occurred while trying to capture the payment")
          Rails.logger.send(@order.number).info("#{__FILE__}:#{__LINE__} Error: #{error}")

          # Se produjo un error al intentar capturar el payment
          data = @payment.puntopagos_params || {}

          @payment.update_attributes puntopagos_params: data.merge({'error' => error.to_s})

          if ['processing', 'failed', 'invalid'].include?(@payment.state)
            Rails.logger.send(@order.number).info("#{__FILE__}:#{__LINE__} Warning - Can't failure! Payment with state: #{@payment.state}")
          else
            Rails.logger.send(@order.number).info("#{__FILE__}:#{__LINE__} Failuring! Payment from state: #{@payment.state}")
            @payment.started_processing!
            @payment.failure!
            Rails.logger.send(@order.number).info("#{__FILE__}:#{__LINE__} Failure! Payment to state: #{@payment.state}")
          end

          Rails.logger.send(@order.number).info("#{__FILE__}:#{__LINE__} Payment failure!")

          return false
        rescue => error
          # Se produjo un error de la aplicacion
          data = @payment.puntopagos_params || {}

          @payment.update_attributes puntopagos_params: data.merge({'internal_error' => error.to_s})

          if ['processing', 'failed', 'invalid'].include?(@payment.state)
            Rails.logger.send(@order.number).info("#{__FILE__}:#{__LINE__} Warning - Can't failure! Payment with state: #{@payment.state}")
          else
            Rails.logger.send(@order.number).info("#{__FILE__}:#{__LINE__} Failuring! Payment from state: #{@payment.state}")
            @payment.started_processing!
            @payment.failure!
            Rails.logger.send(@order.number).info("#{__FILE__}:#{__LINE__} Failure! Payment to state: #{@payment.state}")
          end

          Rails.logger.send(@order.number).info("#{__FILE__}:#{__LINE__} Payment failure!")

          return false
        end
      end
  end
end
