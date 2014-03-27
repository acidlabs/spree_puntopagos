module Spree
  Order.class_eval do
    # Se re-define cuales son pagos pendientes
    def pending_payments
      payments.select{ |payment| payment.checkout? or payment.completed? }
    end

    # Se re-define el checkout flow
    checkout_flow do
      go_to_state :address
      go_to_state :delivery
      go_to_state :payment,    if: ->(order) { order.payment_required? }
      go_to_state :puntopagos, if: ->(order) { order.has_puntopagos_payment_method? or order.state == Spree::Gateway::Puntopagos.STATE }
      go_to_state :confirm,    if: ->(order) { order.confirmation_required? }
      go_to_state :complete
      remove_transition from: :delivery, to: :confirm
    end

    # Indica si la orden tiene algun pago con Puntopagos completado con exito
    #
    # Return TrueClass||FalseClass instance
    def puntopagos_payment_completed?
      if payments.completed.from_puntopagos.any?
        true
      else
        false
      end
    end

    # Indica si la orden tiene asociado un pago por Puntopagos
    #
    # Return TrueClass||FalseClass instance
    def has_puntopagos_payment_method?
      payments.valid.from_puntopagos.any?
    end

    # Devuelve la forma de pago asociada a la order, se extrae desde el ultimo payment
    #
    # Return Spree::PaymentMethod||NilClass instance
    def payment_method
      has_puntopagos_payment_method? ? payments.valid.from_puntopagos.order(:id).last.payment_method : nil
    end

    # Entrega en valor total en un formato compatible con el estandar de Puntopagos
    #
    # Return String instance
    def puntopagos_amount
      # TODO - Ver que pasa cuando hay decimales
      "#{total.to_i}.00"
    end
  end
end