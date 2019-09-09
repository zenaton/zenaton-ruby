# frozen_string_literal: true

require 'securerandom'
require 'singleton'
require 'zenaton/services/graph_ql/client'
require 'zenaton/services/http'
require 'zenaton/services/properties'
require 'zenaton/services/serializer'

module Zenaton
  # Zenaton Client
  class Client
    include Singleton

    attr_writer :app_id, :api_token, :app_env

    # Class method that sets the three tokens needed to interact with the API
    # @param app_id [String] the ID of your Zenaton application
    # @param api_token [String] your Zenaton account API token
    # @param app_env [String] the environment (dev, staging, prod) to run under
    # @return [Zenaton::Client] the instance of the client.
    def self.init(app_id, api_token, app_env)
      instance.tap do |client|
        client.app_id = app_id
        client.api_token = api_token
        client.app_env = app_env
      end
    end

    # @private
    def initialize
      @http = Services::Http.new
      @graphql = Services::GraphQL::Client.new(http: @http)
      @serializer = Services::Serializer.new
      @properties = Services::Properties.new
    end

    # Start a single task
    # @param task [Zenaton::Interfaces::Task]
    def start_task(task)
      @graphql.start_task(task, credentials)
    end

    # Start the specified workflow
    # @param flow [Zenaton::Interfaces::Workflow]
    def start_workflow(flow)
      @graphql.start_workflow(flow, credentials)
    end

    def start_scheduled_task(task, cron)
      res = @graphql.schedule_task(task, cron, credentials)
      res && res['createTaskSchedule']
    end

    def start_scheduled_workflow(flow, cron)
      res = @graphql.schedule_workflow(flow, cron, credentials)
      res && res['createWorkflowSchedule']
    end

    # Stops a workflow
    # @param name [String] the class name of the workflow
    # @param custom_id [String] the custom ID of the workflow
    # @return [NilClass]
    def kill_workflow(name, custom_id)
      @graphql.kill_workflow(name, custom_id, credentials)
    end

    # Pauses a workflow
    # @param name [String] the class name of the workflow
    # @param custom_id [String] the custom ID of the workflow
    # @return [NilClass]
    def pause_workflow(name, custom_id)
      @graphql.pause_workflow(name, custom_id, credentials)
    end

    # Resumes a workflow
    # @param name [String] the class name of the workflow
    # @param custom_id [String] the custom ID of the workflow
    # @return [NilClass]
    def resume_workflow(name, custom_id)
      @graphql.resume_workflow(name, custom_id, credentials)
    end

    # Finds a workflow
    # @param workflow_name [String] the class name of the workflow
    # @param custom_id [String] the custom ID of the workflow
    # @return [Zenaton::Interfaces::Workflow, nil]
    def find_workflow(workflow_name, custom_id)
      @graphql.find_workflow(workflow_name, custom_id, credentials)
    end

    # Sends an event to a workflow
    # @param workflow_name [String] the class name of the workflow
    # @param custom_id [String] the custom ID of the workflow
    # @param event [Zenaton::Interfaces::Event] the event to send
    # @return [NilClass]
    def send_event(workflow_name, custom_id, event)
      @graphql.send_event(workflow_name, custom_id, event, credentials)
    end

    private

    def credentials
      {
        'app_id' => @app_id,
        'api_token' => @api_token,
        'app_env' => @app_env
      }
    end
  end
end
