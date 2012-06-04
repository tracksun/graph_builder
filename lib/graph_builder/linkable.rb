module GraphBuilder
  module Linkable

    def link_to other
      linked_to << other
    end

    def linked_to
      @linked_to ||= []
    end

    def links
      linked_to.map{|to|[self,to]}
    end

  end
end
