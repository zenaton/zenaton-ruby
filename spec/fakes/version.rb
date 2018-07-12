# frozen_string_literal: true

# Fake Subclasses for testing
class Workflow1 < Zenaton::Workflow
  def initialize(_first, _second, _third); end
end
class Workflow2 < Zenaton::Workflow
  def initialize(_first, _second, _third); end
end
class FakeVersion < Zenaton::Workflows::Version
  def versions
    [Workflow1, Workflow2]
  end
end
