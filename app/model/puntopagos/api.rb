# encoding: utf-8

# Clase para englobar las funciones mas relevantes de la gema https://github.com/acidlabs/puntopagos-ruby
# Basicamente disponibiliza 3 metodos que permiten:
#   - Iniciar el proceso para comenzar una transaccion utilizando el boton de pagos
#   - Revisar el estado de una transaccion
#   - Verificar la validez de una confirmacion enviada
module PuntoPagos
  class Api
    # def initialize env = nil
    #   @@config ||= ::PuntoPagos::Config.new(env)
    # end

    # Return PuntoPagos::Response instance
    def make_request(trx_id, amount, payment_method)
      # TODO - Verificar que la configuracion este disponible y seteada correctamente
      puntopagos_request = ::PuntoPagos::Request.new
      # TODO - revisar que los datos correspondan segun estandar de PuntoPagos
      puntopagos_request.create(trx_id, amount, payment_method)
    end

    # Return PuntoPagos::Status instance
    def check_status(token, trx_id, amount)
      # TODO - Verificar que la configuracion este disponible y seteada correctamente
      puntopagos_status = ::PuntoPagos::Status.new
      # TODO - revisar que los datos correspondan segun estandar de PuntoPagos
      puntopagos_status.check(token, trx_id, amount)
      puntopagos_status
    end

    # Return an Array with response and a message. [TrueClass||FalseClass, String]
    def valid_notification?(headers, params)
      # TODO - Verificar que la configuracion este disponible y seteada correctamente
      puntopagos_notification = ::PuntoPagos::Notification.new

      if Rails.env.development? or puntopagos_notification.valid?(headers, params.to_hash)
        [true, '']
      else
        [false, puntopagos_notification.error]
      end
    end
  end
end
