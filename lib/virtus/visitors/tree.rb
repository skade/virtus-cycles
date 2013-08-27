require_relative 'visitor'

module Virtus
  module Visitors
    # A visitor for an actual virtus object tree, starting with a root object
    class Tree
      include Visitor

      def visit_collection(collection, a = nil)
        callbacks.on_collection_begin(collection, a)
        collection.each do |value|
          callbacks.on_collection_element(value)
        end
        callbacks.on_collection_end(collection, a)
      end

      def visit_hash(hash, a = nil)
        callbacks.on_hash_begin(hash, a)
        hash.each do |k, v|
          callbacks.on_hash_key(k)
          visit(v)
        end
        callbacks.on_hash_end(hash, a)
      end

      def visit(object, context = nil)
        callbacks.on_visit(object)
        if Hash === object
          visit_hash(object, context)
        elsif Enumerable === object
          visit_collection(object, context)
        else
          visit_object(object)
        end
        callbacks.on_leave(object)
      end

      def visit_object(object)
        callbacks.on_object(object)
        attributes = object.class.attribute_set
        attributes.each do |a|
          if collection?(a)
            if collection = a.get!(object)
              visit(collection, a)
            end
          elsif hash?(a)
            if hash = a.get!(object)
              visit(hash, a)
            end
          elsif embedded?(a)
            callbacks.on_embedded(object, a)
            if next_obj = a.get!(object)
              visit(next_obj)
            end
          else
            callbacks.on_scalar(object, a)
          end
        end
      end
    end
  end
end

