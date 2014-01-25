require "spec_helper"

describe "When unpacking from a binary stream" do

  it "an erlang atom should decode to a ruby symbol" do
    get("haha").should == :haha
  end

  it "an erlang number encoded as a small_int (< 255) should decode to a fixnum" do
    get("0").should == 0
    get("255").should == 255
  end

  it "an erlang number encoded as a int (signed 27-bit number) should decode to a fixnum" do
    get("256").should == 256
    get("#{(1 << 27) -1}").should == (1 << 27) -1
    get("-1").should == -1
    get("#{-(1 << 27)}").should == -(1 << 27)
  end

  it "an erlang number encoded as a small bignum (1 byte length) should decode to fixnum if it can" do
    get("#{(1 << 27)}").should == (1 << 27)
    get("#{-(1 << 27) - 1}").should == -(1 << 27) - 1
    get("#{(1 << word_length) - 1}").should == (1 << word_length) - 1
    get("#{-(1 << word_length)}").should == -(1 << word_length)
  end

  it "an erlang number encoded as a small bignum (1 byte length) should decode to bignum if it can't be a fixnum" do
    get("#{(1 << word_length)}").should == (1 << word_length)
    get("#{-(1 << word_length) - 1}").should == -(1 << word_length) - 1
    get("#{(1 << (255 * 8)) - 1}").should == (1 << (255 * 8)) - 1
    get("#{-((1 << (255 * 8)) - 1)}").should == -((1 << (255 * 8)) - 1)
  end

  it "an erlang number encoded as a big bignum (4 byte length) should decode to bignum" do
    get("#{(1 << (255 * 8)) }").should == (1 << (255 * 8))
    get("#{-(1 << (255 * 8))}").should == -(1 << (255 * 8))
    get("#{(1 << (512 * 8)) }").should == (1 << (512 * 8))
    get("#{-(1 << (512 * 8))}").should == -(1 << (512 * 8))
  end

  it "an erlang float should decode to a Float" do
    get("#{1.0}").should == 1.0
    get("#{-1.0}").should == -1.0
    get("#{123.456}").should == 123.456
    get("#{123.456789012345}").should == 123.456789012345
  end

  it "an erlang reference should decode to a Reference object" do
    ref = get("make_ref()")
    ref.should be_an_instance_of Beambridge::NewReference
    ref.node.should be_an_instance_of Symbol
  end

  it "an erlang pid should decode to a Pid object" do
    pid = get("spawn(fun() -> 3 end)")
    pid.should be_an_instance_of Beambridge::Pid
    pid.node.should be_an_instance_of Symbol
  end

  it "an erlang tuple encoded as a small tuple (1-byte length) should decode to an array" do
    ref = get("{3}")
    ref.length.should == 1
    ref.first.should == 3

    ref = get("{3, a, make_ref()}")
    ref.length.should == 3
    ref[0].should == 3
    ref[1].should == :a
    ref[2].class.should == Beambridge::NewReference

    tuple_meat = (['3'] * 255).join(', ')
    ref = get("{#{tuple_meat}}")
    ref.length.should == 255
    ref.each{|r| r.should == 3}
  end

  it "an erlang tuple encoded as a large tuple (4-byte length) should decode to an array" do
    tuple_meat = (['3'] * 256).join(', ')
    ref = get("{#{tuple_meat}}")
    ref.length.should == 256
    ref.each{|r| r.should == 3}

    tuple_meat = (['3'] * 512).join(', ')
    ref = get("{#{tuple_meat}}")
    ref.length.should == 512
    ref.each{|r| r.should == 3}
  end

  it "an empty erlang list encoded as a nil should decode to an array" do
    get("[]").class.should == Erl::List
    get("[]").should == []
  end

  it "an erlang list encoded as a string should decode to an array of bytes (less than ideal, but consistent)" do
    get("\"asdasd\"").class.should == Erl::List
    get("\"asdasd\"").should == "asdasd".bytes.to_a
    get("\"#{'a' * 65534}\"").should == "a".bytes.to_a * 65534
  end

  it "an erlang list encoded as a list should decode to an erl::list" do
    get("[3,4,256]").class.should == Erl::List
    get("[3,4,256]").should == [3,4,256]
    get("\"#{'a' * 65535 }\"").should == [97] * 65535
    get("[3,4, foo, {3,4,5,bar}, 256]").should == [3,4, :foo, [3,4,5,:bar], 256]
  end

  it "an erlang binary should decode to a string" do
    get("<< 3,4,255 >>").should == "\003\004\377"
    get("<< \"whatup\" >>").should == "whatup"
    get("<< 99,0,99 >>").should == "c\000c"
  end

  it "the empty atom should decode to the empty symbol" do
    empty_symbol = get("''")
    empty_symbol.should be_an_instance_of Symbol
    empty_symbol.to_s.should == ""
  end

  it "erlang atomic booleans should decode to ruby booleans" do
    get("true").should == true
    get("false").should == false
    get("falsereio").should == :falsereio
    get("t").should == :t
    get("f").should == :f
  end

  it "massive binaries should not overflow the stack" do
    bin = [131,109,0,128,0,0].pack('c*') + ('a' * (8 * 1024 * 1024))
    Beambridge::Decoder.decode(bin).size.should eq(8 * 1024 * 1024)
  end

  it "a good thing should be awesome" do
    get(%Q-[{options,{struct,[{test,<<"I'm chargin' mah lazer">>}]}},{passage,<<"Why doesn't this work?">>}]-).should ==
    [[:options, [:struct, [[:test, "I'm chargin' mah lazer"]]]], [:passage, "Why doesn't this work?"]]
  end

  def get(str)
    x = "term_to_binary(#{str.gsub(/"/, '\\\"')})"
    bin = run_erl(x)
    Beambridge::Decoder.decode(bin)
  end
end
