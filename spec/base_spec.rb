require 'spec_helper'

describe FormObjects::Base do

  it 'includes Virtus Core module' do
    described_class.included_modules.should include Virtus::Model::Core
  end

  it 'includes Serializer module ' do
    described_class.included_modules.should include FormObjects::Serializer
  end

  it 'includes Nesting module' do
    described_class.included_modules.should include FormObjects::Nesting
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
      subject.persisted?.should be_false
    end
  end

end
