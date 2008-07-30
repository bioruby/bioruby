require 'delegate'

module Bio
  class CodeML
    class Rates < DelegateClass(Array)

      def initialize(rates)
        super(parse_rates(rates))
      end

      private

      def parse_rates(text)
        re = /\s+(\d+)\s+(\d+)\s+([A-Z]+)\s+(\d+\.\d+)\s+(\d)/
        array = Array.new
        text.each do |line|
          if re =~ line
            match = Regexp.last_match
            array[match[1].to_i] = {
              :freq => match[2].to_i, 
              :data => match[3], 
              :rate => match[4].to_f }
          end
        end
        array
      end

    end
  end
end
