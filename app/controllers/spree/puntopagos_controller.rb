module Spree
  class PuntopagosController < StoreController
    skip_before_filter :verify_authenticity_token

    # POST spree/puntopagos/confirmation
    def confirmation
      @payment = Spree::Payment.find_by_token(params[:token])
      @order   = @payment.order

      notification = ::PuntoPagos::Notification.new

      # This methods requires the headers as a hash and the params object as a hash
      if notification.valid? headers, params
        if params[:respuesta] == "00"
          @order.update_attributes puntopagos: params, state: 'complete'
        else
          @order.update_attributes puntopagos: params
        end
      end

      render nothing: true
    end

    # GET spree/puntopagos/success
    def success
      # TODO - Solo si se requiere desde alguna configuración
      redirect_to protocol: "http://" and return if request.ssl?

      @payment = Spree::Payment.find_by_token(params[:token])
      @order   = @payment.order

          # @order.state = 'complete'
          # @order.save
    end

    # GET spree/puntopagos/error
    def error
      # TODO - Solo si se requiere desde alguna configuración
      redirect_to protocol: "http://" and return if request.ssl?

      @payment = Spree::Payment.find_by_token(params[:token])
      @order   = @payment.order
    end
  end
end