require "helper"

describe Prey::Client do
  let(:thrift) { subject.thrift }
  let(:queue_name) { "prey" }
  let(:expiration_msec) { 0 }
  let(:max_items) { 1 }
  let(:timeout) { 0 }
  let(:abort_timeout) { 0 }

  before { thrift.flush_queue(queue_name) }

  describe "#[]" do
    it "returns queue instance" do
      subject[queue_name].should be_instance_of(Prey::Queue)
    end
  end

  describe "#size" do
    it "returns size of queue" do
      items = ["1", "2", "3"]
      thrift.put(queue_name, items, expiration_msec)
      subject.size(queue_name).should be(3)
    end
  end
end
