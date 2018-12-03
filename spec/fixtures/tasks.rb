# frozen_string_literal: true

require 'zenaton/interfaces/task'

class FakeTask1 < Zenaton::Interfaces::Task
  def handle
    'result1'
  end
end

class FakeTask2 < Zenaton::Interfaces::Task
  def handle
    'result2'
  end
end

class FakeTask3 < Zenaton::Interfaces::Task
  def initialize(arg1, arg2)
    @arg1 = arg1
    @arg2 = arg2
  end

  def handle
    'result3'
  end
end
