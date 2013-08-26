require "virtus/cycles/version"
require "virtus/visitors"

module Virtus
  module Cycles
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
        connect!(attribute.options[:member_type])
      end

      def on_embedded(attribute)
        connect!(attribute.options[:primitive])
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

      def connect!(next_node)
        edges[current] << next_node
        if cycle?(next_node)
          cycle[current] << next_node
          throw(:next)
        elsif cross?(next_node)
          cross[current] << next_node
          throw(:next)
        else
          forward[current] << next_node
        end
      end

      def cycle?(next_node)
        path.include?(next_node)
      end

      def cross?(next_node)
        visited.include?(next_node)
      end

      def cycles?
        cycles.any?
      end

      def crosses?
        crosses.any?
      end
    end
  end
end
