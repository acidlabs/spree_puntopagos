module Spree
  CheckoutController.class_eval do
    def edit
      if params[:state] == Spree::Gateway::Puntopagos::STATE and @order.state == Spree::Gateway::Puntopagos::STATE
        @payment           = @order.payments.order(:id).last
        payment_method     = @order.payment_method

        trx_id             = @order.id.to_s
        api_payment_method = payment_method.has_preference?(:api_payment_method) ? payment_method.preferred_api_payment_method : nil
        amount             = @order.puntopagos_amount

        provider = payment_method.provider.new

        response = provider.make_request(trx_id, amount, api_payment_method)

        if response.success?
          # TODO - ver que hacer cuando el token ya esta seteado
          @payment.update_attributes token: response.get_token
          redirect_to response.payment_process_url

          return
        else
          @error = response.get_error
        end
      end
    end
  end
end
