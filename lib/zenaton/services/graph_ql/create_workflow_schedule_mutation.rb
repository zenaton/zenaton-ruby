# frozen_string_literal: true

require 'securerandom'
require 'zenaton/services/graph_ql/base_mutation'

module Zenaton
  module Services
    module GraphQL
      class CreateWorkflowScheduleMutation < BaseMutation
        def initialize(workflow, cron, env)
          super
          @workflow = workflow
          @cron = cron
          @env = env
        end

        def body
          { 'query' => query, 'variables' => variables }
        end

        def raw_query
          <<~GQL
            mutation ($createWorkflowScheduleInput: CreateWorkflowScheduleInput!) {
              createWorkflowSchedule(input: $createWorkflowScheduleInput) {
                schedule {
                  id
                }
              }
            }
          GQL
        end

        def variables
          {
            'createWorkflowScheduleInput' => {
              'intentId' => SecureRandom.uuid,
              'environmentName' => @env,
              'cron' => @cron,
              'workflowName' => class_name(@workflow),
              'canonicalName' => canonical_name(@workflow) || class_name(@workflow),
              'programmingLanguage' => 'RUBY',
              'properties' => @serializer.encode(@properties.from(@workflow))
            }
          }
        end

        private

        def canonical_name(flow)
          flow.class.name if flow.is_a? Workflows::Version
        end

        def class_name(flow)
          return flow.class.name unless flow.is_a? Workflows::Version

          flow.current_implementation.class.name
        end
      end
    end
  end
end
