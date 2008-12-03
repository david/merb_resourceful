require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require File.join(File.dirname(__FILE__), 'resourceful_controller_spec')
require 'dm-core'

use_orm :datamapper

given "a book exists" do
  Book.all.destroy!
  
  Book.create(:title => 'Code Complete')
end

describe "DataMapper resourceful controller" do
  before :all do
    DataMapper.setup(:default, "sqlite3://#{File.expand_path(File.dirname(__FILE__) + '/../../datamapper.db')}")
    
    class Book
      include DataMapper::Resource
      
      property :id, Serial
      property :title, String
    end
    
  end
  
  after :all do
    #Object.send(:const_remove, :Book)
  end

  before do
    Book.auto_migrate!
  end

  it_should_behave_like "resourceful controller"
end
