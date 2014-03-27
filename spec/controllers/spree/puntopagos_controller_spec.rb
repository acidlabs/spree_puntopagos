require 'spec_helper'

describe Spree::PuntopagosController do
  let(:user) { stub_model(Spree::User) }

  before do
    @routes = Spree::Core::Engine.routes

    @payment        = FactoryGirl.create(:puntopagos_payment, token: 'ASDF1234')
    @payment_method = @payment.payment_method
    @order          = @payment.order

    session[:order_id] = @order.id
    @current_order     = @order

    controller.stub :try_spree_current_user => user
    controller.stub :spree_current_user => user

    ::PuntoPagos::Status.any_instance.stub(:check).and_return(true)
    ::PuntoPagos::Status.any_instance.stub(:valid?).and_return(true)
    ::PuntoPagos::Notification.any_instance.stub(:valid?).and_return(true)
  end

  describe 'POST #confirmation' do
    before do
      @success_params = {
                          "codigo_autorizacion"=>"178660",
                          "error"=>nil,
                          "fecha_aprobacion"=>"2014-03-20T13:10:34",
                          "medio_pago"=>"3",
                          "medio_pago_descripcion"=>"WebPay Transbank",
                          "monto"=>@order.puntopagos_amount,
                          "num_cuotas"=>'0',
                          "numero_operacion"=>"5322999692",
                          "numero_tarjeta"=>"6623",
                          "primer_vencimiento"=>nil,
                          "respuesta"=>"00",
                          "tipo_cuotas"=>"Sin Cuotas",
                          "tipo_pago"=>nil,
                          "token"=>@payment.token,
                          "trx_id"=>@payment.trx_id.to_s,
                          "valor_cuota"=>'0',
                          "puntopago"=>{
                                          "codigo_autorizacion"=>"178660",
                                          "error"=>nil,
                                          "fecha_aprobacion"=>"2014-03-20T13:10:34",
                                          "medio_pago"=>"3",
                                          "medio_pago_descripcion"=>"WebPay Transbank",
                                          "monto"=>@order.puntopagos_amount,
                                          "num_cuotas"=>'0',
                                          "numero_operacion"=>"5322999692",
                                          "numero_tarjeta"=>"6623",
                                          "primer_vencimiento"=>nil,
                                          "respuesta"=>"00",
                                          "tipo_cuotas"=>"Sin Cuotas",
                                          "tipo_pago"=>nil,
                                          "token"=>@payment.token,
                                          "trx_id"=>@payment.trx_id.to_s,
                                          "valor_cuota"=>'0'
                                       }
                        }

      @failed_params = {
                        "codigo_autorizacion"=>"000000",
                        "error"=>"Transaccion rechazada",
                        "fecha_aprobacion"=>"2014-03-20T14:31:56",
                        "medio_pago"=>"3",
                        "medio_pago_descripcion"=>"WebPay Transbank",
                        "monto"=>@order.puntopagos_amount,
                        "num_cuotas"=>'0',
                        "numero_operacion"=>"5327878711",
                        "numero_tarjeta"=>"6623",
                        "primer_vencimiento"=>nil,
                        "respuesta"=>"01",
                        "tipo_cuotas"=>"Sin Cuotas",
                        "tipo_pago"=>nil,
                        "token"=>@payment.token,
                        "trx_id"=>@payment.trx_id.to_s,
                        "valor_cuota"=>'0',
                        "puntopago"=>{
                                        "codigo_autorizacion"=>"000000",
                                        "error"=>"Transaccion rechazada",
                                        "fecha_aprobacion"=>"2014-03-20T14:31:56",
                                        "medio_pago"=>"3",
                                        "medio_pago_descripcion"=>"WebPay Transbank",
                                        "monto"=>@order.puntopagos_amount,
                                        "num_cuotas"=>'0',
                                        "numero_operacion"=>"5327878711",
                                        "numero_tarjeta"=>"6623",
                                        "primer_vencimiento"=>nil,
                                        "respuesta"=>"01",
                                        "tipo_cuotas"=>"Sin Cuotas",
                                        "tipo_pago"=>nil,
                                        "token"=>@payment.token,
                                        "trx_id"=>@payment.trx_id.to_s,
                                        "valor_cuota"=>'0'
                                      }
                      }

      @request.headers['Fecha'] = DateTime.now.to_s
      @request.headers['Autorizacion'] = 'dummy_authorization'
    end

    it 'should assigns :payment' do
      post :confirmation, @success_params

      assigns(:payment).should_not be_nil
      assigns(:payment).should eq @payment
    end

    it 'should assigns :order' do
      post :confirmation, @success_params

      assigns(:order).should_not be_nil
      assigns(:order).should eq @order
    end

    it 'should assigns :payment_method' do
      post :confirmation, @success_params

      assigns(:payment_method).should_not be_nil
      assigns(:payment_method).should eq @payment_method
    end

    context "success response" do
      it 'should save :puntopagos_params' do
        post :confirmation, @success_params

        assigns(:payment).puntopagos_params.should_not be_nil
        assigns(:payment).puntopagos_params.should == @success_params['puntopago']
      end

      it 'should save internal Spree::Core::GatewayError' do
        custom_error = Spree::Core::GatewayError.new "CUSTOM ERROR MESSAGE"
        Spree::Payment.any_instance.should_receive(:capture!).and_raise(custom_error)

        post :confirmation, @success_params

        assigns(:payment).puntopagos_params.should_not be_nil

        assigns(:payment).puntopagos_params['error'].should_not be_nil
        assigns(:payment).puntopagos_params['error'].should == custom_error.to_s
        assigns(:payment).puntopagos_params['internal_error'].should be_nil
      end

      it 'must fail the :payment when internal Spree::Core::GatewayError was raised' do
        custom_error = Spree::Core::GatewayError.new "CUSTOM ERROR MESSAGE"
        Spree::Payment.any_instance.should_receive(:capture!).and_raise(custom_error)

        @payment.state.should == 'checkout'

        post :confirmation, @success_params

        assigns(:payment).state.should == 'failed'
      end

      it 'should save internal RuntimeError' do
        custom_error = RuntimeError.new "CUSTOM ERROR MESSAGE"
        Spree::Payment.any_instance.should_receive(:capture!).and_raise(custom_error)

        post :confirmation, @success_params

        assigns(:payment).puntopagos_params.should_not be_nil
        assigns(:payment).puntopagos_params['error'].should be_nil
        assigns(:payment).puntopagos_params['internal_error'].should_not be_nil
        assigns(:payment).puntopagos_params['internal_error'].should == custom_error.to_s
      end

      it 'must complete the :order' do
        @order.state.should == Spree::Gateway::Puntopagos.STATE

        post :confirmation, @success_params

        assigns(:order).state.should == 'complete'
      end

      it 'must complete the :payment' do
        @payment == 'checkout'

        post :confirmation, @success_params

        assigns(:payment).state.should == 'completed'
      end

      it 'should not fail if the payment is already confirmed' do
        order = FactoryGirl.create(:completed_order_with_totals)
        @payment.order = order

        @payment.order_id.should == order.id
        @payment.order.should == order
        order.state.should == 'complete'

        post :confirmation, @success_params

        assigns(:order).state.should == 'complete'
      end
    end

    context "failure response" do
      it 'should save :puntopagos_params' do
        ::PuntoPagos::Notification.any_instance.stub(:valid?).and_return(false)
        ::PuntoPagos::Notification.any_instance.stub(:error).and_return(@failed_params)

        post :confirmation, @failed_params

        assigns(:payment).puntopagos_params.should_not be_nil
        puts assigns(:payment).puntopagos_params.inspect
        puts @failed_params.inspect
        assigns(:payment).puntopagos_params['error'].should_not be_nil
        assigns(:payment).puntopagos_params.should == @failed_params['puntopago']
      end

      it 'must fail the :payment' do
        @payment.state.should == 'checkout'

        post :confirmation, @failed_params

        assigns(:payment).state.should == 'failed'
      end

      it 'must not change the :order' do
        @order.state.should == Spree::Gateway::Puntopagos.STATE

        post :confirmation, @failed_params

        assigns(:order).state.should_not == 'complete'
        assigns(:order).state.should == Spree::Gateway::Puntopagos.STATE
      end
    end
  end

  describe 'GET #success' do
    it 'should clean :order_id from session' do
      session[:order_id].should_not be_nil

      get :success, token: @payment.token

      session[:order_id].should be_nil
    end

    it 'should clean :current_order' do
      @current_order.should_not be_nil

      get :success, token: @payment.token

      assigns(:current_order).should be_nil
    end

    it 'should assigns :payment' do
      get :success, token: @payment.token

      assigns(:payment).should_not be_nil
      assigns(:payment).should eq @payment
    end

    it 'should assigns :order' do
      get :success, token: @payment.token

      assigns(:order).should_not be_nil
      assigns(:order).should eq @order
    end

    it 'should assigns :payment_method' do
      get :success, token: @payment.token

      assigns(:payment_method).should_not be_nil
      assigns(:payment_method).should eq @payment_method
    end

    it "action logic" do
      pending "add some examples to (or delete) #{__FILE__}"
    end
  end

  describe 'GET #error' do
    it 'should assigns :payment' do
      get :error, token: @payment.token

      assigns(:payment).should_not be_nil
      assigns(:payment).should eq @payment
    end

    it 'should assigns :order' do
      get :error, token: @payment.token

      assigns(:order).should_not be_nil
      assigns(:order).should eq @order
    end

    it 'should assigns :payment_method' do
      get :error, token: @payment.token

      assigns(:payment_method).should_not be_nil
      assigns(:payment_method).should eq @payment_method
    end

    it "action logic" do
      pending "add some examples to (or delete) #{__FILE__}"
    end
  end
end
