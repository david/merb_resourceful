require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require File.join(File.dirname(__FILE__), 'resourceful_controller_spec')

if Merb.orm == :datamapper
  given "a book exists" do
    Book.all.destroy!
    
    @book = Book.create(:title => 'Code Complete')
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
      Object.send(:remove_const, :Book)
    end

    before do
      Book.auto_migrate!
    end

    it_should_behave_like "resourceful controller"
  end
  
  def request_for_books
    :books
  end
  
  def request_for_book
    @book || Book.first
  end
  
  def request_for_new_book
    [:books, :new]
  end
  
  def request_for_edit_book
    [@book, :edit]
  end
  
  def find_book(id)
    Book.get(id)
  end
end


