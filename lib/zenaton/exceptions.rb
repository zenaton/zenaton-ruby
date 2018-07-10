# frozen_string_literal: true

module Zenaton
  # Zenaton exceptions inherit from this class
  class Error < StandardError; end

  # Exception raised when communication with workers failed
  class InternalError < Error
    def initialize(response); end
  end

  # Exception raised when network connectivity is lost
  class ConnectionError < Error
    def initialize(http_error); end
  end
end
