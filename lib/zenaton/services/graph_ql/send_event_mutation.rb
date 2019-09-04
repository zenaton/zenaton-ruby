# frozen_string_literal: true

require 'zenaton/services/graph_ql/base_mutation'

module Zenaton
  module Services
    module GraphQL
      class SendEventMutation < BaseMutation
        def initialize(name, custom_id, event, app_env)
          super
          @workflow_name = name
          @custom_id = custom_id
          @event = event
          @app_env = app_env
        end

        def body
          { 'query' => query, 'variables' => variables }
        end

        def raw_query
          <<~GQL
            mutation sendEventToWorkflowByNameAndCustomId($input: SendEventToWorkflowByNameAndCustomIdInput!) {
              sendEventToWorkflowByNameAndCustomId(input: $input) {
                event {
                  intentId
                }
              }
            }
          GQL
        end

        def variables
          {
            'input' => {
              'customId' => @custom_id,
              'workflowName' => @workflow_name,
              'name' => @event.class.name,
              'environmentName' => 'dev',
              'intentId' => intent_id,
              'programmingLanguage' => 'RUBY',
              'input' => @serializer.encode(@properties.from(@event)),
              'data' => @serializer.encode(@event)
            }
          }
        end
      end
    end
  end
end
