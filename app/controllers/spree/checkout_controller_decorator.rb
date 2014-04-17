module Spree
  CheckoutController.class_eval do
    before_filter :check_puntopagos, only: :edit

    private
      def check_puntopagos
        @payment = @order.payments.order(:id).last

        redirect_to puntopagos_success_path(@payment.token) and return if @payment and @payment.token? and ['processing', 'completed'].include?(@payment.state)

        # TODO - quiza esto deba considerar el estado Spree::Gateway::Puntopagos.STATE en vez o junto con esto
        redirect_to puntopagos_error_path(@payment.token) and return if @payment and @payment.token? and @payment.failed? and !['address', 'delivery', 'payment'].include?(params[:state])

        if params[:state] == Spree::Gateway::Puntopagos.STATE and @order.state == Spree::Gateway::Puntopagos.STATE
          begin
            MultiLogger.add_logger(@order.number)
          rescue Exception => e
            Rails.logger.info("Logger #{@order.number}.log already initialized")
          end

          Rails.logger.send(@order.number).info("#{__FILE__}:#{__LINE__} Inicio Proceso con Puntopagos")

          Rails.logger.send(@order.number).info("#{__FILE__}:#{__LINE__} Order: #{@order.inspect}")

          payment_method     = @order.payment_method

          return if payment_method.nil?

          trx_id             = @payment.trx_id.to_s
          api_payment_method = payment_method.has_preference?(:api_payment_method) ? payment_method.preferred_api_payment_method : nil
          amount             = @order.puntopagos_amount

          Rails.logger.send(@order.number).info("#{__FILE__}:#{__LINE__} Payment: #{@payment.inspect}")
          Rails.logger.send(@order.number).info("#{__FILE__}:#{__LINE__} Payment Method: #{payment_method.inspect}")

          Rails.logger.send(@order.number).info("#{__FILE__}:#{__LINE__} Make Puntopagos Request...")
          provider = payment_method.provider.new
          response = provider.make_request(trx_id, amount, api_payment_method)

          if response.success?
            Rails.logger.send(@order.number).info("#{__FILE__}:#{__LINE__} Request success!")

            token = response.get_token
            Rails.logger.send(@order.number).info("#{__FILE__}:#{__LINE__} Token: #{token}")
            # TODO - ver si se puede reutilizar el token cuando este ya esta seteado
            @payment.update_attributes token: token

            # To clean the Cart
            Rails.logger.send(@order.number).info("#{__FILE__}:#{__LINE__} Clean Cart: #{session[:order_id]}")
            session[:order_id] = nil
            @current_order     = nil

            Rails.logger.send(@order.number).info("#{__FILE__}:#{__LINE__} Go To: #{response.payment_process_url}")
            redirect_to response.payment_process_url and return
          else
            Rails.logger.send(@order.number).info("#{__FILE__}:#{__LINE__} Request failure!")

            @error = response.get_error
            Rails.logger.send(@order.number).info("#{__FILE__}:#{__LINE__} Error: #{response.get_token}")
            @payment.update_attributes puntopagos_params: {'error' => @error}

            if ['processing', 'failed'].include?(@payment.state)
              Rails.logger.send(@order.number).info("#{__FILE__}:#{__LINE__} Warning - Can't failure! Payment with state: #{@payment.state}")
            else
              Rails.logger.send(@order.number).info("#{__FILE__}:#{__LINE__} Failuring! Payment from state: #{@payment.state}")
              @payment.started_processing!
              @payment.failure!
              Rails.logger.send(@order.number).info("#{__FILE__}:#{__LINE__} Failure! Payment to state: #{@payment.state}")
            end
          end
        end
      end
  end
end
