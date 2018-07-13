# frozen_string_literal: true

require 'zenaton/interfaces/workflow'

class FakeWorkflow1 < Zenaton::Interfaces::Workflow
  def initialize(_first, _second); end
end

class FakeWorkflow2 < Zenaton::Interfaces::Workflow
  def initialize(_first, _second); end
end
