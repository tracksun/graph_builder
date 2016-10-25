# GraphBuilder

[![Build History][2]][1]

[1]: http://travis-ci.org/tsonntag/graph_builder
[2]: https://secure.travis-ci.org/tsonntag/graph_builder.png?branch=master


DSL to build directed graphs

## Installation

Add this line to your application's Gemfile:

    gem 'graph_builder'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install graph_builder

## Usage

GraphBuilder provides a DSL to build a graph of arbritary objects.

The objects must implement

    link_to( other )

which must implement a link between self and other.


### Examples:

#### A simple chain: a &rarr; b &rarr; c

    GraphBuilder::Builder.build do |builder|
       builder.add a
       builder.add b
       builder.add c
    end

#### A simple branch: a &rarr; b, a &rarr; c

    GraphBuilder::Builder.build do |builder|
       builder.add a
       builder.branch do
         builder.add b
         builder.add c
       end
    end

#### Diamond shaped graph: a &rarr; l &rarr; b,  a &rarr; r &rarr; b

    GraphBuilder::Builder.build do |builder|
       builder.add a
       builder.branch do
         builder.add l
         builder.add r
       end
       builder.add b
    end

#### Diamond with chains: a &rarr;  l1 &rarr; l2 &rarr; b, a &rarr;  r1 &rarr; r2 &rarr; r3 &rarr; b

    GraphBuilder::Builder.build do |builder|
       builder.add a
       builder.branch do
         builder.chain do
           builder.add l1
           builder.add l2
         end
         builder.chain do
           builder.add r1
           builder.add r2
           builder.add r3
         end
       end
       builder.add b
    end

### Implemention of #link_to

graph_builder comes with the module GraphBuilder::Linkable which implements

    # links self to other
    link_to( other )

    # returns an array of objects self is linked to
    linked_to

    # returns an array of pairs [ [ self, other1 ], [ self, other2 ], ... ]
    # for linked objects other1,  other2, ...
    links


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
