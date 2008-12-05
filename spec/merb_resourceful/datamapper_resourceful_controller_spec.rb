require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require File.join(File.dirname(__FILE__), 'resourceful_controller_spec')

if Merb.orm == :datamapper
  given "a book exists" do
    Book.all.destroy!
    
    @book = (@shelf ? @shelf.books : Book).create(:title => 'Code Complete')
  end

  given "a shelf exists" do
    Shelf.all.destroy!
    
    @shelf = Shelf.create
  end
  
  given "2 books exist" do
    @book = (@shelf ? @shelf.books : Book).create(:title => 'Code Complete')
    @shelf2 = Shelf.create
    @book2 = @shelf2.books.create(:title => 'The Practice of Programming')
  end

  describe "DataMapper resourceful controller" do
    before :all do
      DataMapper.setup(:default, "sqlite3::memory:")
      
      class Book
        include DataMapper::Resource
        
        property :id, Serial
        property :title, String, :length => 1..255
        property :optional, String
        
        def self.zee_filter
          all(:title => 'filtered')
        end
      end
      
      class Shelf
        include DataMapper::Resource

        property :id, Serial
        
        has n, :books
      end
    end
    
    after :all do
      Object.send(:remove_const, :Book)
    end

    before do
      Shelf.auto_migrate!
      Book.auto_migrate!
    end

    it_should_behave_like "resourceful controller"
    
    def find_single_book
      Book.first
    end
    
    def find_book_in_shelf
      @shelf.books.first
    end
  end
end
