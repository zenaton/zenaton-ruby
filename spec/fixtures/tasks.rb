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
