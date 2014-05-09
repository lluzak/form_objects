require 'spec_helper'

describe FormObjects::ParamsConverter do
  let(:event_attributes)      { { "0" => { "name" => "Name 0" }, "1" => { "name" => "Name 1" } } }
  let(:params)                { { "events_attributes" => event_attributes } }
  let(:converted_attributes)  { [{"name" => "Name 0"}, {"name" => "Name 1"}] }

  subject { described_class.new(params) }

  describe "#params" do
    it "returns events_attributes converted to array" do
      subject.params["events_attributes"].should == converted_attributes
    end

    it "does not modify original params" do
      subject.params.should_not == params
    end

    describe "events_attributes in nested" do
      let(:params) { { "event" => { "events_attributes" => event_attributes } } }

      it "returns events_attributes converted to array" do
        subject.params["event"]["events_attributes"].should == converted_attributes
      end
    end

    describe "events_attributes should keep sequence" do
      let(:event_attributes) { { "1" => { "name" => "Name 1" }, "0" => { "name" => "Name 0" } } }

      it "returns events_attributes converted to array" do
        subject.params["events_attributes"].should == [{"name" => "Name 0"}, {"name" => "Name 1"}]
      end
    end

    describe "event_attributes is not Hash which pretends Array" do
      let(:event_attributes) { { "first_attribute" => { "name" => "Name 0" } } }

      it "returns non-converted events_attributes" do
        subject.params["events_attributes"].should == event_attributes
      end
    end

    describe "event_attributes is Hash which almost pretends Array (wrong attributes sequence)" do
      let(:event_attributes) { { "0" => { "name" => "Name 0" }, "2" => {"name" => "Name 2"} } }

      it "returns non-converted events_attributes" do
        subject.params["events_attributes"].should == event_attributes
      end
    end
  end
end
