# frozen_string_literal: true

require 'zenaton/services/graph_ql/base_operation'
require 'zenaton/workflows/version'
require 'zenaton/exceptions'

module Zenaton
  module Services
    module GraphQL
      # Mutation parameters for executing a workflow
      class DispatchWorkflowMutation < BaseOperation
        MAX_ID_SIZE = 256

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

        private

        def workflow_name
          if @workflow.is_a? Workflows::Version
            @workflow.current_implementation.class.name
          else
            @workflow.class.name
          end
        end

        def validate_custom_id
          return unless @workflow.try(:id).present?

          validate_custom_id_type
          validate_custom_id_value
        end

        def validate_custom_id_type
          valid_types = [String, Integer]
          return if valid_types.any? { |type| @workflow.id.is_a?(type) }

          raise InvalidArgumentError,
                'Provided ID must be a string or an integer' \
        end

        def validate_custom_id_value
          return if @workflow.id.to_s.length <= MAX_ID_SIZE

          raise InvalidArgumentError,
                "Provided Id must not exceed #{MAX_ID_SIZE} bytes"
        end
      end
    end
  end
end
