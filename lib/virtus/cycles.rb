require "virtus/cycles/version"
require "virtus/visitors"

module Virtus
  module Cycles
    # A type that marks an attribute as potentially cyclic.
    module Cyclic
      def cyclic?
        true
      end
    end

    module NonCyclic
      def cyclic?
        false
      end
    end

    class CycleDetector
      include Virtus
      
      ARRAY_HASH = ->(state,attribute) { Hash.new { |h,k| h[k] = []} }

      attribute :visited, Array[Class]
      attribute :path, Array[Class]
      attribute :cycle, Hash[Class => Set[Class]], :default => ARRAY_HASH
      attribute :cross, Hash[Class => Set[Class]], :default => ARRAY_HASH
      attribute :edges, Hash[Class => Set[Class]], :default => ARRAY_HASH
      attribute :forward, Hash[Class => Set[Class]], :default => ARRAY_HASH

      def current
        path.last
      end

      def on_collection(attribute)
        connect!(attribute.options[:member_type], attribute)
      end

      def on_embedded(attribute)
        connect!(attribute.options[:primitive], attribute)
      end

      def on_scalar(attribute)
        #ignore that
      end

      def on_visit(type)
        visited.push type
        path.push type
      end

      def on_leave(type)
        path.pop
      end

      def member_type(attribute)
        attribute.options[:member_type]
      end

      def embedded_primitive(attribute)
        attribute.options[:primitive]
      end

      def cyclic!(next_node, attribute)
        cycle[current] << next_node
        throw(:next)
      end

      def crossing!(next_node, attribute)
        cross[current] << next_node
        throw(:next)
      end

      def forward!(next_node, attribute)
        forward[current] << next_node
      end

      def connect!(next_node, attribute)
        edges[current] << next_node
        if cycle?(next_node)
          cyclic!(next_node, attribute)
        elsif cross?(next_node)
          crossing!(next_node, attribute)
        else
          forward!(next_node, attribute)
        end
      end

      def cycle?(next_node)
        path.include?(next_node)
      end

      def cross?(next_node)
        visited.include?(next_node)
      end

      def cycles?
        cycle.any?
      end

      def crosses?
        cross.any?
      end

      def cyclic_types
        cycle.values.flatten
      end
    end

    class CycleMarker < CycleDetector
      def cyclic!(next_node, attribute)
        attribute.extend(Cyclic)
        super
      end

      def cross!(next_node, attribute)
        attribute.extend(NonCyclic)
        super
      end

      def forward!(next_node, attribute)
        attribute.extend(NonCyclic)
        super
      end
    end
  end
end
