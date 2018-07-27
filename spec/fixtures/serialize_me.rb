# frozen_string_literal: true

class SerializeMe
  def initialize
    @initialized = true
  end

  def initialized?
    @initialized || false
  end
end

module SerializeCircular
  class Parent
    attr_accessor :child

    def initialize
      @child = Child.new
      @child.parent = self
    end
  end

  class Child
    attr_accessor :parent
  end
end
