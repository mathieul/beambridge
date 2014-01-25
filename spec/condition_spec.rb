require "spec_helper"

describe "Beambridge::StaticConditions" do
  it "should satisfy on the same value" do
    Beambridge::StaticCondition.new(:foo).satisfies?(:foo).should == true
    Beambridge::StaticCondition.new([:foo]).satisfies?([:foo]).should == true
    Beambridge::StaticCondition.new(3).satisfies?(3).should == true
  end

  it "should not satisfy on different values" do
    Beambridge::StaticCondition.new(:foo).satisfies?("foo").should == false
    Beambridge::StaticCondition.new([:foo]).satisfies?(:foo).should == false
    Beambridge::StaticCondition.new(Object.new).satisfies?(Object.new).should == false
    Beambridge::StaticCondition.new(3).satisfies?(3.0).should == false
  end

  it "should not produce any bindings" do
    s = Beambridge::StaticCondition.new(:foo)
    s.binding_for(:foo).should == nil
  end
end

describe "Beambridge::TypeConditions" do
  it "should be satisfied when the arg has the same class" do
    Beambridge::TypeCondition.new(Symbol).satisfies?(:foo).should == true
    Beambridge::TypeCondition.new(Symbol).satisfies?(:bar).should == true
    Beambridge::TypeCondition.new(String).satisfies?("foo").should == true
    Beambridge::TypeCondition.new(String).satisfies?("bar").should == true
    Beambridge::TypeCondition.new(Array).satisfies?([]).should == true
    Beambridge::TypeCondition.new(Fixnum).satisfies?(3).should == true
  end

  it "should be satisfied when the arg is of a descendent class" do
    Beambridge::TypeCondition.new(Object).satisfies?(:foo).should == true
    Beambridge::TypeCondition.new(Object).satisfies?("foo").should == true
    Beambridge::TypeCondition.new(Object).satisfies?(3).should == true
  end

  it "should not be satisfied when the arg is of a different class" do
    Beambridge::TypeCondition.new(String).satisfies?(:foo).should == false
    Beambridge::TypeCondition.new(Symbol).satisfies?("foo").should == false
    Beambridge::TypeCondition.new(Fixnum).satisfies?(3.0).should == false
  end

  it "should bind the arg with no transormations" do
    s = Beambridge::TypeCondition.new(Symbol)
    s.binding_for(:foo).should == :foo
    s.binding_for(:bar).should == :bar
  end
end

describe "Beambridge::HashConditions" do
  it "should satisfy an args of the form [[key, value], [key, value]]" do
    Beambridge::HashCondition.new.satisfies?([[:foo, 3], [:bar, Object.new]]).should == true
    Beambridge::HashCondition.new.satisfies?([[:foo, 3]]).should == true
  end

  it "should satisfy on empty arrays" do
    Beambridge::HashCondition.new.satisfies?([]).should == true
  end

  it "should nat satisfy other args" do
     Beambridge::HashCondition.new.satisfies?(:foo).should == false
     Beambridge::HashCondition.new.satisfies?("foo").should == false
     Beambridge::HashCondition.new.satisfies?(3.0).should == false
  end

  it "should bind to a Hash" do
    s = Beambridge::HashCondition.new()
    s.binding_for([[:foo, 3], [:bar, [3,4,5]]]).should == {:foo => 3, :bar => [3,4,5] }
  end
end
