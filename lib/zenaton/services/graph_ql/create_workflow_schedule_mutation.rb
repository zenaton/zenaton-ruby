# frozen_string_literal: true

require 'zenaton/services/graph_ql/base_operation'
require 'zenaton/concerns/workflow'

module Zenaton
  module Services
    module GraphQL
      # Mutation parameters for scheduling a Task
      class CreateWorkflowScheduleMutation < BaseOperation
        include Concerns::Workflow

        # @raise [Zenaton::InvalidArgumentError] if custom id fails validation
        def initialize(workflow, cron, app_env)
          super
          @workflow = workflow
          @cron = cron
          @app_env = app_env
          validate_custom_id
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

        def input
          {
            'intentId' => intent_id,
            'environmentName' => @app_env,
            'cron' => @cron,
            'customId' => @workflow.id.try(:to_s),
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
