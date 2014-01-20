module Spree
  Order.class_eval do
    insert_checkout_step :puntopagos, after: :payment, if: ->(order) { order.need_puntopagos? }

    # remove_checkout_step :confirm, after: :payment, if: ->(order) { order.need_puntopagos? }

    # alias_method :orig_confirmation_required?, :confirmation_required?
    # def confirmation_required?
    #   return false if need_puntopagos?
    # end

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
  end
end