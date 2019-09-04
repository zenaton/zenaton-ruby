# frozen_string_literal: true

require 'securerandom'
require 'zenaton/services/properties'
require 'zenaton/services/serializer'

module Zenaton
  module Services
    module GraphQL
      class BaseQuery
        def initialize(*)
          @serializer = Services::Serializer.new
          @properties = Services::Properties.new
        end

        def body
          raise NotImplemented
        end

        def raw_query
          raise NotImplemented
        end

        def query
          raw_query.gsub(/\s+/, ' ')
        end

        def intent_id
          SecureRandom.uuid
        end
      end
    end
  end
end
