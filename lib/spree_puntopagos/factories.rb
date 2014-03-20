# Adding this to your spec_helper will load these Factories for use:
# require 'spree_puntopagos/factories'

FactoryGirl.define do
  factory :puntopagos, class: Spree::Gateway::Puntopagos do
    name Spree::Gateway::Puntopagos.to_s
    environment 'test'
    type Spree::Gateway::Puntopagos.to_s
    display_on ""
    active true
    description Spree::Gateway::Puntopagos.to_s
    preferred_api_environment "sandbox"
    preferred_api_key "API_KEY"
    preferred_api_sercret "API_SECRET"
    preferred_api_payment_method ""
    preferred_server "test"
    preferred_test_mode true
  end

  factory :puntopagos_payment, parent: :payment do
    association :payment_method, factory: :puntopagos
    association :order, factory: :puntopagos_order
    source nil
    response_code nil
    avs_response nil
    cvv_response_code nil
    cvv_response_message nil
  end

  factory :puntopagos_order, parent: :order_with_totals do
    bill_address
    ship_address

    state Spree::Gateway::Puntopagos.STATE
  end
end
