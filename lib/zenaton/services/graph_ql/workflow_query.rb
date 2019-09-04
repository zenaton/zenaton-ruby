# frozen_string_literal: true

require 'zenaton/services/graph_ql/base_query'

module Zenaton
  module Services
    module GraphQL
      class WorkflowQuery < BaseQuery
        def initialize(workflow_name, custom_id, app_env)
          super
          @workflow_name = workflow_name
          @custom_id = custom_id
          @app_env = app_env
        end

        def body
          { 'query' => query, 'variables' => variables }
        end

        def raw_query
          <<~GQL
            query workflow($workflowName: String, $customId: ID, $environmentName: String, $programmingLanguage: String) {
              workflow(environmentName: $environmentName, programmingLanguage: $programmingLanguage, customId: $customId, name: $workflowName) {
                name
                properties
              }
            }
          GQL
        end

        def variables
          {
            'customId' => @custom_id,
            'environmentName' => @app_env,
            'programmingLanguage' => 'RUBY',
            'workflowName' => @workflow_name
          }
        end

        def result(data)
          @properties.object_from(
            data['name'],
            @serializer.decode(data['properties'])
          )
        end
      end
    end
  end
end
