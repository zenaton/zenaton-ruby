# frozen_string_literal: true

require 'zenaton/services/graph_ql/base_query'

module Zenaton
  module Services
    module GraphQL
      # Query parameters to search for a Workflow
      class WorkflowQuery < BaseQuery
        def initialize(workflow_name, custom_id, app_env)
          super
          @workflow_name = workflow_name
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
            query ($workflowName: String, $customId: ID, $environmentName: String, $programmingLanguage: String) {
              findWorkflow(environmentName: $environmentName, programmingLanguage: $programmingLanguage, customId: $customId, name: $workflowName) {
                name
                properties
              }
            }
          GQL
        end

        # The variables used in the query
        def variables
          {
            'customId' => @custom_id,
            'environmentName' => @app_env,
            'programmingLanguage' => 'RUBY',
            'workflowName' => @workflow_name
          }
        end

        # Parses the results of the query
        def result(response)
          data = response['data']
          raise Zenaton::ExternalError, format_errors(response) unless data

          return nil if data['findWorkflow'].nil?

          @properties.object_from(
            data['findWorkflow']['name'],
            @serializer.decode(data['findWorkflow']['properties'])
          )
        end
      end
    end
  end
end
