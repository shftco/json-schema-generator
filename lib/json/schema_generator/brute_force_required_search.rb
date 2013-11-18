require 'jsonpath'

module JSON
  class SchemaGenerator
    class BruteForceRequiredSearch
      def initialize(data)
        @data = data.dup
        @json_path = ['$']
      end

      def push(key, value)
        if value.is_a? Array
          @json_path.push "#{key}[*]"
        else
          @json_path.push key
        end
      end

      def pop
        @json_path.pop
      end

      def current_path
        @json_path.join '.'
      end

      def search_path search_key
        current_path.gsub(/\[\*\]$/, "[?(@.#{search_key})]")
      end

      def required? child_key
        JsonPath.new(search_path(child_key)).on(@data).count == JsonPath.new(current_path).on(@data).count
      end

      def child_keys 
        JsonPath.new(current_path).on(@data).map(&:keys).flatten.uniq
      end

      def find_required
        required = []
        child_keys.each do |child_key|
          required << child_key if required? child_key
        end
        required
      end
    end
  end
end
