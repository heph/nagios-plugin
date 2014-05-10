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
