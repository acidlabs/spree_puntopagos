module Spree
  Payment.class_eval do
    scope :from_puntopagos, -> { joins(:payment_method).where(spree_payment_methods: {type: Spree::Gateway::Puntopagos.to_s})
 }
  end
end
