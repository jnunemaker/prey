require "helper"

describe Prey::Client do
  let(:queue_name) { "prey" }
  let(:expiration_msec) { 0 }
  let(:max_items) { 1 }
  let(:timeout) { 0 }
  let(:abort_timeout) { 0 }

  before { subject.thrift.flush_queue(queue_name) }

  describe "#get" do
    it "returns empty array if no items" do
      subject.get(queue_name).should eq([])
    end

    it "returns item if found" do
      item = "1"
      items = [item]
      subject.thrift.put(queue_name, items, expiration_msec)
      thrift_item = subject.get(queue_name).first
      thrift_item.should_not be_nil
      thrift_item.data.should eq(item)
    end
  end

  describe "#put" do
    context "with single item" do
      it "puts item onto queue" do
        item = "1"
        subject.put(queue_name, item)
        thrift_item = subject.thrift.get(queue_name, max_items, timeout, abort_timeout).first
        thrift_item.should_not be_nil
        thrift_item.data.should eq(item)
      end
    end

    context "with many items" do
      it "puts item onto queue" do
        items = ["1", "2", "3"]
        subject.put(queue_name, items)
        thrift_items = subject.thrift.get(queue_name, items.size, timeout, abort_timeout)
        thrift_items.map(&:data).sort.should eq(items.sort)
      end
    end

    context "with expiration" do
      it "works" do
        item = "1"
        subject.put(queue_name, item, 1)
        sleep 0.001 # ensure item expires
        thrift_item = subject.thrift.get(queue_name, max_items, timeout, abort_timeout).first
        thrift_item.should be_nil
      end
    end
  end

  describe "#confirm" do
    it "confirms items" do
      abort_timeout = 5
      items = ["1", "2", "3"]
      subject.thrift.put(queue_name, items, expiration_msec)
      thrift_items = subject.thrift.get(queue_name, items.size, timeout, abort_timeout)
      subject.confirm(queue_name, thrift_items[0, 2])
      sleep 0.1
      thrift_items = subject.thrift.get(queue_name, items.size, timeout, abort_timeout)
      thrift_items.map(&:data).sort.should eq(items[2, 3])
    end
  end

  describe "#abort" do
    it "aborts items" do
      abort_timeout = 200
      items = ["1", "2", "3"]
      subject.thrift.put(queue_name, items, expiration_msec)
      thrift_items = subject.thrift.get(queue_name, items.size, timeout, abort_timeout)
      subject.abort(queue_name, thrift_items[0, 2])
      thrift_items = subject.thrift.get(queue_name, items.size, timeout, abort_timeout)
      thrift_items.map(&:data).sort.should eq(items[0, 2])
    end
  end
end
