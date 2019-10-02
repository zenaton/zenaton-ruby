# frozen_string_literal: true

require 'zenaton/services/graph_ql/base_operation'

module Zenaton
  module Services
    module GraphQL
      # Mutation parameters for executing a single task
      class DispatchTaskMutation < BaseOperation
        def initialize(task, app_env)
          super
          @task = task
          @app_env = app_env
        end

        # The body of the GraphQL request
        def body
          { 'query' => query, 'variables' => variables }
        end

        # The query to be executed
        def raw_query
          <<~GQL
            mutation dispatchTask($input: DispatchTaskInput!) {
              dispatchTask(input: $input) {
                task {
                  intentId
                }
              }
            }
          GQL
        end

        # The variables used in the query
        def variables
          {
            'input' => {
              'environmentName' => @app_env,
              'intentId' => intent_id,
              'name' => @task.class.name,
              'maxProcessingTime' => @task.try(:max_processing_time),
              'programmingLanguage' => 'RUBY',
              'data' => @serializer.encode(@properties.from(@task))
            }
          }
        end
      end
    end
  end
end
