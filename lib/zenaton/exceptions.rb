# frozen_string_literal: true

module Zenaton
  # Zenaton base error class
  class Error < StandardError; end

  # Exception raised when communication with workers failed
  class InternalError < Error; end

  # Exception raise when clien code is invalid
  class ExternalError < Error; end

  # Exception raised when wrong argument type is provided
  class InvalidArgumentError < ExternalError; end

  # :nodoc:
  class UnknownWorkflowError < ExternalError; end

  # Exception raised when network connectivity is lost
  class ConnectionError < Error; end

  # Exception raised when interfaces are not fulfilled by client code
  class NotImplemented < Error; end
end
