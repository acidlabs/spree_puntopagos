Spree::Core::Engine.routes.draw do
  # The notification URL
  post 'spree/puntopagos/:token/confirmation', to: 'puntopagos#confirmation', as: :puntopagos_confirmation

  # The success URL
  get 'spree/puntopagos/:token/success', to: 'puntopagos#success', as: :puntopagos_success

  # The failure URL
  get 'spree/puntopagos/:token/error', to: 'puntopagos#error', as: :puntopagos_error
end
