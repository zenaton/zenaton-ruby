# frozen_string_literal: true

require 'singleton'

module Zenaton
  # :nodoc:
  class Engine
    include Singleton

    attr_writer :processor

    def initialize
      @client = nil
      @processor = nil
    end

    def execute(jobs = [])
      return jobs.map(&:handle) if process_locally?(jobs)
      @processor.process(jobs, true)
    end

    private

    def process_locally?(jobs)
      jobs.length.zero? || @processor.nil?
    end
  end
end
