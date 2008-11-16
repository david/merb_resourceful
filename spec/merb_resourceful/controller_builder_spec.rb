require File.dirname(__FILE__) + '/../spec_helper'

describe "resourceful", :shared => true do
  %w(index show new create edit update destroy).each do |action|
    it "creates ##{action}" do
      if action == 'destroy'
        pending
      else
        @controller.should respond_to(action)
      end
    end
  end
  
  describe "showing" do
    before do
      @one = create_resource({:name => "one"}, @parent)
      @two = create_resource({:name => "two"}, @parent)
    end
    
    after do
      delete_resource(@one, @parent)
      delete_resource(@two, @parent)
    end
    
    it "a list" do
      @controller.index.should include(@one, @two)
    end
    
    it "a resource" do
      @controller.show(@one.id).should == @one
    end
  end
  
  describe "creating" do
    after do
      delete_resource({:name => "create resource"}, @parent)
    end

    it "renders the form" do
      @controller.new.should be_new_record
    end
    
    it "creates the resource" do
      @controller.create(:name => "create resource").should == "resource created"
      find_resource({:name => "create resource"}, @parent).should_not be_nil
    end
    
    it "fails to create the resource" do
      pending
      # build the resource
      # save the resource
      # fail
    end
  end
  
  describe "updating" do
    before do
      @resource = create_resource({:name => "before update"}, @parent)
    end
    
    after do
      delete_resource(@resource, @parent)
    end
    
    it "renders the form" do
      @controller.edit(@resource.id).should == @resource
    end
    
    it "updates the resource" do
      @controller.update(@resource.id, :name => "update resource").should == "resource updated"
      find_resource({:id => @resource.id}, @parent).name.should == "update resource"
    end
    
    it "fails to update the resource" do
      pending
      # build the resource
      # save the resource
      # fail
    end
  end
end

describe "controller builder", "with per action parents" do
  before :all do
    class Whatever < Merb::Controller
      resourceful do
        %w(index show new create edit update destroy).each do |action|
          send action, :parent => lambda { action }
        end
      end
    end

    @controller = Whatever.allocate
  end

  %w(index show new create edit update destroy).each do |action|
    it "uses action-specific parent #{action}" do
      if action == "destroy"
        pending
      else
        action.class.class_eval do
          define_method :whatever do
            action
          end
        end
      end

      @controller.send("get_source_for_#{action}").should == action
    end
  end
end
