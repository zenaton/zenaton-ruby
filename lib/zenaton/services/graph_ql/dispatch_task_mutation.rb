# frozen_string_literal: true

require 'zenaton/services/graph_ql/base_mutation'

module Zenaton
  module Services
    module GraphQL
      class DispatchTaskMutation < BaseMutation
        def initialize(task, app_env)
          super
          @task = task
          @app_env = app_env
        end

        def body
          { 'query' => query, 'variables' => variables }
        end

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
