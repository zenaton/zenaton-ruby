# frozen_string_literal: true

require 'httparty'
require 'zenaton/exceptions'

module Zenaton
  # Collection of utility classes for the Zenaton library
  module Services
    # Wrapper class around HTTParty that:
    # - handles http calls
    # - sets appropriate headers for each request type
    # - translates exceptions into Zenaton specific ones
    class Http
      # Makes a GET request and sets the correct headers
      #
      # @param url [String] the url for the request
      # @return [Hash] the parsed json response
      def get(url)
        request(:get, url, default_options)
      end

      # Makes a POST request with some data and sets the correct headers
      #
      # @param url [String] the url for the request
      # @param body [Hash] the payload to send with the request
      # @return [Hash] the parsed json response
      def post(url, body)
        request(:post, url, post_options(body))
      end

      # Makes a PUT request with some data and sets the correct headers
      #
      # @param url [String] the url for the request
      # @param body [Hash] the payload to send with the request
      # @return [Hash] the parsed json response
      def put(url, body)
        request(:put, url, put_options(body))
      end

      private

      def request(verb, url, options)
        make_request(verb, url, options)
      rescue SocketError, HTTParty::Error => error
        raise Zenaton::ConnectionError, error
      end

      def make_request(verb, url, options)
        response = HTTParty.send(verb, url, options)
        raise Zenaton::InternalError, format_error(response) if errors? response
        JSON.parse(response.body)
      end

      def errors?(response)
        response.code >= 400
      end

      def format_error(response)
        "#{response.code}: #{response.message}"
      end

      def default_options
        {
          headers: { 'Accept' => 'application/json' }
        }
      end

      def post_options(body)
        {
          body: body.to_json,
          headers: {
            'Accept' => 'application/json',
            'Content-Type' => 'application/json'
          }
        }
      end
      alias put_options post_options
    end
  end
end
