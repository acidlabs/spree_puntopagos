require "spec_helper"

describe Spree::Payment do
  ##############
  # attributes #
  ##############
  it "has a token" do
    should respond_to :token
  end

  it "has a puntopagos_params" do
    should respond_to :puntopagos_params
  end

  it "puntopagos_params is a hash" do
    pending "add some examples to (or delete) #{__FILE__}"
    # FactoryGirl.build(:puntopagos_payment).puntopagos_params.should be_an_instance_of(Hash)
  end

  it "has a trx_id" do
    should respond_to :trx_id
  end

  ################
  # associations #
  ################
  # Uncomment if your model has associations.
  # See https://github.com/thoughtbot/shoulda
  #
  # it "have_many :models" do
  #   should have_many(:models)
  #   should have_many(:models).dependent(:nullify)
  #   should have_many(:models).through(:another_models)
  # end
  #
  # it "belongs to a :model" do
  #   should belong_to :model
  # end

  # add_column :spree_payments, :token,             :string
  # add_column :spree_payments, :puntopagos_params, :text
  # add_column :spree_payments, :trx_id, :integer

  ###############
  # validations #
  ###############
  # See https://github.com/thoughtbot/factory_girl
  # This factory should only set the REQUIRED attributes.
  it "has a valid factory" do
    FactoryGirl.build(:puntopagos_payment).should be_valid
  end

  describe "validations on :trx_id" do
    it "requires a :trx_id" do
      pending "add some examples to (or delete) #{__FILE__}"
      # FactoryGirl.build(:puntopagos_payment,  trx_id: nil).should_not be_valid
      # FactoryGirl.build(:puntopagos_payment,  trx_id: '').should_not  be_valid
    end

    it "requires a unique :trx_id" do
      pending "add some examples to (or delete) #{__FILE__}"
      # FactoryGirl.create(:puntopagos_payment, trx_id: 'alfa')
      # FactoryGirl.build(:puntopagos_payment,  trx_id: 'alfa').should_not be_valid
    end

    it "requires a numeric :trx_id" do
      pending "add some examples to (or delete) #{__FILE__}"
      # subject.stub(:payment_method){Spree::Gateway::Puntopagos}
      # should validate_numericality_of(:year).only_integer

      # FactoryGirl.build(:puntopagos_payment, year: 'a').should_not be_valid
    end
  end

  ###########
  # methods #
  ###########
  # Describe here you model methods behaviour.

  describe "callbacks" do
    it "it must set by default a value for :trx_id" do
      pending "add some examples to (or delete) #{__FILE__}"
      # payment = FactoryGirl.build(:puntopagos_payment, trx_id: nil)
      # payment.trx_id.should be_nil

      # payment = FactoryGirl.build(:puntopagos_payment, trx_id: '')
      # payment.trx_id.should be_nil

      # payment = FactoryGirl.create(:puntopagos_payment, trx_id: nil)
      # payment.trx_id.should_not be_nil

      # payment = FactoryGirl.create(:puntopagos_payment, trx_id: '')
      # payment.trx_id.should_not be_nil
    end
  end

  describe "search scopes" do
    it "respond to :from_puntopagos" do
      Spree::Payment.should respond_to :from_puntopagos
    end
  end
end
