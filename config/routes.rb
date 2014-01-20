Spree::Core::Engine.routes.draw do
  # The notification URL
  post 'spree/puntopagos/:token/confirmation', to: 'puntopagos#confirmation'

  # The success URL
  get 'spree/puntopagos/:token/success', to: 'puntopagos#success'

  # The failure URL
  get 'spree/puntopagos/:token/error', to: 'puntopagos#error'
end
