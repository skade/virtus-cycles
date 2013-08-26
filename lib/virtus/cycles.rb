require "virtus/cycles/version"

module Virtus
  module Cycles
    class State
      include Virtus
      
      ARRAY_HASH = ->(state,attribute) { Hash.new { |h,k| h[k] = []} }

      attribute :visited, Array[Class]
      attribute :path, Array[Class]
      attribute :cycle, Hash[Class => Set[Class]], :default => ARRAY_HASH
      attribute :cross, Hash[Class => Set[Class]], :default => ARRAY_HASH
      attribute :edges, Hash[Class => Set[Class]], :default => ARRAY_HASH
      attribute :forward, Hash[Class => Set[Class]], :default => ARRAY_HASH
    end

    class Detector
      attr_accessor :root, :state

      def initialize(root)
        self.root = root
      end

      def detect!
        state = State.new
        self.state = detect_recursive(root, state)
      end

      def evaluated?
        detect! unless state
        !!state
      end

      def cycles?
        detect! unless state
        !state.cycles.empty?
      end

      def crosses?
        detect! unless state
        !state.cycles.empty?
      end

      def edges
        detect! unless state
        state.edges
      end

      def associated_types(node, &block)
        node.attribute_set.each do |a|
          if collection?(a) && embedded?(member_type(a))
            next_type = member_type(a)
          elsif embedded?(a)
            next_type = embedded_primitive(a)
          else
            next
          end
          yield next_type
        end
      end

      def collection?(attribute)
        attribute.class < Virtus::Attribute::Collection
      end

      def embedded?(attribute)
        attribute.class < Virtus::Attribute::EmbeddedValue
      end

      def member_type(attribute)
        attribute.options[:member_type]
      end

      def embedded_primitive(attribute)
        attribute.options[:primitive]
      end

      def detect_recursive(node, state)
        state.visited.push node
        state.path.push node
        find_connections(node, state)
        state.path.pop
        state
      end

      def find_connections(node, state)
        associated_types(node) do |next_node|
          state.edges[node] << next_node

          if cycle?(state, next_node)
            state.cycle[node] << next_node
          elsif cross?(state, next_node)
            state.cross[node] << next_node
          else
            state.forward[node] << next_node
            detect_recursive(next_node, state)
          end
        end

      end

      def cycle?(state, next_node)
        state.path.include?(next_node)
      end

      def cross?(state, next_node)
        state.visited.include?(next_node)
      end
    end
  end
end
