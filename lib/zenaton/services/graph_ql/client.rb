# frozen_string_literal: true

require 'securerandom'
require 'zenaton/services/graph_ql/create_workflow_schedule_mutation'
require 'zenaton/services/graph_ql/create_task_schedule_mutation'
require 'zenaton/services/graph_ql/dispatch_task_mutation'
require 'zenaton/services/graph_ql/dispatch_workflow_mutation'
require 'zenaton/services/graph_ql/kill_workflow_mutation'
require 'zenaton/services/graph_ql/pause_workflow_mutation'
require 'zenaton/services/graph_ql/resume_workflow_mutation'
require 'zenaton/services/graph_ql/send_event_mutation'

module Zenaton
  module Services
    module GraphQL
      # Small client to interact with Zenaton's GraphQL API
      class Client
        ZENATON_GATEWAY_URL = 'https://gateway.zenaton.com/api' # Gateway url

        def initialize(http:)
          @http = http
        end

        def schedule_workflow(workflow, cron, credentials)
          app_env = credentials['app_env']
          mutation = CreateWorkflowScheduleMutation.new(workflow, cron, app_env)
          response = @http.post(url, mutation.body, headers(credentials))
          raise Zenaton::ExternalError, format_errors(response) if response['errors']

          response['data']
        end

        def schedule_task(task, cron, credentials)
          app_env = credentials['app_env']
          mutation = CreateTaskScheduleMutation.new(task, cron, app_env)
          response = @http.post(url, mutation.body, headers(credentials))
          raise Zenaton::ExternalError, format_errors(response) if response['errors']

          response['data']
        end

        def start_task(task, credentials)
          app_env = credentials['app_env']
          mutation = DispatchTaskMutation.new(task, app_env)
          response = @http.post(url, mutation.body, headers(credentials))
          raise Zenaton::ExternalError, format_errors(response) if response['errors']

          response['data']
        end

        def start_workflow(workflow, credentials)
          app_env = credentials['app_env']
          mutation = DispatchWorkflowMutation.new(workflow, app_env)
          response = @http.post(url, mutation.body, headers(credentials))
          raise Zenaton::ExternalError, format_errors(response) if response['errors']

          response['data']
        end

        def kill_workflow(name, custom_id, credentials)
          app_env = credentials['app_env']
          mutation = KillWorkflowMutation.new(name, custom_id, app_env)
          response = @http.post(url, mutation.body, headers(credentials))
          raise Zenaton::ExternalError, format_errors(response) if response['errors']

          response['data']
        end

        def pause_workflow(name, custom_id, credentials)
          app_env = credentials['app_env']
          mutation = PauseWorkflowMutation.new(name, custom_id, app_env)
          response = @http.post(url, mutation.body, headers(credentials))
          raise Zenaton::ExternalError, format_errors(response) if response['errors']

          response['data']
        end

        def resume_workflow(name, custom_id, credentials)
          app_env = credentials['app_env']
          mutation = ResumeWorkflowMutation.new(name, custom_id, app_env)
          response = @http.post(url, mutation.body, headers(credentials))
          raise Zenaton::ExternalError, format_errors(response) if response['errors']

          response['data']
        end

        def send_event(name, custom_id, event, credentials)
          app_env = credentials['app_env']
          mutation = SendEventMutation.new(name, custom_id, event, app_env)
          response = @http.post(url, mutation.body, headers(credentials))
          raise Zenaton::ExternalError, format_errors(response) if response['errors']

          response['data']
        end

        private

        def url
          ENV['ZENATON_GATEWAY_URL'] || ZENATON_GATEWAY_URL
        end

        def headers(credentials)
          {
            'app-id' => credentials['app_id'],
            'api-token' => credentials['api_token']
          }
        end

        def format_errors(response)
          response['errors'].map do |error|
            path = error['path'] ? "- #{error['path']}: " : ''
            "#{path}#{error['message']}"
          end.join("\n")
        end
      end
    end
  end
end
