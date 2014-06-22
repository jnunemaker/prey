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
  end
end
