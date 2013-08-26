module Virtus
  module Visitors
    # Virtus::Visitors::ClassGraph visits a virtus class graph depth-first. Events are then
    # propagated to a callback object.
    #
    # This class does not care about circles, they should be handled in callbacks.
    class ClassGraph
      attr_accessor :callbacks

      def initialize(callbacks)
        self.callbacks = callbacks
      end

      def visit(node)
        callbacks.on_visit(node)

        node.attribute_set.each do |a|
          if collection?(a) && embedded?(member_type(a))
            next_type = member_type(a)
            callbacks.on_collection(a)
          elsif embedded?(a)
            next_type = embedded_primitive(a)
            callbacks.on_embedded(a)
          else
            callbacks.on_scalar(a)
            next
          end

          catch(:next) {
            visit next_type
          }
          callbacks.on_leave(next_type)
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
      
    end
  end
end
