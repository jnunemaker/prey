module Prey
  class Item
    def initialize(thrift_item)
      @thrift_item = thrift_item
    end

    def id
      @thrift_item.id
    end

    def data
      @thrift_item.data
    end
  end
end
