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

state = Virtus::Cycles::CycleDetector.new
visitor = Virtus::Visitors::ClassGraph.new(state)
visitor.visit(Root)
puts state.inspect
