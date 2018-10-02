# frozen_string_literal: true

class FakeActiveModel
  # https://github.com/rails/rails/blob/master/activemodel/lib/active_model/attribute_set.rb

  def initialize(attributes)
    @attributes = attributes
  end

  def ==(other)
    attributes == other.attributes
  end

  protected

  attr_reader :attributes
end
