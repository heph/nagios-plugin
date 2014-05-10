module Nagios
  module Plugin
    class Threshold < Range

      # Constant for Infinity, (dividing a float by zero). Used for ranges such as '10:' (10...Infinity) or '~:10' (-Infinity...10).
      Infinity = 1.0/0.0

      # Construct a new Threshold. Parses the nagios threshold format and returns a ruby Range object.
      #
      #   +-----------+------------------------------------------------+
      #   | Threshold |            Generate an alert if x...           |
      #   +-----------+------------------------------------------------+
      #   |    '10'   | < 0 or > 10, (outside the range of {0 .. 10})  |
      #   |    '10:'  | < 10, (outside {10 .. Infinity})               |
      #   |   '~:10'  | < 10, (outside the range of {-Infinity .. 10}) |
      #   |   '10:20' | < 10 or > 20, (outside the range of {10 .. 20})|
      #   +-----------+------------------------------------------------+
      # ==== Example:
      #
      #   def check_threshold
      #     crit_threshold = Nagios::Plugin::Threshold.new('15')
      #     warn_threshold = Nagios::Plugin::Threshold.new('10')
      #     check_output   = 5
      #
      #     if crit_threshold.include?(check_output)
      #       return 2
      #     elsif warn_threshold.include?(check_output)
      #       return 1
      #     else
      #       return 0
      #     end
      #   end
      def initialize(t)

        # Silly workaround to avoid Shell Expansion of infinity (~) as $HOME
        begin
          homedir = File.expand_path('~')
        rescue
          homedir = '~'
        end

        unless t.include? ':'
          t = ":#{t}"
        end
        @low, @high = t.split(':').map do |v|
          if v.to_i.to_s == v
            v.to_i
          elsif v.to_f.to_s == v
            v.to_f
          elsif (v == '~' || v == homedir)
            v = Infinity
          elsif v.empty?
            v = 0
          else
            raise TypeError, "Threshold '#{t}' value '#{v}' must be an Integer or Float"
          end
        end


        if @low == Infinity
          @low = -Infinity
        end

        unless @high.is_a?(Numeric)
          @high = Infinity
        end

        super(@low, @high, true)
      end
    end
  end
end
