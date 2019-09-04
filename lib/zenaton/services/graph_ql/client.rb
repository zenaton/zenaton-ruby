# frozen_string_literal: true

require 'securerandom'
require 'zenaton/services/graph_ql/create_workflow_schedule_mutation'
require 'zenaton/services/graph_ql/create_task_schedule_mutation'

module Zenaton
  module Services
    module GraphQL
      # Small client to interact with Zenaton's GraphQL API
      class Client
        ZENATON_GATEWAY_URL = 'https://gateway.zenaton.com/api' # Gateway url

        def initialize(http:, credentials:)
          @http = http
          @credentials = credentials
        end

        def schedule_workflow(workflow, cron)
          app_env = @credentials['app_env']
          mutation = CreateWorkflowScheduleMutation.new(workflow, cron, app_env)
          response = @http.post(url, mutation.body, headers)
          raise Zenaton::ExternalError if response['errors']

          response['data']
        end

        def schedule_task(task, cron)
          app_env = @credentials['app_env']
          mutation = CreateTaskScheduleMutation.new(task, cron, app_env)
          response = @http.post(url, mutation.body, headers)
          raise Zenaton::ExternalError if response['errors']

          response['data']
        end

        private

        def url
          ENV['ZENATON_GATEWAY_URL'] || ZENATON_GATEWAY_URL
        end

        def headers
          {
            'app-id' => @credentials['app_id'],
            'api-token' => @credentials['api_token']
          }
        end
      end
    end
  end
end
