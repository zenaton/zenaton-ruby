# frozen_string_literal: true

require 'zenaton/services/graph_ql/create_workflow_schedule_mutation'
require 'zenaton/services/graph_ql/create_task_schedule_mutation'
require 'zenaton/services/graph_ql/dispatch_task_mutation'
require 'zenaton/services/graph_ql/dispatch_workflow_mutation'
require 'zenaton/services/graph_ql/kill_workflow_mutation'
require 'zenaton/services/graph_ql/pause_workflow_mutation'
require 'zenaton/services/graph_ql/resume_workflow_mutation'
require 'zenaton/services/graph_ql/send_event_mutation'
require 'zenaton/services/graph_ql/workflow_query'

module Zenaton
  module Services
    module GraphQL
      # Small client to interact with Zenaton's GraphQL API
      class Client
        ZENATON_GATEWAY_URL = 'https://gateway.zenaton.com/api' # Gateway url

        # Setup the GraphQL client with the HTTP client to use
        def initialize(http:)
          @http = http
        end

        # Scheduling a workflow
        def schedule_workflow(workflow, cron, credentials)
          app_env = credentials['app_env']
          mutation = CreateWorkflowScheduleMutation.new(workflow, cron, app_env)
          execute(mutation, credentials)
        end

        # Scheduling a task
        def schedule_task(task, cron, credentials)
          app_env = credentials['app_env']
          mutation = CreateTaskScheduleMutation.new(task, cron, app_env)
          execute(mutation, credentials)
        end

        # Dispatching a single task
        def start_task(task, credentials)
          app_env = credentials['app_env']
          mutation = DispatchTaskMutation.new(task, app_env)
          execute(mutation, credentials)
        end

        # Dispatching a workflow
        def start_workflow(workflow, credentials)
          app_env = credentials['app_env']
          mutation = DispatchWorkflowMutation.new(workflow, app_env)
          execute(mutation, credentials)
        end

        # Stopping an existing workflow
        def kill_workflow(name, custom_id, credentials)
          app_env = credentials['app_env']
          mutation = KillWorkflowMutation.new(name, custom_id, app_env)
          execute(mutation, credentials)
        end

        # Pausing an existing workflow
        def pause_workflow(name, custom_id, credentials)
          app_env = credentials['app_env']
          mutation = PauseWorkflowMutation.new(name, custom_id, app_env)
          execute(mutation, credentials)
        end

        # Resuming a paused workflow
        def resume_workflow(name, custom_id, credentials)
          app_env = credentials['app_env']
          mutation = ResumeWorkflowMutation.new(name, custom_id, app_env)
          execute(mutation, credentials)
        end

        # Sending an event to an existing workflow
        def send_event(name, custom_id, event, credentials)
          app_env = credentials['app_env']
          mutation = SendEventMutation.new(name, custom_id, event, app_env)
          execute(mutation, credentials)
        end

        # Search for a workflow with a custom ID
        def find_workflow(name, custom_id, credentials)
          app_env = credentials['app_env']
          query = WorkflowQuery.new(name, custom_id, app_env)
          execute(query, credentials)
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

        def execute(operation, credentials)
          response = @http.post(url, operation.body, headers(credentials))
          operation.result(response)
        end
      end
    end
  end
end
