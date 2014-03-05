module Spree
  class PuntopagosController < StoreController
    skip_before_filter :verify_authenticity_token
    helper 'spree/checkout'

    before_filter :load_data

    before_filter :ensure_order_not_completed

    # POST spree/puntopagos/confirmation
    def confirmation
      provider = @payment_method.provider.new

      # This methods requires the headers as a hash and the params object as a hash
      if provider.valid_notification?(request.headers, params)
        @payment.update_attributes puntopagos_params: params.to_hash

        begin
          @payment.capture!
        rescue Core::GatewayError => error
          Rails.logger.error error
        end
      else
        Rails.logger.info "Invalid Notification"
      end

      render nothing: true
    end

    # GET spree/puntopagos/success
    def success
      # TODO - quiza aca se puede pasar el pago a :pending

      # reviso si el pago esta fallido y lo envio a la vista correcta
      if @payment.failed?
        redirect_to puntopagos_error_path(@payment.token)
        return
      end

      # To clean the Cart
      session[:order_id] = nil
      @current_order     = nil
    end

    # GET spree/puntopagos/error
    def error
      # TODO - quiza aca se puede pasar el pago a :pending

      # reviso si el pago esta completo y lo envio a la vista correcta
      if ['processing', 'completed'].include?(@payment.state)
        redirect_to puntopagos_success_path(@payment.token)
        return
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

      def ensure_order_not_completed
        redirect_to spree.cart_path if @order.completed?
      end
  end
end
