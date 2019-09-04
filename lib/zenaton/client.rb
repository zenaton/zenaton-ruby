# frozen_string_literal: true

require 'securerandom'
require 'singleton'
require 'zenaton/services/graph_ql/client'
require 'zenaton/services/http'
require 'zenaton/services/properties'
require 'zenaton/services/serializer'
require 'zenaton/workflows/version'

module Zenaton
  # Zenaton Client
  class Client
    include Singleton

    ZENATON_API_URL = 'https://api.zenaton.com/v1' # Zenaton api url
    ZENATON_GATEWAY_URL = 'https://gateway.zenaton.com/api' # Gateway url
    ZENATON_WORKER_URL = 'http://localhost' # Default worker url
    DEFAULT_WORKER_PORT = 4001 # Default worker port
    WORKER_API_VERSION = 'v_newton' # Default worker api version

    MAX_ID_SIZE = 256 # Limit on length of custom ids

    APP_ENV = 'app_env' # Parameter name for the application environment
    APP_ID = 'app_id' # Parameter name for the application ID
    API_TOKEN = 'api_token' # Parameter name for the API token

    ATTR_INTENT_ID = 'intent_id' # Internal parameter for retries
    ATTR_ID = 'custom_id' # Parameter name for custom ids
    ATTR_NAME = 'name' # Parameter name for workflow names
    ATTR_CANONICAL = 'canonical_name' # Parameter name for version name
    ATTR_DATA = 'data' # Parameter name for json payload
    ATTR_PROG = 'programming_language' # Parameter name for the language
    ATTR_MODE = 'mode' # Parameter name for the worker update mode
    # Parameter name for task maximum processing time
    ATTR_MAX_PROCESSING_TIME = 'maxProcessingTime'

    PROG = 'Ruby' # The current programming language

    EVENT_INPUT = 'event_input' # Parameter name for event input
    EVENT_NAME = 'event_name' # Parameter name for event name
    EVENT_DATA = 'event_data' # Parameter name for event data

    WORKFLOW_KILL = 'kill' # Worker update mode to stop a worker
    WORKFLOW_PAUSE = 'pause' # Worker udpate mode to pause a worker
    WORKFLOW_RUN = 'run' # Worker update mode to resume a worker

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

    def gateway_url
      ENV['ZENATON_GATEWAY_URL'] || ZENATON_GATEWAY_URL
    end

    def gateway_headers
      {
        'app-id' => @app_id,
        'api-token' => @api_token
      }
    end

    # Gets the url for zenaton api
    # @param resource [String] the endpoint for the api
    # @param params [Hash|String] query params to be url encoded
    # @return [String] the api url with parameters
    def website_url(resource = '', params = {})
      api_url = ENV['ZENATON_API_URL'] || ZENATON_API_URL
      url = "#{api_url}/#{resource}"

      if params.is_a?(Hash)
        params[API_TOKEN] = @api_token
        append_params_to_url(url, params)
      else
        add_app_env("#{url}?#{API_TOKEN}=#{@api_token}&", params)
      end
    end

    # Start a single task
    # @param task [Zenaton::Interfaces::Task]
    def start_task(task)
      max_processing_time = task.try(:max_processing_time)
      @http.post(
        worker_url('tasks'),
        ATTR_INTENT_ID => SecureRandom.uuid,
        ATTR_PROG => PROG,
        ATTR_NAME => class_name(task),
        ATTR_DATA => @serializer.encode(@properties.from(task)),
        ATTR_MAX_PROCESSING_TIME => max_processing_time
      )
    end

    # Start the specified workflow
    # @param flow [Zenaton::Interfaces::Workflow]
    def start_workflow(flow)
      @http.post(
        instance_worker_url,
        ATTR_INTENT_ID => SecureRandom.uuid,
        ATTR_PROG => PROG,
        ATTR_CANONICAL => canonical_name(flow),
        ATTR_NAME => class_name(flow),
        ATTR_DATA => @serializer.encode(@properties.from(flow)),
        ATTR_ID => parse_custom_id_from(flow)
      )
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
    # @param workflow_name [String] the class name of the workflow
    # @param custom_id [String] the custom ID of the workflow (if any)
    # @return [NilClass]
    def kill_workflow(workflow_name, custom_id)
      update_instance(workflow_name, custom_id, WORKFLOW_KILL)
    end

    # Pauses a workflow
    # @param workflow_name [String] the class name of the workflow
    # @param custom_id [String] the custom ID of the workflow (if any)
    # @return [NilClass]
    def pause_workflow(workflow_name, custom_id)
      update_instance(workflow_name, custom_id, WORKFLOW_PAUSE)
    end

    # Resumes a workflow
    # @param workflow_name [String] the class name of the workflow
    # @param custom_id [String] the custom ID of the workflow (if any)
    # @return [NilClass]
    def resume_workflow(workflow_name, custom_id)
      update_instance(workflow_name, custom_id, WORKFLOW_RUN)
    end

    # Finds a workflow
    # @param workflow_name [String] the class name of the workflow
    # @param custom_id [String] the custom ID of the workflow
    # @return [Zenaton::Interfaces::Workflow, nil]
    def find_workflow(workflow_name, custom_id)
      params = { ATTR_ID => custom_id, ATTR_NAME => workflow_name }
      params[ATTR_PROG] = PROG
      data = @http.get(instance_website_url(params))['data']
      data && @properties.object_from(
        data['name'],
        @serializer.decode(data['properties'])
      )
    rescue Zenaton::InternalError => exception
      return nil if exception.message =~ /No workflow instance found/
      raise exception
    end

    # Sends an event to a workflow
    # @param workflow_name [String] the class name of the workflow
    # @param custom_id [String] the custom ID of the workflow (if any)
    # @param event [Zenaton::Interfaces::Event] the event to send
    # @return [NilClass]
    def send_event(workflow_name, custom_id, event)
      body = {
        ATTR_INTENT_ID => SecureRandom.uuid,
        ATTR_PROG => PROG,
        ATTR_NAME => workflow_name,
        ATTR_ID => custom_id,
        EVENT_NAME => event.class.name,
        EVENT_INPUT => @serializer.encode(@properties.from(event)),
        EVENT_DATA => @serializer.encode(event)
      }
      @http.post(send_event_url, body)
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

    def instance_website_url(params)
      website_url('instances', params)
    end

    def instance_worker_url(params = {})
      worker_url('instances', params)
    end

    def send_event_url
      worker_url('events')
    end

    # rubocop:disable Metrics/MethodLength
    def parse_custom_id_from(flow)
      custom_id = flow.id
      if custom_id
        unless custom_id.is_a?(String) || custom_id.is_a?(Integer)
          raise InvalidArgumentError,
                'Provided ID must be a string or an integer'
        end
        custom_id = custom_id.to_s
        if custom_id.length > MAX_ID_SIZE
          raise InvalidArgumentError,
                "Provided Id must not exceed #{MAX_ID_SIZE} bytes"
        end
      end
      custom_id
    end
    # rubocop:enable Metrics/MethodLength

    def canonical_name(flow)
      flow.class.name if flow.is_a? Workflows::Version
    end

    def class_name(flow)
      return flow.class.name unless flow.is_a? Workflows::Version
      flow.current_implementation.class.name
    end

    def update_instance(workflow_name, custom_id, mode)
      params = { ATTR_ID => custom_id }
      url = instance_worker_url(params)
      options = {
        ATTR_INTENT_ID => SecureRandom.uuid,
        ATTR_PROG => PROG,
        ATTR_NAME => workflow_name,
        ATTR_MODE => mode
      }
      @http.put(url, options)
    end
  end
end
