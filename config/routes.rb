Spree::Core::Engine.routes.draw do
  # The notification URL
  post 'spree/puntopagos/confirmation', to: 'puntopagos#confirmation'

  # The success URL
  get 'spree/puntopagos/success', to: 'puntopagos#success'

  # The failure URL
  get 'spree/puntopagos/error', to: 'puntopagos#error'
end
