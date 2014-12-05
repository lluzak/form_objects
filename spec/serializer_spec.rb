require 'spec_helper'

describe FormObjects::Serializer do
  before(:each) do
    Object.send(:remove_const, 'MessageForm')
    load 'support/examples.rb'
  end

  describe "UserForm" do
    let(:attributes) do
      {
        "first_name"           => "FirstName",
        "last_name"            => "LastName",
        "terms"                => "1",
        "addresses_attributes" => [
          {"address"  => "Street1"},
          {"address" => "Street2"}
        ]
      }
    end

    subject { UserForm.new(attributes).serialized_attributes }

    it "includes first_name" do
      subject[:first_name].should === "FirstName"
    end

    it "includes last_name" do
      subject[:last_name].should == "LastName"
    end

    it "includes terms" do
      subject[:terms].should be_truthy
    end

    it "includes addresses" do
      subject[:addresses].should be_kind_of(Array)
    end

    it "includes converted LocationForm inside Array" do
      subject[:addresses].first.should be_kind_of(Hash)
    end

    it "includes address" do
      subject[:addresses].first[:address].should == "Street1"
    end
  end

  describe '#serialized_attributes' do
    subject { MessageForm.new }

    it 'returns hash' do
      subject.serialized_attributes.should be_kind_of Hash
    end

    it 'calls #serialized_attributes' do
      expect(subject).to receive(:attributes)
      subject.serialized_attributes
    end

    describe 'when object in hash respond to #serialized_attributes' do
      let(:nested_form) { double(described_class) }
      before do
        subject.stub(:attributes).and_return({value: nested_form})
      end

      it 'calls recursively #clean_attributes' do
        expect(nested_form).to receive(:serialized_attributes)
        subject.serialized_attributes
      end
    end

  end

end
