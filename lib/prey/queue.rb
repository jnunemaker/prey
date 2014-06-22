require "prey/item"

module Prey
  class Queue
    def initialize(cluster, name)
      @cluster = cluster
      @name = name
    end

    def get(*args)
      @cluster.get(@name, *args)
    end

    def put(*args)
      @cluster.put(@name, *args)
    end

    def confirm(*args)
      @cluster.confirm(@name, *args)
    end

    def abort(*args)
      @cluster.abort(@name, *args)
    end

    def flush(*args)
      @cluster.flush(@name, *args)
    end

    def size(*args)
      @cluster.queue_size(@name, *args)
    end
  end
end
