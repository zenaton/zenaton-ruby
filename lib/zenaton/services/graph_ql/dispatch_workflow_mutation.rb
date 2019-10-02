# frozen_string_literal: true

require 'zenaton/services/graph_ql/base_operation'
require 'zenaton/concerns/workflow'

module Zenaton
  module Services
    module GraphQL
      # Mutation parameters for executing a workflow
      class DispatchWorkflowMutation < BaseOperation
        include Concerns::Workflow

        # @raise [Zenaton::InvalidArgumentError] if custom id fails validation
        def initialize(workflow, app_env)
          super
          @workflow = workflow
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
            mutation dispatchWorkflow($input: DispatchWorkflowInput!) {
              dispatchWorkflow(input: $input) {
                workflow {
                  id
                }
              }
            }
          GQL
        end

        # rubocop:disable Metrics/MethodLength
        # The variables used in the query
        def variables
          {
            'input' => {
              'customId' => @workflow.id.try(:to_s),
              'environmentName' => @app_env,
              'intentId' => intent_id,
              'programmingLanguage' => 'RUBY',
              'name' => workflow_name,
              'canonicalName' => @workflow.class.name,
              'data' => @serializer.encode(@properties.from(@workflow))
            }
          }
        end
        # rubocop:enable Metrics/MethodLength
      end
    end
  end
end
