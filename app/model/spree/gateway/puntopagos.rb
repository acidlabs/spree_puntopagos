module Spree
  # Gateway for Puntopagos Hosted Payment Pages solution
  class Gateway::Puntopagos < Gateway
    preference :api_environment,    :string
    preference :api_key,            :string
    preference :api_sercret,        :string
    preference :api_payment_method, :string

    STATE = 'puntopagos'

    def source_required?
      false
    end

    def method_type
      "puntopagos"
    end
  end
end