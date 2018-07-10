# frozen_string_literal: true

module Zenaton
  # Zenaton base error class
  class Error < StandardError; end

  # Exception raised when communication with workers failed
  class InternalError < Error; end

  # :nodoc:
  class ExternalError < Error; end

  # :nodoc:
  class InvalidArgumentError < ExternalError; end

  # :nodoc:
  class UnknownWorkflowError < ExternalError; end

  # Exception raised when network connectivity is lost
  class ConnectionError < Error; end
end
