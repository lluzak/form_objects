require 'spec_helper'

describe  FormObjects::Naming do
  before do
    Object.send(:remove_const, 'MessageForm')
    load 'support/examples.rb'
  end

  describe '#model_name' do
    it 'returns Message' do
      MessageForm.model_name.to_s.should == 'Message'
    end
  end
end
