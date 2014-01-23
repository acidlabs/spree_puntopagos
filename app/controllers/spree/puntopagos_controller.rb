module Spree
  class PuntopagosController < StoreController
    skip_before_filter :verify_authenticity_token
    helper 'spree/checkout'

    before_filter :load_data

    # POST spree/puntopagos/confirmation
    def confirmation
      provider = @payment_method.provider.new

      # This methods requires the headers as a hash and the params object as a hash
      if provider.valid_notification?(headers, params)
        @payment.update_attributes puntopagos_params: params
        @payment.capture!
      end

      render nothing: true
    end

    # GET spree/puntopagos/success
    def success
      # To clean the Cart
      session[:order_id] = nil
      @current_order     = nil
    end

    # GET spree/puntopagos/error
    def error
    end

    private
      def load_data
        @payment        = Spree::Payment.find_by_token(params[:token])
        @payment_method = @payment.payment_method
        @order          = @payment.order
      end
  end
end