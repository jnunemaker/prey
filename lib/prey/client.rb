require "forwardable"
require "prey/cluster"

module Prey
  class Client
    extend Forwardable

    def initialize(cluster = nil)
      @cluster = cluster || Cluster.new
    end

    def_delegators :@cluster, :[], :connect, :disconnect, :status
  end
end
