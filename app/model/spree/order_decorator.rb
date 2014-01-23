module Spree
  Order.class_eval do
    # insert_checkout_step :puntopagos, after: :payment, if: ->(order) { order.has_puntopagos_payment_method? }

    def pending_payments
      payments.select{ |payment| payment.checkout? or payment.completed? }
    end

    # alias_method :orig_payment_required?, :payment_required?
    # def payment_required?
    #   if has_puntopagos_payment_method? and puntopagos_payment_completed?
    #     return true
    #   else
    #     return orig_payment_required?
    #   end
    # end

    # alias_method :orig_confirmation_required?, :confirmation_required?
    # def confirmation_required?
    #   return true if has_puntopagos_payment_method?

    #   orig_confirmation_required?
    # end


    checkout_flow do
      go_to_state :address
      go_to_state :delivery
      go_to_state :payment, if: ->(order) {
        order.payment_required?
        #or order.has_puntopagos_payment_method?
      }
      go_to_state :puntopagos, if: ->(order) { order.has_puntopagos_payment_method? }
      go_to_state :confirm, if: ->(order) { order.confirmation_required? }
      go_to_state :complete
      remove_transition from: :delivery, to: :confirm
    end

    def puntopagos_payment_completed?
      if payments.completed.from_puntopagos.any?
        true
      else
        false
      end
    end

    def has_puntopagos_payment_method?
      payments.from_puntopagos.any?
    end

    def payment_method
      # TODO - revisar si puedo devolver una nueva intancia de Spree::Gateway::Puntopagos
      payments.from_puntopagos
              .order(:id)
              .last
              .payment_method
    end

    def puntopagos_amount
      # TODO - Ver que pasa cuando hay decimales
      "#{total.to_i}.00"
    end
  end
end