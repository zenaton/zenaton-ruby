# frozen_string_literal: true

require 'net/http'
require 'zenaton/exceptions'

module Zenaton
  # Collection of utility classes for the Zenaton library
  module Services
    # Wrapper class around HTTParty that:
    # - handles graphql calls
    # - translates exceptions into Zenaton specific ones
    # rubocop:disable Metrics/ClassLength
    class GraphQL
      # Net::HTTP errors translated into a Zenaton::ConnectionError
      ALL_NET_HTTP_ERRORS = [
        Timeout::Error,
        Errno::EINVAL,
        Errno::ECONNRESET,
        EOFError,
        Net::HTTPBadResponse,
        Net::HTTPHeaderSyntaxError,
        Net::ProtocolError
      ].freeze

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

      # Makes a GRAPHQL request with some data and sets the correct headers
      #
      # @param url [String] the url for the request
      # @param body [Hash] the payload to send with the request
      # @return [Hash] the parsed json response
      def request(url, query, variables = nil, headers = {})
        headers = default_headers.merge(headers)
        parsed_url = parse_url(url)
        request = Net::HTTP::Post.new(parsed_url[:uri])
        body = { 'query' => query }
        body['variables'] = variables if variables

        set_body_and_headers(request, body, headers)
        make_request(request, parsed_url)
      end

      private

      def parse_url(url)
        uri = URI.parse(url)
        { uri: uri, use_ssl: uri.scheme == 'https' }
      end

      def set_body_and_headers(request, body, headers)
        headers.each do |key, value|
          request[key] = value
        end
        request.body = body.to_json
      end

      def make_request(request, parsed_url)
        res = get_response(request, parsed_url)
        if internal_error?(res)
          raise Zenaton::InternalError, format_internal_error(res)
        end

        handle_response_body(res.body)
      rescue *ALL_NET_HTTP_ERRORS
        raise Zenaton::ConnectionError
      end

      def get_response(request, parsed_url)
        Net::HTTP.start(
          parsed_url[:uri].hostname,
          parsed_url[:uri].port,
          use_ssl: parsed_url[:use_ssl]
        ) do |http|
          http.request(request)
        end
      end

      def handle_response_body(body)
        parsed_body = JSON.parse(body)
        if external_error?(parsed_body)
          raise Zenaton::ExternalError, format_external_error(parsed_body)
        end

        parsed_body['data']
      end

      def internal_error?(response)
        response.code.to_i >= 400
      end

      def external_error?(response_body)
        response_body.key?('errors')
      end

      def format_internal_error(response)
        message = JSON.parse(response.read_body)['error']
        "#{response.code}: #{message}"
      end

      def format_external_error(response_body)
        response_body['errors'].map do |error|
          path = error['path'] ? "#{- error['path']}: " : ''
          "#{path}#{error['message']}"
        end.join("\n")
      end

      def default_headers
        {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json'
        }
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
