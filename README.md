# GraphBuilder

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

#### A simple chain: a &rarr; b

    GraphBuilder::Builder.build do |builder|
       builder.add a 
       builder.add b 
    end

#### A simple branch: a -> b, a -> c

    GraphBuilder::Builder.build do |builder|
       builder.add a  
       builder.branch do 
         builder.add b 
         builder.add c 
       end
    end

#### Diamond shaped graph: a -> b -> d,  a -> c -> d

    GraphBuilder::Builder.build do |builder|
       builder.add a  
       builder.branch do 
         builder.add b 
         builder.add c 
       end
       builder.add d  
    end

graph_builder comes with the module GraphBuilder::Linkable which implements

    # links self to other
    link_to( other ) 

    # returns an array of objects self is linked to
    link_to

    # returns an array of pairs [ [ self, other1 ], [ self, other2 ], ... ]
    # for linked objects other1,  other2, ...
    links

    

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
