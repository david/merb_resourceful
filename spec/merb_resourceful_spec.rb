require File.dirname(__FILE__) + '/spec_helper'

describe "merb_resourceful", "#belongs_to" do
  before :all do
    class YoyoParent; end
    
    class Yoyo; end
    class Yoyos < Merb::Controller
      belongs_to :yoyo_parent
      
      def params
        { :yoyo_parent_id => 1_000_000 }
      end
    end
  end
  
  before do
    @controller = Yoyos.allocate
    @yoyop = mock(YoyoParent)
    YoyoParent.stub!(:get).and_return(@yoyop)
  end
  
  it "renders the resource list" do
    @yoyop.stub!(:yoyos).and_return("yoyos list")
    
    @controller.should_receive(:display).with("yoyos list")
    @controller.index
  end
  
  it "renders a new resource" do
    yoyo = mock(Yoyo)
    
    @yoyop.stub!(:yoyos).and_return(@yoyop)
    @yoyop.stub!(:build).and_return(yoyo)
    
    @controller.should_receive(:display).with(yoyo)
    @controller.new
  end
  
  describe "#create" do
    before do
      @yoyo = mock(Yoyo)
      @yoyop.stub!(:yoyos).and_return(@yoyop)
      @yoyop.should_receive(:build).with("params!").and_return(@yoyo)
    end
    
    it "creates a resource successfully" do
      @yoyo.stub!(:save).and_return(true)
      
      @controller.should_receive(:resource).with(@yoyop, :yoyos).and_return("route")
      @controller.should_receive(:redirect).with("route", :message => { :notice => "Yoyo created successfully." })
      @controller.create("params!")
    end
    
    it "fails to create a resource" do
      pending do
        @yoyo.stub!(:save).and_return(false)
        
        @controller.create("params!")
      end
    end
  end
  
  describe "#update" do
    before do
      @yoyo = mock(Yoyo)
      @yoyop.stub!(:yoyos).and_return(@yoyop)
      @yoyop.should_receive(:get).with("id!").and_return(@yoyo)
    end
    
    it "updates a resource successfully" do
      @yoyo.should_receive(:update_attributes).with("params!").and_return(true)
      
      @controller.should_receive(:resource).with(@yoyop, :yoyos).and_return("route")
      @controller.should_receive(:redirect).with("route", :message => { :notice => "Yoyo updated successfully." })
      @controller.update("id!", "params!")
    end
    
    it "fails to update a resource" do
      pending do
        @yoyo.stub!(:update_attributes).and_return(false)
        
        @controller.update("id!", "params!")
      end
    end
  end
end
