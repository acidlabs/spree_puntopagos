module Spree
  # Gateway for Puntopagos Hosted Payment Pages solution
  class Gateway::Puntopagos < Gateway
    preference :api_environment,    :string
    preference :api_key,            :string
    preference :api_sercret,        :string
    preference :api_payment_method, :string

    STATE = 'puntopagos'

    # # Indicates whether its possible to void the payment.
    # def can_void?(payment)
    #   !payment.void?
    # end

    def actions
      %w{capture}
    end

    # Indicates whether its possible to capture the payment
    def can_capture?(payment)
      payment.pending? || payment.checkout?
    end

    def capture(money_cents, response_code, gateway_options)
      raise
      gateway_order_id   = gateway_options[:order_id]
      order_number       = gateway_order_id.split('-').first
      payment_identifier = gateway_order_id.split('-').last

      payment = Spree::Payment.find_by(identifier: payment_identifier)
      order   = payment.order

      if payment.puntopagos_params?
        if payment.puntopagos_params[:respuesta] == "00"
          ActiveMerchant::Billing::Response.new(true,  make_success_message(payment.puntopagos_params), {}, {})
        else
          ActiveMerchant::Billing::Response.new(false, "", {}, {})
        end
      else
        status = ::PuntoPagos::Status.new
        status.check payment.token, order.id.to_s, "#{order.total.to_i}.00"

        if status.valid?
          ActiveMerchant::Billing::Response.new(true,  "Puntopagos paid using PuntoPagos::Status", {}, {})
        else
          ActiveMerchant::Billing::Response.new(false, status.error, {}, {})
        end
      end
    end

    def payment_profiles_supported?
      false
    end

    def auto_capture?
      false
    end

    def source_required?
      false
    end

    def method_type
      "puntopagos"
    end

    private
    def make_success_message puntopagos_params
      puntopagos_params[:medio_pago_descripcion]
    end

    def make_failure_message puntopagos_params
      puntopagos_params[:error]
    end
  end
end