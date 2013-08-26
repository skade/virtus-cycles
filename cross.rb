require 'virtus'
require 'virtus/cycles'
require 'virtus/visitors'

class C
  include Virtus

  attribute :c, C
end

class B
  include Virtus

  attribute :c, C
end

class A
  include Virtus

  attribute :c, C
end

class Root
  include Virtus

  attribute :name
  attribute :a, A
  attribute :b, B
end

state = Virtus::Cycles::CycleMarker.new
visitor = Virtus::Visitors::ClassGraph.new(state)
visitor.visit(Root)
puts C.attribute_set[:c].cyclic?
puts Root.attribute_set[:a].cyclic?
puts state.inspect
puts state.cyclic_types.inspect
