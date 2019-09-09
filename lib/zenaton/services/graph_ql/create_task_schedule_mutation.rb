# frozen_string_literal: true

require 'zenaton/services/graph_ql/base_mutation'

module Zenaton
  module Services
    module GraphQL
      # Mutation parameters for scheduling a Task
      class CreateTaskScheduleMutation < BaseMutation
        def initialize(task, cron, app_env)
          super
          @task = task
          @cron = cron
          @app_env = app_env
        end

        # The body of the GraphQL request
        def body
          { 'query' => query, 'variables' => variables }
        end

        # The query to be executed
        def raw_query
          <<~GQL
            mutation ($input: CreateTaskScheduleInput!) {
              createTaskSchedule(input: $input) {
                schedule {
                  id
                }
              }
            }
          GQL
        end

        # The variables used in the query
        def variables
          {
            'input' => {
              'intentId' => intent_id,
              'environmentName' => @app_env,
              'cron' => @cron,
              'taskName' => @task.class.name,
              'programmingLanguage' => 'RUBY',
              'properties' => @serializer.encode(@properties.from(@task))
            }
          }
        end
      end
    end
  end
end
