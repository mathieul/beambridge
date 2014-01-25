require "spec_helper"

describe "A port" do
  it "should return terms from the queue if it is not empty" do
    port = FakePort.new()
    port.queue.clear
    port.queue << :foo << :bar
    port.receive.should == :foo
    port.receive.should == :bar
    port.receive.should == nil
  end

  it "should read_from_input if the queue gets empty" do
    port = FakePort.new(:bar)
    port.queue.clear
    port.queue << :foo
    port.receive.should == :foo
    port.receive.should == :bar
    port.receive.should == nil
  end

  it "should put the terms in skipped at the front of queue when restore_skipped is called" do
    port = FakePort.new(:baz)
    port.queue.clear
    port.queue << :bar
    port.skipped << :foo
    port.restore_skipped

    port.receive.should == :foo
    port.receive.should == :bar
    port.receive.should == :baz
    port.receive.should == nil
  end
end
