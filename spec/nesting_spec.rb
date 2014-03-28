require 'spec_helper'

describe FormObjects::Nesting do
  before(:each) do
    Object.send(:remove_const, 'UserForm')
    load 'support/examples.rb'
  end

  it 'define #nested_form method' do
    FormObjects::Base.methods.include?(:nested_form).should be_true
  end

  describe "#nested_form"
    before do
      UserForm.nested_form(:personal_info, PersonalInfoForm)
    end

    subject { UserForm.new }

    it 'defined array attribute' do
      subject.personal_info = PersonalInfoForm.new
      subject.personal_info.should be_kind_of(PersonalInfoForm)
    end

    it 'defines writer method for attributes' do
      subject.methods.include?(:personal_info_attributes=).should be_true
    end
  end

  describe 'nested writer method' do
    before do
      UserForm.nested_form(:personal_info, PersonalInfoForm)
      UserForm.nested_form(:addresses, Array[AddressForm])
    end

    let(:addresses_data) { [{street: 'Diagon Alley', city: 'London'}] }

    subject { UserForm.new }

    it 'can mass-assign attributes to PersonalInfoForm' do
      subject.personal_info_attributes = { :first_name => "Piotr" }
      subject.personal_info.first_name.should == "Piotr"
    end

    it '#*_attributes method should set data to corresponding object' do
      subject.addresses_attributes = addresses_data
      subject.addresses.map(&:attributes).should == addresses_data
    end
  end

  describe 'validates nested forms' do
    let(:address)           { AddressForm.new(city: 'London') }
    let(:secondary_address) { AddressForm.new(street: 'Privet Drive', city: 'Little Whinging Alley') }
    let(:personal_info)     { PersonalInfoForm.new(first_name: '', last_name: 'Granger') }

    subject { UserForm.new }

    before do
      UserForm.clear_validators!
      UserForm.nested_form(:addresses, Array[AddressForm])
      UserForm.nested_form(:personal_info, PersonalInfoForm)

      subject.addresses     = [address, secondary_address]
      subject.personal_info = personal_info
    end

    it 'validate nested form' do
      subject.personal_info = PersonalInfoForm.new
      subject.valid?.should be_false

      subject.personal_info.errors.messages.should include :first_name
    end

    it 'calls #valid? on each nested forms objects' do
      address.should_receive(:valid?)
      secondary_address.should_receive(:valid?)
      personal_info.should_receive(:valid?)

      subject.valid?
    end

    it 'add errors into parent object' do
      subject.valid?

      subject.errors.messages.should include :addresses
      subject.errors.messages.should include :personal_info
    end
  end
