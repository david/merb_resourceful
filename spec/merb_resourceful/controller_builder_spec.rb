require File.dirname(__FILE__) + '/../spec_helper'

describe "resourceful", :shared => true do
  before :all do
    @resourceful_opts = {}

    class TestResources < Merb::AbstractController
      include Merb::Plugins::Resourceful
      extend Merb::Plugins::Resourceful::ClassMethods
      
      def only_provides(whatever)
      end

      def display(result, options)
        [result, options]
      end
      
      def resource_updated(rsrc)
        "resource updated"
      end
      
      def message
        @message ||= {}
      end
      
      def redirect(*args)
      end
    end
  end
  
  describe "all actions" do 
    before do
      @controller.class.resourceful
    end
    
    %w(index show new create edit update destroy).each do |action|
      it "creates ##{action}" do
        if action == 'destroy'
          pending
        else
          @controller.should respond_to(action)
        end
      end
    end
  end
  
  describe "#index" do
    before do
      @controller.class.resourceful @resourceful_opts.merge({:only => :index})
      
      @one = create_resource({:name => "one"}, @parent)
      @two = create_resource({:name => "two"}, @parent)
    end
    
    after do
      delete_resource(@one, @parent)
      delete_resource(@two, @parent)
    end
    
    it "renders the list" do
      @controller.index[0].should include(@one, @two)
    end
  end
  
  describe "#show" do
    describe "no options" do
      before do
        @controller.class.resourceful @resourceful_opts.merge(:only => :show)
        
        @resource = create_resource({:name => "one"}, @parent)
        @result, @display_opts = @controller.show(@resource.id)
      end
      
      after do
        delete_resource(@resource, @parent)
      end
      
      it "renders the resource" do
        @result.should == @resource
      end
    end
    
    describe "with options" do
      before do
        @controller.class.resourceful @resourceful_opts.merge(:only => :show) do
          show :layout => :layout
        end
        
        @resource = create_resource({:name => "one"}, @parent)
        @result, @display_opts = @controller.show(@resource.id)
      end
      
      after do
        delete_resource(@resource, @parent)
      end
      
      it ":layout" do
        @display_opts.should have_key(:layout)
      end
    end
  end
  
  describe "#new" do
    before do
      @controller.class.resourceful @resourceful_opts.merge(:only => :new)
      
      @result, @display_opts = @controller.new
    end
    
    it "renders a new resource" do
      @result.should be_new_record
    end
  end
  
  describe "#create" do
    before do
      resourceful_opts = @resourceful_opts

      @controller.class.class_eval do
        resourceful resourceful_opts.merge(:only => :create)
        
        def resource_created(rsrc)
          "resource created"
        end
      end
      
      @result = @controller.create(:name => "create resource")
    end
    
    after do
      delete_resource({:name => "create resource"}, @parent)
    end

    it "creates the resource" do
      find_resource({:name => "create resource"}, @parent).should_not be_nil
    end
    
    it "displays the resource" do
      @result.should == "resource created"
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
      resourceful_opts = @resourceful_opts
      
      @controller.class.class_eval do
        resourceful resourceful_opts.merge(:only => :update)
        
        def resource_updated(rsrc)
          "resource updated"
        end
      end

      @resource = create_resource({:name => "before update"}, @parent)
    end
    
    after do
      delete_resource(@resource, @parent)
    end
    
    it "renders the form" do
      @resource, @result = @controller.edit(@resource.id)
      @resource.should == @resource
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
