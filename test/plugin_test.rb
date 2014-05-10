require 'rubygems'
require 'minitest/autorun'

require 'nagios/plugin'

class NumericPlugin
  include Nagios::Plugin
  def check
    1234
  end
end

class StringPlugin
  include Nagios::Plugin
  def check
    "one two three four"
  end
end

describe Nagios::Plugin do

  it "outputs test data correctly" do
    NumericPlugin.new('numeric_plugin', 'template string: <%= @result %>').to_s.must_equal("template string: 1234")
    StringPlugin.new('string_plugin', 'template string: <%= @result %>').to_s.must_equal("template string: one two three four")
  end

  describe "#validate_numeric" do
    let(:np) { NumericPlugin.new('numeric_plugin') }

    it "sends the correct return code" do
      np.validate_numeric(15, 0...20)
      np.state.must_equal('ok')
      np.code.must_equal(0)

      np.validate_numeric(15, 0...5)
      np.state.must_equal('warning')
      np.code.must_equal(1)

      np.validate_numeric(15, 0...5, 0...5)
      np.state.must_equal('critical')
      np.code.must_equal(2)

      np.validate_numeric("fifteen", 0...10, 0...5)
      np.state.must_equal('unknown')
      np.code.must_equal(3)
    end
  end

  describe "#validate_string" do
    let(:sp) { StringPlugin.new('string_plugin') }

    it "sends the correct return code" do
      sp.validate_string(sp.check, "three")
      sp.state.must_equal('ok')
      sp.code.must_equal(0)

      sp.validate_string(sp.check, "five")
      sp.state.must_equal('critical')
      sp.code.must_equal(2)
    end
  end
end
