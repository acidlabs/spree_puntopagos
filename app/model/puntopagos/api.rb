module PuntoPagos
  class Api
    # def initialize env = nil
    #   @@config ||= ::PuntoPagos::Config.new(env)
    # end

    # Return PuntoPagos::Response instance
    def make_request(trx_id, amount, payment_method)
      puntopagos_request = ::PuntoPagos::Request.new
      puntopagos_request.create(trx_id, amount, payment_method)
    end

    # Return PuntoPagos::Status instance
    def check_status(token, trx_id, amount)
      puntopagos_status = ::PuntoPagos::Status.new
      puntopagos_status.check(token, trx_id, amount)
      puntopagos_status
    end

    # Return TrueClass||FalseClass instance
    def valid_notification?(headers, params)
      puntopagos_notification = ::PuntoPagos::Notification.new

      if Rails.env.development? or puntopagos_notification.valid?(headers, params)
        true
      else
        false
      end
    end
  end
end