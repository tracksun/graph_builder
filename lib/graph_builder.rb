module GraphBuilder
  class BuilderError < StandardError; end

  # implements an AND/OR tree
  # An Branch represents a branch
  # An Chain represents a chain
  # A Leaf contains a thing
  class Base
    attr_reader :parent, :opts, :children

    @@debug = false

    def initialize parent, opts = {}
      @parent, @opts, @children = parent, opts, []
    end

    def process; children.each &:process; end
    def empty?;  children.all? &:empty?;  end

    def dump recursive = true
      debug{self.to_s} or return false
      children.each{|c|c.dump(recursive)} if recursive
    end

    def debug &proc
      @@debug or return false
      puts indent + proc.call
      true
    end

    def indent;    "   " * depth;   end
    def depth;     ancestors.count; end
    def ancestors; parent ? parent.ancestors << parent : [];  end
  end

  class Node < Base
    def add_leaf child
      add_node Leaf.new(self,child)
    end

    def add_node node
      @children << node
      node
    end

    def to_s
      "[#{self.class.name.split('::').last},empty?=#{empty?},f=#{first_things},l=#{last_things}]"
    end

  end

  class Leaf < Base
    attr_reader :thing
    def initialize parent, thing
      @thing = thing
      super parent
    end

    def empty?;       false;         end
    def last_things;  thing;         end
    def first_things; thing;         end
    def to_s;         "[#{thing}]";  end
  end

  class Chain < Node
    def last_things;   children.map(&:last_things).last;   end
    def first_things;  children.map(&:first_things).first; end

    def process
      children.each &:process

      debug{"processing #{self}"}
      debug{"       children: #{children.map(&:to_s).join(',')}" }

      # Connect the pairs of a chain:
      # connect all last_things of child with the first_things of the following child
      children.each_cons(2) do |pair|
        debug{"       pair: (#{pair.first},#{pair.last})"}
        froms = [pair.first.last_things].flatten
        tos   = [pair.last.first_things].flatten
        debug{"       froms= last_things of #{pair.first}: #{froms.map(&:to_s).join(',')}"}
        debug{"       tos=  first_things of #{pair.last}:  #{tos.map(&:to_s).join(',')}"}
        tos.each do |to|
          froms.each do |from|
            debug{"       link from=#{from} to=#{to}"}
            from.link_to to
          end
        end
      end
    end

  end

  class Branch < Node
    def last_things;   children.map &:last_things;  end
    def first_things;  children.map &:first_things; end
  end

  class Builder
    def self.build opts={}, &proc
      b = new opts
      proc.call b
      b.send :process
    end

    attr_reader :logger

    def initialize opts = {}
      @cur = @root = Chain.new(nil)
      @logger = opts.delete(:logger)
      @opts = opts # global opts
      debug{"initialize"}
      dump_tree
    end

    def add thing
      raise InvalidBlockError if block_given?
      add_thing thing
    end

    def chain  opts = {}, &proc ;  node Chain,  opts, proc; end
    def branch opts = {}, &proc ;  node Branch, opts, proc; end

    alias_method :with, :chain

    # yield each child of the children of the recent thing
    def children opts = {}
      debug{">> children"}
      debug{"children: @cur=#{@cur}, last_things=#{@cur.last_things}"}
      recent_things = [@cur.last_things].flatten
      unless recent_things.size == 1
        raise BuilderError, "invalid recent_thing #{recent_things}, @cur=#{@cur}. children() expects one recent thing"
      end
      recent_thing = recent_things.first
      #unless recent_thing.resource
      #  raise BuilderError, "no resource for recent_thing #{recent_thing}"
      #end

      #debug{"children: resource=#{recent_thing.resource}"}

      branch opts do
        recent_thing.children.map do |child|
          chain(opts.merge(:resource => child)){ yield child }
        end
      end
      debug{"<< children"}
    end

    def options opts
      res = @opts.merge(@cur.opts).merge(opts)
      debug{"options: opts=#{opts.inspect}, current.opts=#{@cur.opts.inspect}, @opts=#{@opts}, options=#{res.inspect}"}
      res
    end

    # set or get global opt
    def global_opt key,value
      if value
        @opts[key] = value
      else
        @opts[key]
      end
    end

    private

    # perform block with given opts
    def node clazz, opts, proc
      debug{">> #{clazz}"}
      # push
      prev = @cur
      @cur = clazz.new(prev,opts)
      proc.call
      debug{"-- @cur=#{@cur}"}
      prev.add_node @cur unless @cur.empty?
      # pop
      raise BuilderError, "stack error: no parent for @cur = #{@cur}" unless @cur.parent
      @cur = prev
      dump_tree
      debug{"<< #{clazz}"}
    end

    def process
      @root.process
    end

    def add_thing thing
      @cur.add_leaf thing
      debug{"add_thing #{thing}"}
      dump_tree
      thing
    end

    def dump_tree
      @root.debug{"*** whole tree ***"} or return
      @root.dump true
      @root.debug{'**************'}
    end

    def debug
      @root.debug{yield}
    end
  end
end
