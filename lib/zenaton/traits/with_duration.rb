# frozen_string_literal: true

require 'active_support/time'

module Zenaton
  module Traits
    # Module to calculate duration between events
    module WithDuration
      # @return [Integer, NilClass] Duration in seconds
      def _get_duration
        return unless @buffer
        now, now_dup = _init_now_then
        @buffer.each do |time_unit, time_value|
          now_dup = _apply_duration(time_unit, time_value, now_dup)
        end
        diff_in_seconds(now, now_dup)
      end

      %i[seconds minutes hours days weeks months years].each do |method_name|
        define_method method_name do |value = 1|
          @buffer ||= {}
          @buffer[method_name] = value
          self
        end
      end

      private

      def _init_now_then
        time_zone = respond_to?(:_timezone) ? _timezone : 'UTC'
        Time.zone = time_zone
        now = Time.zone.now # This returns time in UTC
        Time.zone = nil # Resets time zone
        [now, now.dup]
      end

      def _apply_duration(time_unit, time_value, time)
        time + time_value.send(time_unit)
      end

      def diff_in_seconds(before, after)
        (after - before).to_i
      end
    end
  end
end
