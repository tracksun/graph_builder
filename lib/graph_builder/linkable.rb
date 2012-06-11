module GraphBuilder
  module Linkable

    # links other to self
    def link_to other
      linked_to << other
    end

    # returns array of objects to which self is linked
    def linked_to
      @linked_to ||= []
    end

    # returns array of [ self, object ] where each object linked to self
    def links
      linked_to.map{|to|[self,to]}
    end

  end
end
