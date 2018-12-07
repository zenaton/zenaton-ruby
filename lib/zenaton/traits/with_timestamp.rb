# frozen_string_literal: true

# rubocop:disable Style/ClassVars
require 'active_support'
require 'zenaton/exceptions'
require 'zenaton/traits/with_duration'

module Zenaton
  module Traits
    # Module to calculate unix timestamps for events
    module WithTimestamp
      include WithDuration
      extend ActiveSupport::Concern

      # Array of weekdays as symbols from ActiveSupport
      WEEKDAYS = DateAndTime::Calculations::DAYS_INTO_WEEK.keys
      MODE_AT = 'AT' # When specifying a time
      MODE_WEEK_DAY = 'WEEK_DAY' # When specifying a day of the week
      MODE_MONTH_DAY = 'MONTH_DAY' # When specifying a day of the month
      MODE_TIMESTAMP = 'TIMESTAMP' # When specifying a unix timestamp

      included do
        @@_timezone = nil
      end

      # Calculates the timestamp based on either timestamp or duration methods
      # @return Array<Integer, NilClass>
      def _get_timestamp_or_duration
        return [nil, nil] unless @buffer

        now, now_dup = _init_now_then
        @_mode = nil
        @buffer.each do |time_unit, time_value|
          now_dup = _apply(time_unit, time_value, now, now_dup)
        end
        return [nil, diff_in_seconds(now, now_dup)] if @_mode.nil?

        [now_dup.to_i, nil]
      end

      %i[
        timestamp at day_of_month monday tuesday wednesday thursday
        friday saturday sunday
      ]. each do |method_name|
        define_method method_name do |value = 1|
          _push(method_name, value)
          self
        end
      end

      private

      # rubocop:disable Metrics/MethodLength
      def _apply(method, value, now, now_dup)
        if WEEKDAYS.include?(method)
          _weekday(value, method, now, now_dup)
        elsif method == :timestamp
          _timestamp(value)
        elsif method == :at
          _at(value, now, now_dup)
        elsif method == :day_of_month
          _day_of_month(value, now, now_dup)
        else
          _apply_duration(method, value, now_dup)
        end
      end
      # rubocop:enable Metrics/MethodLength

      def _weekday(value, day, now, now_dup)
        _set_mode(MODE_WEEK_DAY)
        value -= 1 if later_today?(now, day)
        value.times { |_n| now_dup = now_dup.next_occurring(day) }
        now_dup
      end

      def _timestamp(timestamp)
        _set_mode(MODE_TIMESTAMP)
        timestamp
      end

      def _at(time, now, now_dup)
        _set_mode(MODE_AT)
        now_dup = set_time_from_string(now_dup, time)
        now_dup += delay if now > now_dup
        now_dup
      end

      def delay
        case @_mode
        when MODE_AT
          1.day
        when MODE_WEEK_DAY
          1.week
        when MODE_MONTH_DAY
          1.month
        else
          raise InternalError "Unknown mode: #{@_mode}"
        end
      end

      def _day_of_month(day, now, now_dup)
        _set_mode(MODE_MONTH_DAY)
        now_dup += 1.day until now_dup.mday == day
        now_dup += 1.month if now >= now_dup && !later_today?(now, day)
        now_dup
      end

      def _set_mode(mode)
        error = 'Incompatible definition in Wait methods'
        raise ExternalError,  error if mode == @_mode
        raise ExternalError, error if timestamp_mode_set?(mode)

        @_mode = mode if @_mode.nil? || @_mode == MODE_AT
      end

      def timestamp_mode_set?(mode)
        (!@_mode.nil? && MODE_TIMESTAMP == mode) || (@_mode == MODE_TIMESTAMP)
      end

      def later_today?(now, day)
        today?(now, day) && later?(now)
      end

      def today?(now, day)
        wday = WEEKDAYS[now.wday - 1]
        now.mday == day || wday == day
      end

      def later?(now)
        time = @buffer[:at]
        return false unless time

        now < set_time_from_string(now.dup, time)
      end

      def set_time_from_string(now, string_time)
        hour, min, sec = string_time.split(':').map(&:to_i)
        now.change(hour: hour, min: min, sec: sec || 0)
      end

      class_methods do
        def timezone=(timezone)
          error = 'Unknown timezone'
          raise ExternalError, error unless valid_timezone?(timezone)

          @@_timezone = timezone
        end

        def valid_timezone?(timezone)
          timezone.nil? || ActiveSupport::TimeZone::MAPPING.value?(timezone)
        end
      end
    end
  end
end
# rubocop:enable Style/ClassVars
