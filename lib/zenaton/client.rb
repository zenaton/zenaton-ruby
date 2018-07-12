# frozen_string_literal: true

require 'singleton'
require 'zenaton/services/http'
require 'zenaton/workflow'

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

    PROG = 'RUBY'

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
    def get_worker_url(resource = '', params = '')
      base_url = ENV['ZENATON_WORKER_URL'] || ZENATON_WORKER_URL
      port = ENV['ZENATON_WORKER_PORT'] || DEFAULT_WORKER_PORT
      url = "#{base_url}:#{port}/api/#{WORKER_API_VERSION}/#{resource}?"
      add_app_env(url, params)
    end

    # Gets the url for zenaton api
    # @param resource [String] the endpoint for the api
    # @param params [String] url encoded parameters to include in request
    # @return [String] the api url with parameters
    def get_website_url(resource = '', params = '')
      api_url = ENV['ZENATON_API_URL'] || ZENATON_API_URL
      url = "#{api_url}/#{resource}?#{API_TOKEN}=#{@api_token}&"
      add_app_env(url, params)
    end

    # Start the specified workflow
    # @param workflow [Zenaton::Workflow]
    def start_workflow(flow)
      custom_id = parse_custom_id_from(flow)
      @http.post(
        get_instance_worker_url,
        ATTR_PROG => PROG,
        ATTR_CANONICAL => nil,
        ATTR_NAME => get_class(flow),
        ATTR_DATA => { hard_coded: 'json' }.to_json,
        ATTR_ID => custom_id
      )
    end

    private

    def add_app_env(url, params)
      app_env = @app_env ? "#{APP_ENV}=#{@app_env}&" : ''
      app_id = @app_id ? "#{APP_ID}=#{@app_id}&" : ''

      "#{url}#{app_env}#{app_id}#{params}"
    end

    def get_instance_website_url(params)
      get_website_url('instances', params)
    end

    def get_instance_worker_url(params = '')
      get_worker_url('instances', params)
    end

    def get_send_url # rubocop:disable Naming/AccessorMethodName
      get_worker_url('events')
    end

    def get_class(object)
      object.class.name
    end

    # rubocop:disable Metrics/MethodLength
    def parse_custom_id_from(flow)
      custom_id = flow.get_id
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
  end
end
