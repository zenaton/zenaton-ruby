# frozen_string_literal: true

require 'zenaton/services/graph_ql/base_mutation'

module Zenaton
  module Services
    module GraphQL
      class DispatchWorkflowMutation < BaseMutation
        def initialize(workflow, app_env)
          super
          @workflow = workflow
          @app_env = app_env
        end

        def body
          { 'query' => query, 'variables' => variables }
        end

        def raw_query
          <<~GQL
            mutation dispatchWorkflow($input: DispatchWorkflowInput!) {
              dispatchWorkflow(input: $input) {
                workflow {
                  id
                }
              }
            }
          GQL
        end

        def variables
          {
            'input' => {
              'customId' => @workflow.id,
              'environmentName' => @app_env,
              'intentId' => intent_id,
              'programmingLanguage' => 'RUBY',
              'name' => workflow_name,
              'canonicalName' => @workflow.class.name,
              'data' => @serializer.encode(@properties.from(@workflow))
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
