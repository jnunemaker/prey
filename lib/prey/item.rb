module Prey
  class Item
    def initialize(thrift, thrift_item)
      @thrift = thrift
      @thrift_item = thrift_item
    end

    def id
      @thrift_item.id
    end

    def data
      @thrift_item.data
    end

    def confirm
      @thrift.confirm
    end

    def abort
      @thrift.abort
    end
  end
end
