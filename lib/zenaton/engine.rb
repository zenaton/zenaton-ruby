# frozen_string_literal: true

require 'singleton'
require 'zenaton/exceptions'
require 'zenaton/interfaces/task'
require 'zenaton/interfaces/workflow'
require 'zenaton/client'
require 'zenaton/processor'

module Zenaton
  # Zenaton Engine is a singleton class that stores a reference to the current
  # client and processor. It then handles job processing either locally or
  # through the processor with Zenaton workers
  # To access the instance, call `Zenaton::Engine.instance`
  class Engine
    include Singleton

    # @param value [Zenaton::Processor]
    attr_writer :processor

    # @private
    def initialize
      @client = Zenaton::Client.instance
      @processor = nil
    end

    # Executes scheduling jobs synchronously
    # @param jobs [Array<Zenaton::Interfaces::Job>]
    # @param cron String
    # @return [Array<String>, nil] the results if executed locally, or nil
    def schedule(jobs, cron)
      jobs.map(&method(:check_argument))
      jobs.map do |job|
        if job.is_a? Interfaces::Workflow
          @client.start_scheduled_workflow(job, cron)
        else
          @client.start_scheduled_task(job, cron)
        end
      end
      nil
    end

    # Executes jobs synchronously
    # @param jobs [Array<Zenaton::Interfaces::Job>]
    # @return [Array<String>, nil] the results if executed locally, or nil
    def execute(jobs)
      jobs.map(&method(:check_argument))
      return jobs.map(&:handle) if process_locally?(jobs)
      @processor.process(jobs, true)
    end

    # Executes jobs asynchronously
    # @param jobs [Array<Zenaton::Interfaces::Job>]
    # @return nil
    def dispatch(jobs)
      jobs.map(&method(:check_argument))
      jobs.map(&method(:local_dispatch)) if process_locally?(jobs)
      @processor&.process(jobs, false) unless jobs.length.zero?
      nil
    end

    private

    def process_locally?(jobs)
      jobs.length.zero? || @processor.nil?
    end

    def local_dispatch(job)
      if job.is_a? Interfaces::Workflow
        @client.start_workflow(job)
      else
        @client.start_task(job)
      end
    end

    def check_argument(job)
      raise InvalidArgumentError, error_message unless valid_job?(job)
    end

    def error_message
      'You can only execute or dispatch Zenaton Task or Worflow'
    end

    def valid_job?(job)
      job.is_a?(Interfaces::Task) || job.is_a?(Interfaces::Workflow)
    end
  end
end
