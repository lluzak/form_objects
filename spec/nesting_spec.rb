require 'spec_helper'

describe FormObjects::Nesting do
  before(:each) do
    Object.send(:remove_const, 'UserForm')
    load 'support/examples.rb'
  end

  it 'define #nested_forms method' do
    FormObjects::Base.methods.include?(:nested_forms).should be_true
  end

  describe '#nested_forms' do
    it 'raise ArgumentError on non-existing attributes' do
      expect{ UserForm.nested_forms(:unknown, :raiser) }.to raise_error(ArgumentError, 'Unknown attributes: unknown, raiser')
    end

    it 'defines writer method for attributes' do
      UserForm.nested_forms(:personal_info, :addresses)

      UserForm.instance_methods.include?(:personal_info_attributes=).should be_true
      UserForm.instance_methods.include?(:addresses_attributes=).should be_true
    end

    it 'adds validation for attributes' do
      UserForm.should_receive(:validate)
      UserForm.nested_forms(:personal_info, :addresses)
    end
  end

  describe 'nested writer method' do
    subject { UserForm.new }
    let(:addresses_data) { [{street: 'Diagon Alley', city: 'London'}] }

    before do
      UserForm.nested_forms(:addresses, :personal_info)
    end

    it '#*_attributes method should set data to corresponding object' do
      subject.addresses_attributes = addresses_data
      subject.addresses.map(&:attributes).should == addresses_data
    end
  end

  describe 'validates nested forms' do
    subject { UserForm.new }
    let(:address) { AddressForm.new(city: 'London') }
    let(:secondary_address) { AddressForm.new(street: 'Privet Drive', city: 'Little Whinging Alley') }
    let(:personal_info) { PersonalInfoForm.new(first_name: '', last_name: 'Granger') }

    before do
      UserForm.nested_forms(:addresses, :personal_info)

      subject.addresses = [address, secondary_address]
      subject.personal_info = personal_info
    end

    it 'calls #valid? on each nested forms objects' do
      address.should_receive(:valid?)
      secondary_address.should_receive(:valid?)
      personal_info.should_receive(:valid?)

      subject.valid?
    end

    it 'merges errors into parent object' do
      subject.valid?

      subject.errors.messages.should include :addresses_street
      subject.errors.messages.should include :personal_info_first_name
    end

  end

end
