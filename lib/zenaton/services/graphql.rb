# frozen_string_literal: true

require 'net/http'
require 'zenaton/exceptions'

module Zenaton
  # Collection of utility classes for the Zenaton library
  module Services
    # Service that:
    # - handles graphql calls
    # - translates exceptions into Zenaton specific ones
    class GraphQL
      CREATE_WORKFLOW_SCHEDULE = <<-'GRAPHQL'
        mutation ($createWorkflowScheduleInput: CreateWorkflowScheduleInput!) {
          createWorkflowSchedule(input: $createWorkflowScheduleInput) {
            schedule {
              id
              name
              cron
              insertedAt
              updatedAt
              target {
                ... on WorkflowTarget {
                  type
                  name
                  canonicalName
                  programmingLanguage
                  properties
                }
              }
            }
          }
        }
      GRAPHQL

      CREATE_TASK_SCHEDULE = <<-'GRAPHQL'
        mutation ($createTaskScheduleInput: CreateTaskScheduleInput!) {
          createTaskSchedule(input: $createTaskScheduleInput) {
            schedule {
              id
              name
              cron
              insertedAt
              updatedAt
              target {
                ... on TaskTarget {
                  type
                  name
                  type
                  programmingLanguage
                  properties
                }
              }
            }
          }
        }
      GRAPHQL

      def initialize(http:)
        @http = http
      end

      # Makes a GRAPHQL request with some data and sets the correct headers
      #
      # @param url [String] the url for the request
      # @param body [Hash] the payload to send with the request
      # @return [Hash] the parsed json response
      def request(url, query, variables = nil, headers = {})
        body = { 'query' => query }
        body['variables'] = variables if variables

        res_body = @http.post(url, body, headers)
        handle_response_body(res_body)
      end

      private

      def handle_response_body(response_body)
        puts response_body
        if external_error?(response_body)
          raise Zenaton::ExternalError, format_external_error(response_body)
        end

        response_body['data']
      end

      def external_error?(response_body)
        response_body.key?('errors')
      end

      def format_external_error(response_body)
        response_body['errors'].map do |error|
          path = error['path'] ? "- #{error['path']}: " : ''
          "#{path}#{error['message']}"
        end.join("\n")
      end
    end
  end
end
