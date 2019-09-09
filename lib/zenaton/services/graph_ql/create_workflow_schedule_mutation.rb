# frozen_string_literal: true

require 'zenaton/services/graph_ql/base_mutation'
require 'zenaton/workflows/version'

module Zenaton
  module Services
    module GraphQL
      # Mutation parameters for scheduling a Task
      class CreateWorkflowScheduleMutation < BaseMutation
        def initialize(workflow, cron, app_env)
          super
          @workflow = workflow
          @cron = cron
          @app_env = app_env
        end

        # The body of the GraphQL request
        def body
          { 'query' => query, 'variables' => variables }
        end

        # The query to be executed
        def raw_query
          <<~GQL
            mutation ($input: CreateWorkflowScheduleInput!) {
              createWorkflowSchedule(input: $input) {
                schedule {
                  id
                }
              }
            }
          GQL
        end

        # The variables used in the query
        def variables
          { 'input' => input }
        end

        private

        def workflow_name
          if @workflow.is_a? Workflows::Version
            @workflow.current_implementation.class.name
          else
            @workflow.class.name
          end
        end

        def input
          {
            'intentId' => intent_id,
            'environmentName' => @app_env,
            'cron' => @cron,
            'workflowName' => workflow_name,
            'canonicalName' => @workflow.class.name,
            'programmingLanguage' => 'RUBY',
            'properties' => @serializer.encode(@properties.from(@workflow))
          }
        end
      end
    end
  end
end
