require "prey/item"

module Prey
  class Queue
    def initialize(cluster, name)
      @cluster = cluster
      @thrift = @cluster.thrift
      @name = name
    end

    # Public: Gets items from a queue.
    #
    # options: Hash options:
    #          max_items: the maximum number of items ot fetch
    #          timeout: timeout to wait for items (0 for nonblocking)
    #          abort_timeout: if zero, items are considered confirmed, if
    #                         greater than zero, items must be confirmed
    #                         before abort_timeout milliseconds have ellapsed
    #                         or the items will be re-enqueued
    #
    # Returns zero items if no items could be fetched within the time.
    # Otherwise returns up to `max_items` or 1 by default.
    def get(options = {})
      max_items     = options.fetch(:max_items, 1)
      timeout       = options.fetch(:timeout, 0)
      abort_timeout = options.fetch(:abort_timeout, 0)

      if thrift_items = @thrift.get(@name, max_items, timeout, abort_timeout)
        thrift_items.map { |item| Item.new(item) }
      end
    end

    def put(items, expiration_msec = 0)
      items = case items
      when Array
        items
      else
        [items]
      end
      @thrift.put(@name, items, expiration_msec)
    end

    def confirm(items)
      ids = items.map { |item| item.id }
      @thrift.confirm(@name, ids)
    end

    def abort(items)
      ids = items.map { |item| item.id }
      @thrift.abort(@name, ids)
    end

    def flush
      @thrift.flush_queue(@name)
    end

    def size
      @cluster.servers.uniq.inject(0) do |sum, server|
        sum += server.queue_size(@name)
      end
    end
  end
end
