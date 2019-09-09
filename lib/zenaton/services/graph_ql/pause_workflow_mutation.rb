# frozen_string_literal: true

require 'zenaton/services/graph_ql/base_mutation'

module Zenaton
  module Services
    module GraphQL
      # Mutation parameters for pausing a Workflow
      class PauseWorkflowMutation < BaseMutation
        def initialize(name, custom_id, app_env)
          super
          @name = name
          @custom_id = custom_id
          @app_env = app_env
        end

        # The body of the GraphQL request
        def body
          { 'query' => query, 'variables' => variables }
        end

        # The query to be executed
        def raw_query
          <<~GQL
            mutation pauseWorkflow($input: PauseWorkflowInput!) {
              pauseWorkflow(input: $input) {
                id
              }
            }
          GQL
        end

        # The variables used in the query
        def variables
          {
            'input' => {
              'customId' => @custom_id,
              'environmentName' => @app_env,
              'intentId' => intent_id,
              'programmingLanguage' => 'RUBY',
              'name' => @name
            }
          }
        end
      end
    end
  end
end
