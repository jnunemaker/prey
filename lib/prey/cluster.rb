require "forwardable"
require_relative "2.4.1/kestrel"
require "thrift_client"
require "prey/server"
require "prey/queue"

module Prey
  class Cluster
    extend Forwardable

    attr_reader :servers
    attr_reader :thrift

    def_delegators :@thrift, :connect, :disconnect, :status
    def_delegators :@thrift, :get, :put

    def initialize(servers = nil, options = {})
      @servers = servers || [Server.new]

      # If there is only one server in the list, the reconnect after timeout
      # logic will not work correctly because ThriftClient has no server to
      # fall back on.
      @servers *= 2 if @servers.length == 1

      connect_timeout = 2
      options = {
        retries: 5,
        server_max_requests: 1000,
        connect_timeout: connect_timeout,
        timeout: connect_timeout * @servers.length,
      }.merge(options)

      thrift_servers = @servers.map { |server|
        "#{server.host}:#{server.thrift_port}"
      }

      @thrift = ThriftClient.new(Thrift::Client, thrift_servers, options)
    end

    def [](queue_name)
      Queue.new(self, queue_name)
    end

    def get(queue_name, options = {})
      max_items     = options.fetch(:max_items, 1)
      timeout       = options.fetch(:timeout, 0)
      abort_timeout = options.fetch(:abort_timeout, 0)

      if thrift_items = @thrift.get(queue_name, max_items, timeout, abort_timeout)
        thrift_items.map { |item| Item.new(@thrift, item) }
      end
    end

    def put(queue_name, items, expiration_msec = 0)
      items = case items
      when Array
        items
      else
        [items]
      end

      @thrift.put(queue_name, items, expiration_msec)
    end

    def confirm(queue_name, items)
      ids = items.map { |item| item.id }
      @thrift.confirm(@name, ids)
    end

    def abort(queue_name, items)
      ids = items.map { |item| item.id }
      @thrift.abort(queue_name, ids)
    end

    def flush(queue_name)
      @thrift.flush_queue(queue_name)
    end

    def queue_size(queue_name)
      @servers.uniq.inject(0) do |sum, server|
        sum += server.queue_size(queue_name)
      end
    end
  end
end
