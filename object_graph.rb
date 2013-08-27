require 'virtus'
require 'virtus/visitors/tree'

class SerializingCallbacks
  def initialize
    @serialized = nil
    @current = nil
    @last = nil
  end

  def on_visit(*args)
  end

  def on_object(*args)
    if @current.nil?
      @current = {}
    else
      @last = @current
      @current = {}
    end
  end

  def on_leave(*args)
    puts __callee__
    puts args.inspect
  end

  def on_embedded(*args)
    puts __callee__
    puts args.inspect
  end

  def on_scalar(object, attribute)
    @current[attribute.name] = attribute.get(object)
    puts __callee__
    puts [object, attribute].inspect
  end

  def on_collection_begin(collection, attribute)
    @current[attribute.name] = []
    @last = @current
    @current = @current[attribute.name]
    puts __callee__
    puts [collection, attribute].inspect
  end

  def on_collection_end(*args)
    puts __callee__
    puts args.inspect
  end

  def on_collection_element(e)
    @current << e
    puts __callee__
    puts [e].inspect
  end

  def on_hash_begin(*args)
    puts __callee__
    puts args.inspect
  end

  def on_hash_key(*args)
    puts __callee__
    puts args.inspect
  end

  def on_hash_end(*args)
    puts __callee__
    puts args.inspect
  end

  def on_hash_element(*args)
    puts __callee__
    puts args.inspect
  end
end

class Foo
  include Virtus

  attribute :foo, String
end

class Bar
  include Virtus

  attribute :bar, Foo
  attribute :foo, Array[Foo]
  attribute :batz, Hash[String => Hash[String=> Foo]]
end

b = Bar.new({:bar => {:foo => 1234}, :foo => [{:foo => 4577}], :batz => {:hoge => {:fuge => {:foo => :bar}}}})

logger = SerializingCallbacks.new
visitor = Virtus::Visitors::Tree.new(logger)
visitor.visit(b)
puts logger.inspect
