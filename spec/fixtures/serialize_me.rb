# frozen_string_literal: true

class SerializeMe
  def initialize
    @initialized = true
  end

  def initialized?
    @initialized || false
  end
end
