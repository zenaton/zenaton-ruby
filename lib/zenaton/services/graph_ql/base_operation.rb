# frozen_string_literal: true

require 'securerandom'
require 'zenaton/exceptions'
require 'zenaton/services/properties'
require 'zenaton/services/serializer'

module Zenaton
  module Services
    module GraphQL
      # @abstract Superclass for graphql queries and mutations.
      # It expects two methods to be implemented in children classes:
      # - #body
      # - #raw_query
      class BaseOperation
        # Sets up common dependencies for serialization
        # Don't forget to call #super in your children #initialize if
        # overriding this method.
        def initialize(*)
          @serializer = Services::Serializer.new
          @properties = Services::Properties.new
        end

        # To be implemented in subclasses.
        # Should return the body of the GraphQL request
        # @raise [NotImplemented]
        def body
          raise NotImplemented
        end

        # To be implemented in subclasses.
        # The actual GraphQL query
        # @raise [NotImplemented]
        def raw_query
          raise NotImplemented
        end

        # Default implementation for parsing GraphQL responses
        # Override in subclasses if needed.
        # @raise [NotImplemented]
        def result(response)
          raise Zenaton::ExternalError, format_errors(response) \
            if response['errors']

          response['data']
        end

        # Removes duplicate white space from the raw_query
        # @return [String]
        def query
          raw_query.gsub(/\s+/, ' ')
        end

        # Sets an unique identifier to the query
        # @return [String]
        def intent_id
          SecureRandom.uuid
        end

        private

        def format_errors(response)
          response['errors'].map(&method(:format_error))
                            .join("\n")
        end

        def format_error(error)
          if error['path']
            "- #{error['path']}: #{error['message']}"
          else
            "- #{error['message']}"
          end
        end
      end
    end
  end
end
