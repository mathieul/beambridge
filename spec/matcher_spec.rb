require "spec_helper"

def false_match(matcher, arg)
   matcher.matches?(arg).should == false
end

describe "A matcher whose condition is a String (the class object" do
  before(:each) do
    @matcher = Beambridge::Matcher.new(nil, Beambridge::TypeCondition.new(String), nil)
  end

  it "should match any string" do
    @matcher.matches?("foo").should == true
  end

  it "should not match symbols" do
    @matcher.matches?(:foo).should == false
  end
end

describe "A matcher whose condition is Symbol (the class object)" do
  before(:each) do
    @matcher = Beambridge::Matcher.new(nil, Beambridge::TypeCondition.new(Symbol), nil)
  end

  it "should match any symbol" do
    @matcher.matches?(:foo).should == true
    @matcher.matches?(:bar).should == true
    @matcher.matches?(:baz).should == true
  end

  it "should not match strings" do
    @matcher.matches?("foo").should == false
    @matcher.matches?("bar").should == false
    @matcher.matches?("baz").should == false
  end

  it "should not match a arrays" do
    @matcher.matches?([:foo]).should == false
    @matcher.matches?([:foo, :bar]).should == false
    @matcher.matches?([:foo, :bar, :baz]).should == false
  end
end

describe "a matcher whose condition is a symbol" do
  before(:each) do
    @matcher = Beambridge::Matcher.new(nil, Beambridge::StaticCondition.new(:foo), nil)
  end

  it "should match that symbol" do
    @matcher.matches?(:foo).should == true
  end

  it "should not match any other symbol" do
    @matcher.matches?(:bar).should == false
    @matcher.matches?(:baz).should == false
  end
end

describe "a matcher whose matcher is an array" do

  it "should match if all of its children match" do
    Beambridge::Matcher.new(nil, [Beambridge::StaticCondition.new(:speak), Beambridge::TypeCondition.new(Object)], nil).matches?([:paste, "haha"]).should == false

    matcher = Beambridge::Matcher.new(nil, [Beambridge::StaticCondition.new(:foo), Beambridge::StaticCondition.new(:bar)], nil)
    matcher.matches?([:foo, :bar]).should == true
  end

  it "should not match any of its children dont match" do
    matcher = Beambridge::Matcher.new(nil, [Beambridge::StaticCondition.new(:foo), Beambridge::StaticCondition.new(:bar)], nil)
    matcher.matches?([:foo]).should == false
    matcher.matches?([:foo, :bar, :baz]).should == false
    matcher.matches?([:fooo, :barr]).should == false
    matcher.matches?([3, :bar]).should == false
  end

  it "should not match if arg isn't an array" do
    matcher = Beambridge::Matcher.new(nil, [Beambridge::StaticCondition.new(:foo), Beambridge::StaticCondition.new(:bar)], nil)
    matcher.matches?(:foo).should == false
  end
end
