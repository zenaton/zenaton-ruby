# frozen_string_literal: true

require 'zenaton/services/graph_ql/base_mutation'

module Zenaton
  module Services
    module GraphQL
      class CreateWorkflowScheduleMutation < BaseMutation
        def initialize(workflow, cron, app_env)
          super
          @workflow = workflow
          @cron = cron
          @app_env = app_env
        end

        def body
          { 'query' => query, 'variables' => variables }
        end

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

        def variables
          {
            'input' => {
              'intentId' => intent_id,
              'environmentName' => @app_env,
              'cron' => @cron,
              'workflowName' => workflow_name,
              'canonicalName' => @workflow.class.name,
              'programmingLanguage' => 'RUBY',
              'properties' => @serializer.encode(@properties.from(@workflow))
            }
          }
        end

        private

        def workflow_name
          if @workflow.is_a? Workflows::Version
            @workflow.current_implementation.class.name
          else
            @workflow.class.name
          end
        end
      end
    end
  end
end
