module Spree
  Order.class_eval do
    insert_checkout_step :puntopagos, after: :payment, if: ->(order) { order.need_puntopagos? }

    def need_puntopagos?
      payments.each do |payment|
        return true if payment.payment_method.class == Spree::Gateway::Puntopagos
      end

      return false
    end

    def payment_method
      payments.joins(:payment_method)
              .where(spree_payment_methods: {type: Spree::Gateway::Puntopagos.to_s})
              .order(:id)
              .last
              .payment_method
    end

    def puntopagos_paid?
      true
    end
  end
end