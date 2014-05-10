#!/usr/bin/env ruby

require 'rubygems'
require 'sys/filesystem'

lib = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'nagios/plugin'

class CheckRootDiskFree
  include Nagios::Plugin
  def check
    unless @path
      puts "You must specify a -p/--path to check."
      exit 3
    end

    stat = Sys::Filesystem.stat(@path)
    stat.block_size * stat.blocks_available / 1024 / 1024
  end
end

plugin = CheckRootDiskFree.new('check_disk_free',
  '<%= @state.upcase %>: Mountpoint <%= @path %> has <%= @result %>MB free.',
  {:path => ['-p', '--path STRING', 'Disk Path You Want to Check'],
   :warn => ['-w', '--warn THRESHOLD', 'Minimum Disk Free in MB Before Warning'],
   :crit => ['-c', '--crit THRESHOLD', 'Minimum Disk Free in MB Before Critical'] })

puts plugin
exit plugin.code
