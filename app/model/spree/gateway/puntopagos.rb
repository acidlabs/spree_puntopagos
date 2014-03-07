module Spree
  # Gateway for Puntopagos Hosted Payment Pages solution
  class Gateway::Puntopagos < Gateway
    preference :api_environment,    :string, default: 'sandbox'
    preference :api_key,            :string
    preference :api_sercret,        :string
    preference :api_payment_method, :string

    def self.STATE
      'puntopagos'
    end

    # def STATE
    #   'puntopagos'
    # end
    # STATE = 'puntopagos'.freeze

    def payment_profiles_supported?
      false
    end

    def source_required?
      false
    end

    def provider_class
      PuntoPagos::Api
    end

    def provider
      ::PuntoPagos::Config.env      = has_preference?(:api_environment) ? preferred_api_environment : 'sandbox'
      ::PuntoPagos::Config.key      = has_preference?(:api_key)         ? preferred_api_key         : nil
      ::PuntoPagos::Config.secret   = has_preference?(:api_sercret)     ? preferred_api_sercret     : nil

      provider_class
    end

    def actions
      %w{capture}
    end

    # Indicates whether its possible to capture the payment
    def can_capture?(payment)
      payment.pending? || payment.checkout?
    end

    def capture(money_cents, response_code, gateway_options)
      gateway_order_id   = gateway_options[:order_id]
      order_number       = gateway_order_id.split('-').first
      payment_identifier = gateway_order_id.split('-').last

      payment = Spree::Payment.find_by(identifier: payment_identifier)
      order   = payment.order

      if payment.puntopagos_params?
        if payment.puntopagos_params["respuesta"] == "00"
          ActiveMerchant::Billing::Response.new(true,  make_success_message(payment.puntopagos_params), {}, {})
        else
          ActiveMerchant::Billing::Response.new(false, make_failure_message(payment.puntopagos_params), {}, {})
        end
      else
        status = provider.new.check_status(payment.token, payment.trx_id.to_s, order.puntopagos_amount)

        if status.valid?
          ActiveMerchant::Billing::Response.new(true, Spree.t(:puntopagos_captured), {}, {})
        else
          ActiveMerchant::Billing::Response.new(false, status.error, {}, {})
        end
      end
    end

    def auto_capture?
      false
    end

    def method_type
      "puntopagos"
    end

    def payment_method_logo
      if has_preference?(:api_payment_method) and preferred_api_payment_method.present?
        "http://www.puntopagos.com/content/mp#{preferred_api_payment_method}.gif"
      else
        nil
      end
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