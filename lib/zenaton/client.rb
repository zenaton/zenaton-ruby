# frozen_string_literal: true

require 'singleton'
require 'zenaton/services/http'
require 'zenaton/workflows/version'
require 'zenaton/interfaces/workflow'
require 'zenaton/interfaces/event'

module Zenaton
  # Zenaton Client
  class Client
    include Singleton

    ZENATON_API_URL = 'https://zenaton.com/api/v1'
    ZENATON_WORKER_URL = 'http://localhost'
    DEFAULT_WORKER_PORT = 4001
    WORKER_API_VERSION = 'v_newton'

    MAX_ID_SIZE = 256

    APP_ENV = 'app_env'
    APP_ID = 'app_id'
    API_TOKEN = 'api_token'

    ATTR_ID = 'custom_id'
    ATTR_NAME = 'name'
    ATTR_CANONICAL = 'canonical_name'
    ATTR_DATA = 'data'
    ATTR_PROG = 'programming_language'
    ATTR_MODE = 'mode'

    PROG = 'Ruby'

    EVENT_INPUT = 'event_input'
    EVENT_NAME = 'event_name'

    WORKFLOW_KILL = 'kill'
    WORKFLOW_PAUSE = 'pause'
    WORKFLOW_RUN = 'run'

    attr_writer :app_id, :api_token, :app_env

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
    end

    # Gets the url for the workers
    # @param resource [String] the endpoint for the worker
    # @param params [String] url encoded parameters to include in request
    # @return [String] the workers url with parameters
    def worker_url(resource = '', params = '')
      base_url = ENV['ZENATON_WORKER_URL'] || ZENATON_WORKER_URL
      port = ENV['ZENATON_WORKER_PORT'] || DEFAULT_WORKER_PORT
      url = "#{base_url}:#{port}/api/#{WORKER_API_VERSION}/#{resource}?"
      add_app_env(url, params)
    end

    # Gets the url for zenaton api
    # @param resource [String] the endpoint for the api
    # @param params [String] url encoded parameters to include in request
    # @return [String] the api url with parameters
    def website_url(resource = '', params = '')
      api_url = ENV['ZENATON_API_URL'] || ZENATON_API_URL
      url = "#{api_url}/#{resource}?#{API_TOKEN}=#{@api_token}&"
      add_app_env(url, params)
    end

    # Start the specified workflow
    # @param flow [Zenaton::Interfaces::Workflow]
    def start_workflow(flow)
      @http.post(
        instance_worker_url,
        ATTR_PROG => PROG,
        ATTR_CANONICAL => canonical_name(flow),
        ATTR_NAME => class_name(flow),
        ATTR_DATA => { hard_coded: 'json' }.to_json,
        ATTR_ID => parse_custom_id_from(flow)
      )
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
    # @param custom_id [String] the custom ID of the workflow (if any)
    # @return [Zenaton::Interfaces::Workflow]
    def find_workflow(workflow_name, custom_id)
      # rubocop:disable Metrics/LineLength
      params = "#{ATTR_ID}=#{custom_id}&#{ATTR_NAME}=#{workflow_name}&#{ATTR_PROG}=#{PROG}"
      # rubocop:enable Metrics/LineLength
      data = @http.get(instance_website_url(params))
      Object.const_get(data['name']).new
    end

    # Sends an event to a workflow
    # @param workflow_name [String] the class name of the workflow
    # @param custom_id [String] the custom ID of the workflow (if any)
    # @param event [Zenaton::Interfaces::Event] the event to send
    # @return [NilClass]
    def send_event(workflow_name, custom_id, event)
      body = {
        ATTR_PROG => PROG,
        ATTR_NAME => workflow_name,
        ATTR_ID => custom_id,
        EVENT_NAME => event.class.name,
        EVENT_INPUT => { hardcoded: 'json' }.to_json
      }
      @http.post(send_event_url, body)
    end

    private

    def add_app_env(url, params)
      app_env = @app_env ? "#{APP_ENV}=#{@app_env}&" : ''
      app_id = @app_id ? "#{APP_ID}=#{@app_id}&" : ''

      "#{url}#{app_env}#{app_id}#{params}"
    end

    def instance_website_url(params)
      website_url('instances', params)
    end

    def instance_worker_url(params = '')
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
      params = "#{ATTR_ID}=#{custom_id}"
      url = instance_worker_url(params)
      options = {
        ATTR_PROG => PROG,
        ATTR_NAME => workflow_name,
        ATTR_MODE => mode
      }
      @http.put(url, options)
    end
  end
end
