require 'spec_helper'

describe FormObjects::Base do

  describe "#validates_associated" do
    let(:klass) do
      Class.new(described_class) do
        nested_form :addresses, AddressForm
      end
    end

    it "creates validator instance inside #validators array" do
      klass.validators.should_not be_empty
    end

    it "creates instance of AssociatedValidator" do
      klass.validators.any? { |validator| validator.should be_kind_of(FormObjects::AssociatedValidator) }.should be_true
    end
  end

  it 'includes Virtus Core module' do
    described_class.included_modules.should include Virtus::Model::Core
  end

  it 'includes Serializer module ' do
    described_class.included_modules.should include FormObjects::Serializer
  end

  describe 'when ActiveModel major version is above 3' do
    it 'includes ActiveModel::Model module' do
      described_class.included_modules.should include ActiveModel::Model
    end
  end

  describe 'when ActiveModel major version is lower than or equal to 3' do

    it 'includes ActiveModel Validations module'  do
      described_class.included_modules.should include ActiveModel::Validations
    end

    it 'includes ActiveModel Conversion module'  do
      described_class.included_modules.should include ActiveModel::Conversion
    end

    it 'extends itself by ActiveModel Naming module' do
      described_class.singleton_class.included_modules.should include ActiveModel::Naming
    end

  end

  describe '#persisted?' do
    it 'always returns false' do
      subject.persisted?.should == false
    end
  end

  describe "#as_json" do
    let(:form) do
      Class.new(described_class) do
        nested_form :addresses, Array[AddressForm]
      end
    end

    subject { form.new(:addresses => [{ :street => "Kazimierza" } ]) }

    it 'returns hash of nested forms' do
      subject.as_json.should == { "addresses" => [ { "street" => "Kazimierza", "city" => nil }] }
    end
  end
end
