$:.unshift File.expand_path( '../lib/', File.dirname( __FILE__))

require 'minitest/autorun'

require 'graph_builder'
require 'graph_builder/linkable'

class MyResource
  attr_reader :children, :name

  def initialize(name, children = [])
    @name, @children = name, children
  end

  def to_s
    name
  end
end

class Thing
  include GraphBuilder::Linkable

  attr_reader :resource
  
  def initialize(resource=nil)
    @resource = resource
  end

  def children
    resource.children
  end

  def self.links(things)
    things.inject([]) {|res,t| r = t.links; res +=r unless r.empty?; res }
  end

  def self.links_s(things)
    links(things).map{|r|"#{r.first}=>#{r.last}"}.join(",")
  end

  def to_s
    s = "#{self.class}"
    s += "(#{resource})" if resource
    s
  end
end

class Thing0 < Thing; end
class Thing1 < Thing; end
class Thing2 < Thing; end
class Thing3 < Thing; end
class Thing4 < Thing; end
class Thing11 < Thing; end
class Thing12 < Thing; end
class Thing21 < Thing; end
class Thing22 < Thing; end
class Thing23 < Thing; end
class Thing31 < Thing; end
class Thing32 < Thing; end
class ThingT < Thing; end
class TestThing < Thing; end
class ThingA < Thing; end
class ThingB < Thing; end

class GraphBuilderTest < MiniTest::Unit::TestCase

  # thing1 -> thing2 -> TestThing
  def test_simple
    #puts "---------------test_simple-----------------"
    t1= Thing1.new
    t2 = nil
    tt = nil
    GraphBuilder::Builder.build do |b|
      b.add t1
      assert (nil != t2 = b.add(Thing2.new))
      assert_instance_of Thing2, t2
      assert (nil != tt = b.add(TestThing.new))
      assert_instance_of TestThing, tt
    end

    r = Thing.links([t1,t2,tt])
    assert_equal 2, r.size
    assert r.include? [t1,t2]
    assert r.include? [t2,tt]
  end

  # thing1
  def test_empty
    #puts "---------------test_empty-----------------"
    t1 = nil
    GraphBuilder::Builder.build do |b|
      t1 = b.add(Thing1.new)
    end

    r = Thing.links([t1])
    assert_equal 0, r.size
  end

  # t1 -> (t2 -> t3) -> t4
  def test_chain
    #puts "---------------test_chain-----------------"

    t1 = t2 = t3 = t4 = nil
    GraphBuilder::Builder.build do |b|
      t1 = b.add(Thing1.new)
      b.chain do
        t2 = b.add(Thing2.new)
        t3 = b.add(Thing3.new)
      end
      t4 = b.add(Thing4.new)
    end

    r = Thing.links([t1,t2,t3,t4])
    assert_equal 3, r.size
    assert r.include? [t1,t2]
    assert r.include? [t2,t3]
    assert r.include? [t3,t4]
  end

  # t1 -> () -> t4
  def test_empty_chain
    #puts "---------------test_chain-----------------"

    t1 = t2 = t3 = t4 = nil
    GraphBuilder::Builder.build do |b|
      t1 = b.add(Thing1.new)
      b.chain do
      end
      t4 = b.add(Thing4.new)
    end

    r = Thing.links([t1,t4])
    assert_equal 1, r.size
    assert r.include? [t1,t4]
  end

  # t1 -> t11 -> t2, t1 -> t12 -> t2
  def test_branch
    #puts "---------------test_branch-----------------"
    t1= nil
    t2 = nil
    t11 = nil
    t12 = nil
    GraphBuilder::Builder.build do |b|
      t1 = b.add(Thing1.new)
      b.branch do 
        t11 = b.add(Thing11.new)
        t12 = b.add(Thing12.new)
      end
      t2 = b.add(Thing2.new)
    end

    r = Thing.links([t1,t2,t11,t12])
    assert_equal 4, r.size
    assert r.include? [t1,t11]
    assert r.include? [t1,t12]
    assert r.include? [t11,t2]
    assert r.include? [t12,t2]
  end

  # t1 -> (empty) -> t2
  def test_empty_branch
    #puts "---------------test_branch-----------------"
    t1 = t2 = nil
    GraphBuilder::Builder.build do |b|
      t1 = b.add(Thing1.new)
      b.branch do 
      end
      t2 = b.add(Thing2.new)
    end

    r = Thing.links([t1,t2])
    assert_equal 1, r.size
    assert r.include? [t1,t2]
  end

  # t1 -> t11 -> t12 -> t2,    t1 -> t21 -> t22 -> t2
  def test_branch_chain
    #puts "---------------test_branch_chain-----------------"

    t1= t2 = t11 = t12 = t21 = t22 = nil
    GraphBuilder::Builder.build do |b|
      t1 = b.add(Thing1.new)
      b.branch do
        b.chain do
          t11 = b.add(Thing11.new)
          t12 = b.add(Thing12.new)
        end
        b.chain do
          t21 = b.add(Thing21.new)
          t22 = b.add(Thing22.new)
        end
      end
      t2 = b.add(Thing2.new)
    end

    r = Thing.links([t1,t2,t11,t12,t21,t22])
    assert r.include? [t1,t11]
    assert r.include? [t11,t12]
    assert r.include? [t12,t2]

    assert r.include? [t1,t21]
    assert r.include? [t21,t22]
    assert r.include? [t22,t2]

    assert_equal 6, r.size
  end

  # t1 -> t11 -> t12 -> t2,   t1 -> t21 -> t23 -> t2,    t1 -> t31 -> t32 -> t23 -> t2
  def test_branch_chain2
    #puts "---------------test_branch_chain2-----------------"

    t1= t2 = t11 = t12 = t21 = t23 = t31 = t32 = nil
    GraphBuilder::Builder.build do |b|
      t1 = b.add(Thing1.new)
      b.branch do
        b.chain do
          t11 = b.add(Thing11.new)
          t12 = b.add(Thing12.new)
        end
        b.chain do
          b.branch do
            t21 = b.add(Thing21.new)
            b.chain do
              t31 = b.add(Thing31.new)
              t32 = b.add(Thing32.new)
            end
          end
          t23 = b.add(Thing23.new)
        end
      end
      t2 = b.add(Thing2.new)
    end

    r = Thing.links([t1,t2,t11,t12,t21,t23,t31,t32])
    assert r.include? [t1,t11]
    assert r.include? [t1,t21]
    assert r.include? [t1,t31]

    assert r.include? [t11,t12]
    assert r.include? [t12,t2]

    assert r.include? [t21,t23]
    assert r.include? [t23,t2]

    assert r.include? [t31,t32]
    assert r.include? [t32,t23]

    assert_equal 9, r.size
  end


  # t0(order) -> t1(pos1) -> t11(batch11) -> t12(batch11) -> t2(order)
  # t0(order) -> t1(pos1) -> t11(batch12) -> t12(batch12) -> t2(order)
  # t0(order) -> t1(pos2) -> t11(batch21) -> t12(batch21) -> t2(order)
  # t0(order) -> t1(pos2) -> t11(batch22) -> t12(batch22) -> t2(order)
  def test_children
    #puts "---------------test_children-----------------"
    t= {}

    batch11 = MyResource.new :batch11
    batch12 = MyResource.new :batch12
    batch21 = MyResource.new :batch21
    batch22 = MyResource.new :batch22
    pos1 = MyResource.new :pos1, [ batch11, batch12 ]
    pos2 = MyResource.new :pos2, [ batch21, batch22 ]
    order = MyResource.new :order, [pos1, pos2]

    GraphBuilder::Builder.build do |b|
      t[:order] = [ b.add(Thing0.new(order)) ]
      
      b.children do |pos|
        t[pos.name] = b.add Thing1.new(pos)
        b.children do |batch|
          b1 = b.add Thing11.new(batch)
          b2 = b.add Thing12.new(batch)
          t[batch.name] = [b1, b2]
        end
      end
      t[:order] << b.add( Thing2.new(order))
    end

    r = Thing.links(t.values.flatten)
    assert_instance_of Thing0, t[:order].first
    assert_instance_of Thing2, t[:order].last
    assert_instance_of Thing1, t[:pos1]
    assert_instance_of Thing1, t[:pos2]
    assert_instance_of Thing11, t[:batch11].first
    assert_instance_of Thing12, t[:batch12].last
    assert_instance_of Thing11, t[:batch21].first
    assert_instance_of Thing12, t[:batch22].last

    assert r.include? [t[:order].first,t[:pos1]]
    assert r.include? [t[:order].first,t[:pos2]]
    assert r.include? [t[:pos1],t[:batch11].first]
    assert r.include? [t[:pos1],t[:batch12].first]
    assert r.include? [t[:pos2],t[:batch21].first]
    assert r.include? [t[:pos2],t[:batch22].first]
    assert r.include? [t[:batch11].first,t[:batch11].last]
    assert r.include? [t[:batch12].first,t[:batch12].last]
    assert r.include? [t[:batch21].first,t[:batch21].last]
    assert r.include? [t[:batch22].first,t[:batch22].last]
    assert r.include? [t[:batch11].last,t[:order].last]
    assert r.include? [t[:batch12].last,t[:order].last]
    assert r.include? [t[:batch21].last,t[:order].last]
    assert r.include? [t[:batch22].last,t[:order].last]

    assert_equal 14, r.size
  end

end
