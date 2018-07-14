# frozen_string_literal: true

# rubocop:disable Style/ClassVars
require 'active_support/concern'
require 'zenaton/exceptions'
require 'zenaton/traits/with_duration'

module Zenaton
  module Traits
    module WithTimestamp
      include WithDuration
      extend ActiveSupport::Concern

      MODE_AT = 'AT'
      MODE_WEEK_DAY = 'WEEK_DAY'
      MODE_MONTH_DAY = 'MONTH_DAY'
      MODE_TIMESTAMP = 'TIMESTAMP'

      included do
        @@timezone = nil
      end

      class_methods do
        def timezone=(timezone)
          error = 'Unknown timezone'
          raise ExternalError, error unless valid_timezone?(timezone)
          @@timezone = timezone
        end

        private

        def valid_timezone?(timezone)
          ActiveSupport::TimeZone::MAPPING.value? timezone
        end
      end
    end
  end
end
# rubocop:enable Style/ClassVars
