require 'virtus'
require 'virtus/cycles'

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

puts Virtus::Cycles::Detector.new(Root).edges