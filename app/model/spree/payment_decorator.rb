module Spree
  Payment.class_eval do
    scope :from_puntopagos, -> { joins(:payment_method).where(spree_payment_methods: {type: Spree::Gateway::Puntopagos.to_s}) }

    after_initialize :set_trx_id

    private
      # Public: Setea un trx_id unico.
      #
      # Returns Integer.
      def set_trx_id
        self.trx_id ||= generate_trx_id
      end

      # Public: Genera el trx_id unico y lo retorna.
      #
      # Returns Integer.
      def generate_trx_id
        while true
          generated_trx_id = Time.now.to_i

          return generated_trx_id unless Spree::Payment.exists?(trx_id: generated_trx_id)
        end
      end
  end
end
