# frozen_string_literal: true

require 'fugit'
require 'active_support/concern'

module Zenaton
  # Reusable modules from the Zenaton library
  module Traits
    # Module included in tasks and workflows
    module Repeatable
      extend ActiveSupport::Concern

      # Sets a repeatable frequency using cron notation
      # @param cron_expression [String]
      def repeat(cron_expression)
        Fugit::Cron.do_parse(cron_expression)
        @scheduling = { cron: cron_expression }
        self
      rescue ArgumentError
        message = <<~TXT
          Could not parse `#{cron_expression}'.
          Make sure it is a valid cron string.
        TXT
        @scheduling = { cron: nil }
        raise InvalidArgumentError, message
      end

      # Checks if a repeatable schedule has been set.
      def repeatable?
        cron
      end

      # Returns the cron expression if any.
      def cron
        @scheduling && @scheduling[:cron]
      end
    end
  end
end
