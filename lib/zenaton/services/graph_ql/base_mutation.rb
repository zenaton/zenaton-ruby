# frozen_string_literal: true

require 'zenaton/services/properties'
require 'zenaton/services/serializer'

module Zenaton
  module Services
    module GraphQL
      class BaseMutation
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
      end
    end
  end
end
