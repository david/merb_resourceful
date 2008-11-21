require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/controller_builder_spec'
require 'dm-core'

module Merb
  def self.orm
    :datamapper
  end
end

describe "datamapper builder" do
  it_should_behave_like 'resourceful'
  
  before :all do
    DataMapper.setup(:default, "sqlite3://#{File.expand_path(File.dirname(__FILE__) + '/../../datamapper.db')}")

    class TestResource
      include DataMapper::Resource
      
      property :id, Serial
      property :name, String
    end

    TestResource.auto_migrate!

    @controller = TestResources.new
  end
  
  def find_resource(query, parent = nil)
    TestResource.first(query)
  end
  
  def delete_resource(resource, parent = nil)
    if Hash === resource
      (r = find_resource(resource)) && r.destroy
    else
      resource.destroy
    end
  end
  
  def create_resource(attrs, parent = nil)
    TestResource.create(attrs)
  end

  describe "with parent (has many)" do
    it_should_behave_like 'resourceful'
  
    before :all do
      DataMapper.setup(:default, "sqlite3://#{File.expand_path(File.dirname(__FILE__) + '../../datamapper.db')}")
      
      class ParentResource
        include DataMapper::Resource
        
        property :id, Serial
        property :name, String
        
        has n, :test_resources
      end
      
      ParentResource.auto_migrate!
      TestResource.auto_migrate!
      
      @parent = test_parent = ParentResource.create(:name => 'parent')
      @resourceful_opts = { :parent => lambda { ParentResource.get(params[:parent_resource_id]) } }

      TestResources.class_eval do
        define_method :params do
          {:parent_resource_id => test_parent.id}
        end
      end
    end
    
    after :all do
      @parent.destroy
    end
    
    before do
      @controller = TestResources.new
    end
    
    def find_resource(query, parent)
      parent.test_resources.first(query)
    end
    
    def delete_resource(resource, parent)
      if Hash === resource
        (r = find_resource(resource, parent)) && r.destroy
      else
        resource.destroy
      end
    end
    
    def create_resource(attrs, parent)
      parent.test_resources.create(attrs)
    end
  end
end
