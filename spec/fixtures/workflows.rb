# frozen_string_literal: true

require 'zenaton/interfaces/workflow'
require 'fixtures/tasks'

class FakeWorkflow1 < Zenaton::Interfaces::Workflow
  def initialize(first, second)
    @first = first
    @second = second
  end

  def handle
    FakeTask1.new.dispatch
    FakeTask2.new.execute
  end
end

class FakeWorkflow2 < Zenaton::Interfaces::Workflow
  def initialize(_first, _second); end

  def handle
    FakeTask1.new.execute
    FakeTask2.new.execute
  end
end
