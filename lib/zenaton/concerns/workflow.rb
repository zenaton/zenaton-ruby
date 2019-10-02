# frozen_string_literal: true

require 'active_support/concern'
require 'zenaton/workflows/version'
require 'zenaton/exceptions'

module Zenaton
  # Composable modules available for reuse
  module Concerns
    # Utility methods for classes that interact with workflows
    # Requires an instance variable @workflow to work
    module Workflow
      extend ActiveSupport::Concern

      MAX_ID_SIZE = 256 # Maximum length for custom ids

      private

      # Determines the name of the workflow
      def workflow_name
        if @workflow.is_a? Workflows::Version
          @workflow.current_implementation.class.name
        else
          @workflow.class.name
        end
      end

      # Validation for the return value of the [#id] method
      def validate_custom_id
        return unless @workflow.try(:id).present?

        validate_custom_id_type
        validate_custom_id_value
      end

      # Only allow String and Integers as custom IDs
      def validate_custom_id_type
        valid_types = [String, Integer]
        return if valid_types.any? { |type| @workflow.id.is_a?(type) }

        raise InvalidArgumentError,
              'Provided ID must be a string or an integer' \
      end

      # Enforce maximum size on custom IDs
      def validate_custom_id_value
        return if @workflow.id.to_s.length <= MAX_ID_SIZE

        raise InvalidArgumentError,
              "Provided Id must not exceed #{MAX_ID_SIZE} bytes"
      end
    end
  end
end
