module Spree
  class PuntopagosController < StoreController
    skip_before_filter :verify_authenticity_token
    helper 'spree/checkout'

    before_filter :load_data

    # POST spree/puntopagos/confirmation
    def confirmation
      provider = @payment_method.provider.new
      response, message = provider.valid_notification?(request.headers, params)

      # This methods requires the headers as a hash and the params object as a hash
      if response
        @payment.update_attributes puntopagos_params: params['puntopago'].symbolize_keys

        capture_payment
      else
        @payment.update_attributes puntopagos_params: message['puntopago'].symbolize_keys

        unless ['processing', 'failed'].include?(@payment.state)
          @payment.started_processing!
          @payment.failure!
        end
      end

      render nothing: true
    end

    # GET spree/puntopagos/success
    def success
      # To clean the Cart
      session[:order_id] = nil
      @current_order     = nil

      if ['failed', 'invalid'].include?(@payment.state)
        # Reviso si el pago no se completo correctamente
        redirect_to puntopagos_error_path(@payment.token) and return
      end

      unless capture_payment
        # Si no se pudo capturar el payment
        redirect_to puntopagos_error_path(@payment.token) and return
      end

      if @order.completed?
        # Si ya se completo la orden
        flash.notice = Spree.t(:order_processed_successfully)
        redirect_to completion_route and return
      else
        # Seteo el falsh con los errores de la orden
        flash[:error] = @order.errors.full_messages.join("\n") if @order.errors.any?

        # Avanzo al siguiente paso del flujo o la dejo en el estado correto si la orden tiene errores
        redirect_to checkout_state_path(@order.state) and return
      end
    end

    # GET spree/puntopagos/error
    def error
      unless @order.completed?
        # To restore the Cart
        session[:order_id] = @order.id
        @current_order     = @order
      end

      if ['processing', 'completed'].include?(@payment.state) or capture_payment
        # Reviso si el pago se completo con exito
        # ó
        # Si logro capturar el payment

        redirect_to puntopagos_success_path(@payment.token) and return
      # else
        # En este caso dejo que muestre la vista de error
      end

      unless ['processing', 'failed', 'invalid'].include?(@payment.state)
        @payment.started_processing!
        @payment.failure!
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

      # Same as CheckoutController#completion_route
      def completion_route
        spree.order_path(@order)
      end

      def capture_payment
        begin
          # Reviso si puedo capturar el payment
          unless ['processing', 'completed'].include?(@payment.state)
            @payment.capture!
          end

          # Envio la orden al siguiente estado
          @order.next! unless @order.completed?

          return true
        rescue Core::GatewayError => error
          # Se produjo un error al intentar capturar el payment
          data = @payment.puntopagos_params || {}

          @payment.update_attributes puntopagos_params: data.merge({internal_error: error})

          unless ['processing', 'failed', 'invalid'].include?(@payment.state)
            @payment.started_processing!
            @payment.failure!
          end

          return false
        rescue => error
          # Se produjo un error de la aplicacion
          data = @payment.puntopagos_params || {}

          @payment.update_attributes puntopagos_params: data.merge({internal_error: error})

          unless ['processing', 'failed', 'invalid'].include?(@payment.state)
            @payment.started_processing!
            @payment.failure!
          end

          return false
        end
      end
  end
end
