require "spec_helper"

def simple_receiver_and_port(*terms, &block)
  port = FakePort.new(*terms)
  receiver = if block
      Beambridge::Receiver.new(port, &block)
    else
      Beambridge::Receiver.new(port) do |f|
        f.when Erl.any do
          :matched
        end
      end
    end
end

describe "When a receiver is passed a message that matches two match blocks it" do
  before(:each) do
    @port = FakePort.new([:foo, :foo])
    @receiver = Beambridge::Receiver.new(@port) do |f|
      f.when([:foo, :foo]) do
        :first
      end

      f.when([:foo, Erl.any]) do
        :second
      end
    end
  end

  it "should run the first matching receiver's block" do
    @receiver.run.should == :first
  end
end

describe "A receiver" do
  it "should return the result of the match block when finished" do
    simple_receiver_and_port(:foo).run.should == :matched
    simple_receiver_and_port(:bar).run.should == :matched
    simple_receiver_and_port(:bar, :baz).run.should == :matched
  end

  it "should process another message if the matched block returns the results of receive_loop" do
    recv = simple_receiver_and_port(:foo, :bar, :baz) do |f|
      f.when(:bar) {  }
      f.when(Erl.any) { f.receive_loop }
    end

    recv.run
    recv.port.terms.should == [:baz]
  end

  it "should properly nest" do
    @port = FakePort.new(:foo, :bar, :baz)
    @receiver = Beambridge::Receiver.new(@port) do |f|
      f.when(:foo) do
        f.receive do |g|
          g.when(:bar){ :ok }
        end
        f.receive_loop
      end

      f.when(:baz) do
        :done
      end
    end

    @receiver.run.should == :done
    @port.terms.should == []
  end

  it "should queue up skipped results and restore them when a match happens" do
    @port = FakePort.new(:foo, :baz, :bar)
    @receiver = Beambridge::Receiver.new(@port) do |f|
      f.when(:foo) do
        f.receive do |g|
          g.when(:bar){ :ok }
        end
        f.receive_loop
      end

      f.when(:baz) do
        :done
      end
    end

    @receiver.run.should == :done
    @port.terms.should == []
  end

  it "should expose bindings to the matched block" do
    @port = FakePort.new(:foo, :bar, :baz)
    results = []
    @receiver = Beambridge::Receiver.new(@port) do |f|
      f.when(Erl.atom) do |bindinated|
        results << bindinated
        f.receive_loop
      end
    end

    @receiver.run.should == nil
    results.should == [:foo, :bar, :baz]
  end
end
