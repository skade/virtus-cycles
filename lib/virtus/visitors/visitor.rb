module Virtus
  module Visitors
    module Visitor
      attr_accessor :callbacks

      def initialize(callbacks)
        self.callbacks = callbacks
      end

      def collection?(attribute)
        attribute.class < Virtus::Attribute::Collection
      end

      def embedded?(attribute)
        attribute.class < Virtus::Attribute::EmbeddedValue
      end

      def hash?(attribute)
        attribute.class <= Virtus::Attribute::Hash
      end
    end
  end
end
