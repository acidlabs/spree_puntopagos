require "spec_helper"

describe Spree::PuntopagosController do
  routes { Spree::Core::Engine.routes }

  describe "routing" do
    # The notification URL
    it "routes to #confirmation" do
      post('/spree/puntopagos/confirmation').should route_to('spree/puntopagos#confirmation')
    end

    # The success URL
    it "routes to #success" do
      get('/spree/puntopagos/success/ASDF1234').should route_to('spree/puntopagos#success', :token => 'ASDF1234')
    end

    # The failure URL
    it "routes to #error" do
      get('/spree/puntopagos/error/ASDF1234').should route_to('spree/puntopagos#error', :token => 'ASDF1234')
    end
  end
end
