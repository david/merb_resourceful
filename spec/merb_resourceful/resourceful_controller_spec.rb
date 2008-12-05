require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')


describe "resourceful controller", :shared => true do
  
  before :all do
    Merb.push_path(:view, File.join(File.dirname(__FILE__), '..', 'views'))
  end
  
  before do
    class AbstractBooks < Merb::Controller
      def _template_location(action, type = nil, controller = controller_name)
        controller == "layout" ? "layout.#{action}.#{type}" : "#{action}.#{type}"
      end
    end
    
    class ShelvedBooks < AbstractBooks
      def shelf
        @shelf ||= Shelf.all.last
      end
    end

  end
  
  after do
    Object.send(:remove_const, :Books)
  end

  describe "common behavior", :shared => true do
    describe "resource(*, :books)" do
      describe "GET" do
        before(:each) do
          @response = request(resource(*request_for_books))
        end
        
        it "responds successfully" do
          @response.should be_successful
        end

        it "has a list of books" do
          @response.should have_xpath("//ul")
        end
      end
      
      describe "GET", :given => "a book exists" do
        before(:each) do
          @response = request(resource(*request_for_books))
        end
        
        it "has a list of books" do
          @response.should have_xpath("//ul/li")
        end
      end
      
      describe "a successful POST" do
        before(:each) do
          @response = request(resource(*request_for_books), :method => "POST", 
                              :params => { :book => { :title => "The C Programming Language" }})
        end
        
        it "redirects to resource(*, @book)" do
          @response.should redirect_to(resource(*request_for_book), 
                                       :message => {:notice => "book successfully created"})
        end
        
        it "creates the resource" do
          find_book.should_not be_nil
        end
      end
      
      describe "GET", "with filter", :given => "a book exists" do
        before(:each) do
          Object.send(:remove_const, :Books)
          
          class Books < AbstractBooks
            resourceful do
              index :filter => :zee_filter
            end
          end
          
          @response = request(resource(*request_for_books))
        end
        
        it "has a list of filtered books" do
          @response.should have_xpath("//ul")
          @response.should_not have_xpath("//ul/li")
        end
      end
      
      describe "a successful POST" do
        before(:each) do
          @response = request(resource(*request_for_books), :method => "POST", 
                              :params => { :book => { :title => "The C Programming Language" }})
        end
        
        it "redirects to resource(*, @book)" do
          @response.should redirect_to(resource(*request_for_book), 
                                       :message => {:notice => "book successfully created"})
        end
      end
    end

    describe "resource(*, @book)" do 
      describe "a successful DELETE", :given => "a book exists" do
        before(:each) do
          pending do 
            @response = request(resource(*request_delete), :method => "DELETE")
          end
        end

        it "should redirect to the index action" do
          pending do
            @response.should redirect_to(resource(*request_for_books))
          end
        end
      end
    end

    describe "resource(*, :books, :new)" do
      before(:each) do
        @response = request(resource(*request_for_new_book))
      end
      
      it "responds successfully" do
        @response.should be_successful
      end
    end

    describe "resource(*, @book, :edit)", :given => "a book exists" do
      before(:each) do
        @response = request(resource(*request_for_edit_book))
      end
      
      it "responds successfully" do
        @response.should be_successful
      end
      
      it "presents the resource being edited" do
        @response.should have_xpath("//*[contains(., 'Edit Code Complete')]")
      end
    end

    describe "resource(*, @book)", :given => "a book exists" do
      describe "GET" do
        before(:each) do
          @response = request(resource(*request_for_book))
        end
        
        it "responds successfully" do
          @response.should be_successful
        end
        
        it "shows the right book" do
          @response.should have_xpath("//*[contains(., 'Code Complete')]")
        end
      end
      
      describe "PUT" do
        before(:each) do
          @response = request(resource(*request_for_book), :method => "PUT", 
                              :params => { :book => {:id => @book.id, :title => "Code Complete 2nd Edition."} })
        end
        
        it "redirect to the book show action" do
          @response.should redirect_to(resource(*request_for_book))
        end
        
        it "updates the book" do

          Book.first.title.should == "Code Complete 2nd Edition."
        end
      end
    end
  end
  
  describe "action-specific layouts", :shared => true do
    describe "GET", :given => "a book exists" do
      before(:each) do
        Object.send(:remove_const, :Books)
        
        class Books < AbstractBooks
          resourceful do
            show :layout => :another
          end
        end
        
        @response = request(resource(*request_for_book))
      end
      
      it "has a different layout" do
        @response.should have_xpath("//*[contains(., 'Another Layout')]")
      end
    end
  end
  
  describe "action-specific params", :shared => true do
    describe "resource(*, :books)" do
      describe "a successful POST", "with extra params" do
        before(:each) do
          Object.send(:remove_const, :Books)
          
          class Books < AbstractBooks
            resourceful do
              create :params => lambda {{ :optional => "is not null!" }}
            end
          end
          
          @response = request(resource(*request_for_books), :method => "POST", 
                              :params => { :book => { :title => "The C Programming Language" }})
        end
        
        it "redirects to resource(*, @book)" do
          @response.should redirect_to(resource(*request_for_book), 
                                       :message => {:notice => "book successfully created"})
        end
        
        it "adds the value of optional to the book" do
          find_book.optional.should_not be_nil
        end
      end
    end  
    
    describe "resource(*, @book)", :given => "a book exists" do
      describe "PUT", "with extra params" do
        before(:each) do
          Object.send(:remove_const, :Books)
          
          class Books < AbstractBooks
            resourceful do
              update :params => lambda {{ :optional => "is not null!" }}
            end
          end
          
          @response = request(resource(*request_for_book), :method => "PUT", 
                              :params => { :book => {:id => @book.id, :title => "Code Complete 2nd Edition."} })
        end
        
        it "redirect to the book show action" do
          @response.should redirect_to(resource(*request_for_book))
        end
        
        it "updates the book with the extra param" do
          Book.first.optional.should_not be_nil
        end
      end
    end
  end
    
  describe "action-specific scopes", :shared => true do
    describe "resource(*, @book)", :given => "a book exists" do
      describe "GET", "using :scope", :given => "2 books exist" do
        before(:each) do
          Object.send(:remove_const, :Books)
          
          class Books < ShelvedBooks
            resourceful do
              show :scope => :shelf
            end
          end
          
          @response = request(resource(*request_for_book))
        end
          
        it "responds successfully" do
          @response.should be_successful
        end
        
        it "shows the right book" do
          @response.should have_xpath("//*[contains(., 'The Practice of Programming')]")
        end
        
        def request_for_book
          @book2
        end
      end
    
      describe "a successful POST", "using :scope", :given => "a shelf exists" do
        before(:each) do
          Object.send(:remove_const, :Books)
          
          class Books < ShelvedBooks
            resourceful do
              create :scope => :shelf
            end
          end
          
          @response = request(resource(*request_for_books), :method => "POST", 
                              :params => { :book => { :title => "The C Programming Language" }})
        end
        
        it "redirects to resource(*, @book)" do
          @response.should redirect_to(resource(*find_book), 
                                       :message => {:notice => "book successfully created"})
        end
        
        it "creates the book" do
          find_book.title.should == "The C Programming Language"
        end
        
        def find_book
          find_book_in_shelf
        end
      end
    end
  end
  
  describe "single resource" do
    before :all do
      Merb::Router.prepare do |r|
        identify :id do
          r.resources :books
        end
      end
    end
    
    before do
      class Books < AbstractBooks
        resourceful
      end
    end
    
    def request_for_books
      :books
    end
    
    def request_for_book
      @book || find_book
    end
    
    def request_for_new_book
      [:books, :new]
    end
    
    def request_for_edit_book
      [@book, :edit]
    end
    
    it_should_behave_like "common behavior"
    it_should_behave_like "action-specific scopes"
    it_should_behave_like "action-specific params"
    it_should_behave_like "action-specific layouts"
    
    def find_book
      find_single_book
    end
  end
  
  describe "single resource", "using :scope", :given => "a shelf exists" do
    before :all do
      Merb::Router.prepare do |r|
        identify :id do
          r.resources :books
        end
      end
    end
    
    before do
      class Books < ShelvedBooks
        resourceful :scope => :shelf
      end
    end
    
    def request_for_books
      :books
    end
    
    def request_for_book
      @book || find_book
    end
    
    def request_for_new_book
      [:books, :new]
    end
    
    def request_for_edit_book
      [@book, :edit]
    end
    
    it_should_behave_like "common behavior"
    it_should_behave_like "action-specific scopes"
    
    def find_book
      find_book_in_shelf
    end
  end
  
  describe "nested resource", "through method", :given => "a shelf exists" do
    before :all do
      Merb::Router.prepare do |r|
        identify :id do
          r.resources :shelves do
            r.resources :books
          end
        end
      end
    end
    
    before do
      class Books < ShelvedBooks
        resourceful :belongs_to => :shelf
      end
    end
    
    def request_for_books
      [@shelf, :books]
    end
    
    def request_for_book
      [@shelf, @book || find_book]
    end
    
    def request_for_new_book
      [@shelf, :books, :new]
    end
    
    def request_for_edit_book
      [@shelf, @book, :edit]
    end
    
    it_should_behave_like "common behavior"
    
    def find_book
      find_book_in_shelf
    end
  end
end
