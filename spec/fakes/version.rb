# frozen_string_literal: true

require 'zenaton/workflows/version'
require 'fakes/workflows'

class FakeVersion < Zenaton::Workflows::Version
  def versions
    [FakeWorkflow1, FakeWorkflow2]
  end
end
