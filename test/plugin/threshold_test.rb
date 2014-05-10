# -*- coding: utf-8 -*-
require 'rubygems'
require 'minitest/autorun'

require 'nagios/plugin/threshold'

Infinity = 1.0/0

describe Nagios::Plugin::Threshold do
  it "can't be created without arguments" do
    lambda{ Nagios::Plugin::Threshold.new }.must_raise(ArgumentError)
  end

  it "throws a TypeError if passed non-numeric thresholds" do
    lambda { Nagios::Plugin::Threshold.new('ten:twenty') }.must_raise(TypeError)
  end

  it "accepts and parses thresholds correctly" do
    Nagios::Plugin::Threshold.new('10').to_s.must_equal(Range.new(0,10,true).to_s)          # 10 < 0 or > 10, ({0 .. 10})
    Nagios::Plugin::Threshold.new('10:').to_s.must_equal(Range.new(10,Infinity,true).to_s)  # 10: < 10, ({10 .. ∞})
    Nagios::Plugin::Threshold.new('~:10').to_s.must_equal(Range.new(-Infinity,10,true).to_s)# ~:10  > 10, ({-∞ .. 10})
    Nagios::Plugin::Threshold.new('10:20').to_s.must_equal(Range.new(10,20,true).to_s)      # 10:20 < 10 or > 20, ({10 .. 20})
  end

end
