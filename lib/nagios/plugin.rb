require 'optparse'
require 'erb'
require 'nagios/plugin/version'
require 'nagios/plugin/threshold'

module Nagios
  module Plugin
    @state = 0
    @template = ''
    @arguments = {
      :expect => ['-e', '--expect STRING', 'Return Critical Unless Output Matches STRING'],
      :crit   => ['-c', '--crit THRESHOLD', 'Critical Threshold'],
      :warn   => ['-w', '--warn THRESHOLD', 'Warning Threshold']  } 

    def state # :nodoc: read_accessor for nagios state: %q{ok warning critical unknown}
      @state
    end

    def code # :nodoc: read_accessor for the nagios status code: [0,1,2,3]
      @code
    end

    def result # :nodoc: read_accessor for the plugin result 
      @result
    end

    def to_s # :nodoc: renders plugin output through the ERB template
      @output
    end

    def description # :nodoc: read_accessor for the plugin description
      @description
    end

    # Create a new Nagios::Plugin
    #  
    # ==== Attributes  
    #  
    # * +description+ - A short description for the plugin ("check_https_health", "Ted's Plugin", etc.)
    # * +template+    - An ERB Template for Plugin Output
    # * +arguments+   - Additional command line options your plugin should accept.
    #
    # ==== Arguments
    # Takes a hash in the form of:
    #
    #     arguments = { :variable => ['-f', '--flag STRING', 'Description of Flag'] }
    #
    # If that flag is seen, the instance variable named @variable will be assigned its value. If the second field contains
    # the string 'THRESHOLD', it will parse the value as a Nagios::Plugin::Threshold object instead of a String. The arguments
    # in the array of flags are passed to OptionParser.on(*args).
    #  
    # ==== Examples  
    #
    #    MyPlugin.new('My Plugin',
    #                 '<%= @description %> is <%= state.upcase %>: <%= @result %>',
    #                 { :expect => ['-e', '--expect STRING', 'Return Critical Unless Output Matches STRING'] })
    #
    def initialize(description, template='', arguments=@arguments)
      @description = description
      @template = template || '<%= @state.upcase %>: <%= @description %> <%= @result %>'
      get_args(arguments)
      @result = check
      @state = validate(@result)
    end

    # This should be overridden with your custom check validator, or it can
    # reference a built-in validator (such as validate_numeric() or validate_string())
    # By default, this passes all arguments through to validate_numeric().
    #
    # ==== Example
    #
    # To create a new validator:
    #
    #    def validate(check_output)
    #      lock_mtime = check_output
    #      conf_mtime = @date
    #      if lock_mtime > conf_mtime
    #        return status(:ok, "Lock file is newer (#{lock_mtime}) than config file (#{conf_mtime})."
    #      else
    #        return status(:critical, "Config is newer (#{conf_mtime}) than lock file (#{lock_mtime}). Restart The Service!")
    #      end
    #    end
    #
    def validate(output)
      validate_numeric(output, @warn, @crit)
    end

    # ==== Built-In Validator for Strings
    # Compare a string to a case-insensetive regular expression. If the input
    # string matches, returns ok. Otherwise, returns critical.
    def validate_string(str, match='')
      if str =~ /#{match}/i
        return status(:ok, str)
      else
        return status(:critical, "#{str} does not match /#{match}/i")
      end
    end

    # ==== Built-In Validator for Numerics
    # Compare a numeric result to the warning and critical ranges. Returns the
    # appropriate status code on a match. Returns unknown if given non-numeric input.
    def validate_numeric(num, warn=0, crit=0)
      if num.to_i.to_s == num
        num = num.to_i
      elsif num.to_f.to_s == num
        num = num.to_f
      end

      if num.is_a?(Numeric) # we have a numerical num, compare to warn and crit thresholds
        if crit.is_a?(Range)
          unless(crit.include?(num))
            return status(:critical, num)
          end
        end

        if warn.is_a?(Range)
          unless(warn.include?(num))
            return status(:warning, num)
          end
        end

        return status(:ok, num)
      else
        return status(:unknown, num)
      end
    end

    # This should be overridden by your custom check method. Your check should
    # return in a way that can be passed to your validate() method.
    #  
    # ==== Examples  
    #   
    # To create a new nagios check:  
    #
    #    require 'sys/filesystem'
    #    class CheckRootDiskFree
    #      include Nagios::Plugin
    #      def check
    #        stat = Sys::Filesystem.stat("/")
    #        stat.block_size * stat.blocks_available / 1024 / 1024
    #      end
    #    end
    #    
    #    plugin = CheckRootDiskFree.new("check_root_disk_free")
    #    
    #    puts plugin
    #    exit plugin.code
    #
    # Your check method will have its output passed directly to the validate() method,
    # which by default passes through to validate_numeric().
    def check
      return status(:warning, "override this check definition")
    end

    private

    # Internal method for returning the exit code and templated output for the plugin.
    def status(code, out, template=@template)
      @state  = code.to_s
      @result = out.to_s
      codes   = [:ok, :warning, :critical, :unknown]

      @output = ERB.new(template, 0, '-').result(binding)
      @code  = codes.index(code) || codes.index(:unknown)
      return @code
    end

    # Collect command line arguments into instance variables.
    def get_args(arguments)
      OptionParser.new do |opts|
        if arguments # Allow users to add their own arguments by passing a hash of arrays
          arguments.each do |var_name,flags|
            opts.on(*flags) do |value|
              if flags[1] and flags[1] =~ /THRESHOLD/i
                instance_variable_set("@#{var_name}", Nagios::Plugin::Threshold.new(value)) unless value.nil?
              else
                instance_variable_set("@#{var_name}", value) unless value.nil?
              end
            end
          end
        end

       opts.on('-h', '--help', 'Display this help.') do
          puts "#{opts}"
          exit(3)
        end

        begin
          opts.parse!
        rescue => e
          puts "#{e}\n\n#{opts}"
          exit(3)
        end
       end
    end
  end
end
