require "bundler/setup"

require "stringio"
require "pry"
require "beambridge"

$stdout.sync = true

module BeambridgeTestHelpers
  def run_erl(code)
    %x{erl -noshell -eval "A = #{code.split.join(' ')}, io:put_chars(binary_to_list(A))." -s erlang halt}
  end

  def encode_packet(code)
    bin = run_erl("term_to_binary(#{code})")
    [bin.length, bin].pack("Na#{bin.length}")
  end

  def word_length
    (1.size * 8) - 2
  end
end

class FakePort < Beambridge::Port
  attr_reader :sent
  attr_reader :terms

  def initialize(*terms)
    @terms = terms
    @sent = []
    super(StringIO.new(""), StringIO.new(""))
  end

  def send(term)
    sent << term
  end

  private

  def read_from_input
    @terms.shift
  end
end

RSpec.configure do |config|
  config.include BeambridgeTestHelpers
end
