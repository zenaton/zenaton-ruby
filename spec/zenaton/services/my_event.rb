# frozen_string_literal: true

class MyEvent < Zenaton::Interfaces::Event
  def initialize(status)
    @status = status
  end
end
