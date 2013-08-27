require 'virtus'
require 'virtus/cycles'
require 'virtus/visitors/class_graph'

class C
  include Virtus

  # this is a trivial cycle
  attribute :c, C
end

class B
  include Virtus

  # this is a cross
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

  # this is a forward (currently undetected)
  # attribute :c, C
end

state = Virtus::Cycles::CycleMarker.new
visitor = Virtus::Visitors::ClassGraph.new(state)
visitor.visit(Root)
puts C.attribute_set[:c].cyclic?
puts Root.attribute_set[:a].cyclic?
puts state.inspect
puts state.cyclic_types.inspect
