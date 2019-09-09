# frozen_string_literal: true

require 'singleton'
require 'zenaton/services/graph_ql/client'
require 'zenaton/services/http'
require 'zenaton/services/properties'
require 'zenaton/services/serializer'

module Zenaton
  # Zenaton Client
  class Client
    include Singleton

    ZENATON_WORKER_URL = 'http://localhost' # Default worker url
    DEFAULT_WORKER_PORT = 4001 # Default worker port
    WORKER_API_VERSION = 'v_newton' # Default worker api version

    APP_ENV = 'app_env' # Parameter name for the application environment
    APP_ID = 'app_id' # Parameter name for the application ID

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

    # Gets the url for the workers
    # @param resource [String] the endpoint for the worker
    # @param params [Hash|String] query params to be url encoded
    # @return [String] the workers url with parameters
    def worker_url(resource = '', params = {})
      base_url = ENV['ZENATON_WORKER_URL'] || ZENATON_WORKER_URL
      port = ENV['ZENATON_WORKER_PORT'] || DEFAULT_WORKER_PORT
      url = "#{base_url}:#{port}/api/#{WORKER_API_VERSION}/#{resource}"

      if params.is_a?(Hash)
        append_params_to_url(url, params)
      else
        add_app_env("#{url}?", params)
      end
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

    # DEPRECATED: This implementation does not safely encode the parameters to
    # be passed as query params in a get request. This method gets called by
    # agents up to version 0.4.5
    def add_app_env(url, params)
      deprecation_warning = <<~WARN
        [WARNING] You are running a Zenaton agent with a version <= 0.4.5
                  Please consider upgrading to a more recent version.
      WARN
      warn(deprecation_warning)

      app_env = @app_env ? "#{APP_ENV}=#{@app_env}&" : ''
      app_id = @app_id ? "#{APP_ID}=#{@app_id}&" : ''

      "#{url}#{app_env}#{app_id}#{params}"
    end

    def append_params_to_url(url, params)
      params[APP_ENV] = @app_env if @app_env
      params[APP_ID] = @app_id if @app_id

      "#{url}?#{URI.encode_www_form(params)}"
    end
  end
end
