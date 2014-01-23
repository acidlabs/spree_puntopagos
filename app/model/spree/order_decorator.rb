module Spree
  Order.class_eval do
    def pending_payments
      payments.select{ |payment| payment.checkout? or payment.completed? }
    end

    # insert_checkout_step :puntopagos, after: :payment, if: ->(order) { order.has_puntopagos_payment_method? }
    checkout_flow do
      go_to_state :address
      go_to_state :delivery
      go_to_state :payment,    if: ->(order) { order.payment_required?              }
      go_to_state :puntopagos, if: ->(order) { order.has_puntopagos_payment_method? }
      go_to_state :confirm,    if: ->(order) { order.confirmation_required?         }
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