# frozen_string_literal: true

require 'json'
require 'net/http'
require 'zenaton/exceptions'
require 'json'

module Zenaton
  # Collection of utility classes for the Zenaton library
  module Services
    # Wrapper class around HTTParty that:
    # - handles http calls
    # - sets appropriate headers for each request type
    # - translates exceptions into Zenaton specific ones
    class Http
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

      # Makes a GET request and sets the correct headers
      #
      # @param url [String] the url for the request
      # @return [Hash] the parsed json response
      def get(url)
        parsed_url = parse_url(url)
        request = Net::HTTP::Get.new(parsed_url[:uri])
        set_body_and_headers(request, default_options)
        make_request(request, parsed_url)
      end

      # Makes a POST request with some data and sets the correct headers
      #
      # @param url [String] the url for the request
      # @param body [Hash] the payload to send with the request
      # @param headers [Hash] additional headers to send with the request
      # @return [Hash] the parsed json response
      def post(url, body, headers = {})
        parsed_url = parse_url(url)
        request = Net::HTTP::Post.new(parsed_url[:uri])
        set_body_and_headers(request, post_options(body, headers))
        make_request(request, parsed_url)
      end

      # Makes a PUT request with some data and sets the correct headers
      #
      # @param url [String] the url for the request
      # @param body [Hash] the payload to send with the request
      # @param headers [Hash] additional headers to send with the request
      # @return [Hash] the parsed json response
      def put(url, body, headers = {})
        parsed_url = parse_url(url)
        request = Net::HTTP::Put.new(parsed_url[:uri])
        set_body_and_headers(request, put_options(body, headers))
        make_request(request, parsed_url)
      end

      private

      def parse_url(url)
        uri = URI.parse(url)
        { uri: uri, use_ssl: uri.scheme == 'https' }
      end

      def set_body_and_headers(request, options)
        options[:headers].each do |key, value|
          request[key] = value
        end
        request.body = options[:body].to_json if options[:body]
      end

      def make_request(request, parsed_url)
        res = get_response(request, parsed_url)
        raise Zenaton::InternalError, format_error(res) if errors?(res)
        JSON.parse(res.body)
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

      def errors?(response)
        response.code.to_i >= 400
      end

      def format_error(response)
        message = JSON.parse(response.read_body)['error']
        "#{response.code}: #{message}"
      end

      def default_options
        {
          headers: { 'Accept' => 'application/json' }
        }
      end

      def post_options(body, headers)
        default_post_headers = {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json'
        }
        {
          body: body,
          headers: default_post_headers.merge(headers)
        }
      end
      alias put_options post_options
    end
  end
end
