# Nagios::Plugin

Nagios::Plugin is a helper library for writing Nagios Plugins.
It takes care of most of the work of accepting arguments, parsing
nagios thresholds, comparing output, and returing the correct status.

## Installation

    $ gem install nagios-plugin

## Usage

The boilerplate for writing a nagios check with this plugin is very small:

  * Include Nagios::Plugin in your plugin class.
  * Override the check method to output your check data.
  * (optional) Override the validate method for your check's data.
  * Create a new instance of your plugin class.
  * Print the plugin output.
  * Exit with the plugin's return code.

Example:

    #!/usr/bin/env ruby
    require 'sys/filesystem'
    require 'nagios/plugin'

    class CheckRootDiskFree
      include Nagios::Plugin
      def check
        stat = Sys::Filesystem.stat("/")
        stat.block_size * stat.blocks_available / 1024 / 1024
      end
    end

    plugin = CheckRootDiskFree.new("check_root_disk_free")

    puts plugin
    exit plugin.code

## Validators

The default behavior is to validate that the output of the check() method is
numeric, and within the range of the warning and critical thresholds (-w and
-c command line arguments).

You can override this behavior to use the built-in string validator instead:

    #!/usr/bin/env ruby
    require 'nagios/plugin'

    class CheckRubyVersion
      include Nagios::Plugin
      def check
        RUBY_VERSION
      end
      def validate(check_output)
        validate_string(check_output, @expect)
      end
    end

    arguments = { :expect => ['-e', '--expect STRING', 'Return Critical Unless Output Matches STRING'] }

    plugin = CheckRubyVersion.new("check_ruby_version", nil, arguments)

    puts plugin
    exit plugin.code

Or you can write your own validator method:

    def validate(check_output)
      data = JSON.parse(check_output)
      if data['status'] && data['status'].downcase == 'ok'
        return status(:ok, "JSON Check Output returned OK!")
      else
        return status(:critical, check_output)
      end
    end

## Arguments

If your plugin requires command-line arguments other than -w (warning) or -c (critical), you can
pass them into your Plugin initializer as a hash of arrays:

    arguments = { :expect => ['-e', '--expect STRING', 'Return Critical Unless Output Matches STRING'] }
    plugin = CheckRubyVersion.new("check_ruby_version", nil, arguments)

The name of the array (in this case, :expect) will be turned into an instance variable containing
the argument given to the specified flags. In this case, it sets @expect to whatever the user
passes to that option.

### Thresholds

If the second element of the array ('--expect STRING' in our example) contained the word THRESHOLD instead,
the plugin would attempt to parse any aruments given as a Nagios::Plugin::Threshold object instead. For example:

    MyPlugin.new("my plugin", nil, { :between => ['-b', '--between THRESHOLD'] })

This will add a '-b' flag to the plugin, whose argument would be interpreted as a Threshold, and be available
in the instance variable @between.

Nagios thresholds can be used to determine if a plugin's output should trigger an alert. For example:

    def check_threshold
      crit_threshold = Nagios::Plugin::Threshold.new('15')
      warn_threshold = Nagios::Plugin::Threshold.new('10')
      check_output   = 5

      if crit_threshold.include?(check_output)
        return 2
      elsif warn_threshold.include?(check_output)
        return 1
      else
        return 0
      end
    end

## Templating

If you want to override the default template used for formatting the check output, pass a new ERB template
as the second argument to the Plugin constructor. The default template format is:

    <%= @state.upcase %>: <%= @description %> <%= @result %>

To override:

    MyPlugin.new('my plugin', 'MY PLUGIN: <%= @state.upcase %> - <%= @result %>')

Key Variables:

  * @state - The Literal State of the Check, one of: ok, warning, critical, unknown.
  * @description - The plugin's name (first argument of MyPlugin.new())
  * @result - The output of your check method

You can also use any variable you make available within your plugin class.

## Contributors

  * Stephen Koenig
  * Jonathan Lassoff
  * David Golombek
