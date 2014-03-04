Spree::Core::Engine.routes.draw do
  # The notification URL
  post '/spree/puntopagos/confirmation', to: 'puntopagos#confirmation', as: :puntopagos_confirmation

  # The success URL
  get '/spree/puntopagos/success/:token', to: 'puntopagos#success', as: :puntopagos_success

  # The failure URL
  get '/spree/puntopagos/error/:token', to: 'puntopagos#error', as: :puntopagos_error
end
