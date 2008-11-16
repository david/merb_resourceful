require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/controller_builder_spec'
require 'dm-core'

module Merb
  def self.orm
    :datamapper
  end
end

describe "datamapper builder" do
  before :all do
    DataMapper.setup(:default, "sqlite3://#{File.expand_path(File.dirname(__FILE__) + '/../../datamapper.db')}")
    
    class Resource
      include DataMapper::Resource
      
      property :id, Serial
      property :name, String
    end
    
    Resource.auto_migrate!
    
    class Resources < Merb::Controller
      resourceful

      def display(result)
        result
      end
      
      def resource_created(rsrc)
        "resource created"
      end
      
      def resource_updated(rsrc)
        "resource updated"
      end
      
      def message
        {}
      end
    end
    
    @controller = Resources.allocate
  end
  
  it_should_behave_like 'resourceful'
  
  def find_resource(query, parent = nil)
    Resource.first(query)
  end
  
  def delete_resource(resource, parent = nil)
    if Hash === resource
      (r = find_resource(resource)) && r.destroy
    else
      resource.destroy
    end
  end
  
  def create_resource(attrs, parent = nil)
    Resource.create(attrs)
  end
end

describe "datamapper builder", "with parent (has many)" do
  before :all do
    DataMapper.setup(:default, "sqlite3://#{File.expand_path(File.dirname(__FILE__) + '../../datamapper.db')}")
    
    class ParentResource
      include DataMapper::Resource
      
      property :id, Serial
      property :name, String
      
      has n, :child_resources
    end
    
    class ChildResource
      include DataMapper::Resource
      
      property :id, Serial
      property :name, String
    end
    
    ParentResource.auto_migrate!
    ChildResource.auto_migrate!
    
    class ChildResources < Merb::Controller
      resourceful :parent => lambda { p = ParentResource.get(params[:parent_resource_id]) }

      def display(result)
        result
      end
      
      def resource_created(rsrc)
        "resource created"
      end
      
      def resource_updated(rsrc)
        "resource updated"
      end
      
      def message
        {}
      end
    end
  end
  
  it_should_behave_like 'resourceful'
  
  before do
    @parent = test_parent = ParentResource.create(:name => 'parent')
    
    @controller = ChildResources.allocate
    @controller.class.class_eval do
      define_method :params do
        {:parent_resource_id => test_parent.id}
      end
    end
  end
  
  after do
    @parent.destroy
  end
  
  def find_resource(query, parent)
    parent.child_resources.first(query)
  end
  
  def delete_resource(resource, parent)
    if Hash === resource
      (r = find_resource(resource, parent)) && r.destroy
    else
      resource.destroy
    end
  end
  
  def create_resource(attrs, parent)
    parent.child_resources.create(attrs)
  end
end
