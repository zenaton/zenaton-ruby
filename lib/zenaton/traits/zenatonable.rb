# frozen_string_literal: true

require 'zenaton/engine'

module Zenaton
  module Traits
    module Zenatonable
      def execute
        Engine.instance.execute([self])[0]
      end

      def dispatch
        Engine.instance.dispatch([self])[0]
      end
    end
  end
end
