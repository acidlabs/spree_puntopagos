module Spree
  class PuntopagosController < StoreController
    skip_before_filter :verify_authenticity_token
    helper 'spree/checkout'

    # POST spree/puntopagos/confirmation
    def confirmation
      @payment = Spree::Payment.find_by_token(params[:token])
      @order   = @payment.order

      notification = ::PuntoPagos::Notification.new

      # This methods requires the headers as a hash and the params object as a hash
      if Rails.env.development? or notification.valid?(headers, params)
        @payment.update_attributes puntopagos_params: params
        # @order.capture
        # @order.capture(@payment)
        # @payment.capture
        @payment.capture!
        # @payment.payment_method.capture
      end

      render nothing: true
    end

    # GET spree/puntopagos/success
    def success
      @payment        = Spree::Payment.find_by_token(params[:token])
      @payment_method = @payment.payment_method
      @order          = @payment.order

      # To clean the Cart
      session[:order_id] = nil
      @current_order     = nil
    end

    # GET spree/puntopagos/error
    def error
      @payment        = Spree::Payment.find_by_token(params[:token])
      @payment_method = @payment.payment_method
      @order          = @payment.order
    end
  end
end