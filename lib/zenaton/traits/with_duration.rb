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
          _push(method_name, value)
          self
        end
      end

      private

      def _init_now_then
        Time.zone = self.class.class_variable_get(:@@_timezone) || 'UTC'
        now = Time.zone.now
        Time.zone = nil # Resets time zone
        [now, now.dup]
      end

      def _push(method_name, value)
        @buffer ||= {}
        @buffer[method_name] = value
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
