# frozen_string_literal: true

require 'zenaton/services/graph_ql/base_mutation'

module Zenaton
  module Services
    module GraphQL
      class KillWorkflowMutation < BaseMutation
        def initialize(name, custom_id, app_env)
          super
          @name = name
          @custom_id = custom_id
          @app_env = app_env
        end

        def body
          { 'query' => query, 'variables' => variables }
        end

        def raw_query
          <<~GQL
            mutation killWorkflow($input: KillWorkflowInput!) {
              killWorkflow(input: $input) {
                id
              }
            }
          GQL
        end

        def variables
          {
            'input' => {
              'customId' => @custom_id,
              'environmentName' => 'dev',
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
