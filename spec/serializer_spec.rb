require 'spec_helper'

describe FormObjects::Serializer do

  subject { FormObjects::Base.new }

  describe '#serialized_attributes' do

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
