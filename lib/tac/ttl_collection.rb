# frozen_string_literal: true

module TAC
  module Models
    class TTLCollection
      def initialize(ttl = 60)
        @ttl = ttl
        @timestamps = {}
      end

      def <<(value)
        # record the current value
        @timestamps[value] = Time.now

        # expire anything past its TTL
        expire_values!

        # return the number of values in the collection
        @timestamps.length
      end

      def values
        # expire anything past its TTL
        expire_values!

        # return the values still in the collection
        @timestamps.keys
      end

      private

      def expire_values!
        # discard values older than TTL
        @timestamps.reject! { |_, time| time < Time.now - @ttl }
      end
    end
  end
end
