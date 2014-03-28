module Spree
  CheckoutController.class_eval do
    before_filter :check_puntopagos, only: :edit

    private
      def check_puntopagos
        @payment = @order.payments.order(:id).last

        redirect_to puntopagos_success_path(@payment.token) and return if @payment and @payment.token? and ['processing', 'completed'].include?(@payment.state)

        redirect_to puntopagos_error_path(@payment.token) and return if @payment and @payment.token? and @payment.failed? and !['address', 'delivery', 'payment'].include?(params[:state])

        if params[:state] == Spree::Gateway::Puntopagos.STATE and @order.state == Spree::Gateway::Puntopagos.STATE
          payment_method     = @order.payment_method

          return if payment_method.nil?

          trx_id             = @payment.trx_id.to_s
          api_payment_method = payment_method.has_preference?(:api_payment_method) ? payment_method.preferred_api_payment_method : nil
          amount             = @order.puntopagos_amount

          provider = payment_method.provider.new
          response = provider.make_request(trx_id, amount, api_payment_method)

          if response.success?
            # TODO - ver si se puede reutilizar el token cuando este ya esta seteado
            @payment.update_attributes token: response.get_token

            # To clean the Cart
            session[:order_id] = nil
            @current_order     = nil

            redirect_to response.payment_process_url and return
          else
            @error = response.get_error
            @payment.update_attributes puntopagos_params: {'error' => @error}

            unless ['processing', 'failed'].include?(@payment.state)
              @payment.started_processing!
              @payment.failure!
            end
          end
        end
      end
  end
end
