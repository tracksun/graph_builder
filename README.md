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



graph_builder comes with the module GraphBuilder::Linkable which implements

   # links self to other
   link_to( other ) 

   # returns an array of objects self is linked to
   link_to

   # returns an array of pairs [ [ self, other1 ], [ self, other2 ], ... ]
   # of self an linked objects
   links

    


    

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
