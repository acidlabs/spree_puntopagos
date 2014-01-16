Spree::Core::Engine.routes.draw do
  # La URL de notificación
  post 'spree/puntopagos/confirmation', to: 'puntopagos#confirmation'

  # La URL de exito
  get 'spree/puntopagos/success', to: 'puntopagos#success'

  # La URL de fracaso
  get 'spree/puntopagos/error', to: 'puntopagos#error'
end
