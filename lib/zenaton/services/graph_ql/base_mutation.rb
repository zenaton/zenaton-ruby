# frozen_string_literal: true

require 'securerandom'
require 'zenaton/services/properties'
require 'zenaton/services/serializer'

module Zenaton
  module Services
    module GraphQL
      # @abstract Superclass for graphql mutations.
      # It expects two methods to be implemented in children classes:
      # - #body
      # - #raw_query
      class BaseMutation
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
      end
    end
  end
end
