require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')


describe "resourceful controller", :shared => true do
  
  before :all do
    Merb.push_path(:view, File.join(File.dirname(__FILE__), '..', 'views'))
    Merb::Router.prepare do |r|
      identify :id do
        r.resources :books
      end
    end
  end

  before do
    class Books < Merb::Controller
      def _template_location(action, type = nil, controller = controller_name)
        controller == "layout" ? "layout.#{action}.#{type}" : "#{action}.#{type}"
      end
      
      resourceful
    end
  end
  
  after do
    Object.send(:remove_const, :Books)
  end

  describe "resource(:books)" do
    describe "GET" do
      
      before(:each) do
        @response = request(resource(*request_for_books))
      end
      
      it "responds successfully" do
        @response.should be_successful
      end

      it "contains a list of books" do
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
      
      it "redirects to resource(@book)" do
        @response.should redirect_to(resource(*request_for_book), :message => {:notice => "book successfully created"})
      end
      
    end
  end

  describe "resource(@book)" do 
    describe "a successful DELETE", :given => "a book exists" do
      before(:each) do
        @response = request(resource(*request_delete), :method => "DELETE")
      end

      it "should redirect to the index action" do
        @response.should redirect_to(resource(*request_for_books))
      end
    end
  end

  describe "resource(:books, :new)" do
    before(:each) do
      @response = request(resource(*request_for_new_book))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end
  end

  describe "resource(@book, :edit)", :given => "a book exists" do
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

  describe "resource(@book)", :given => "a book exists" do
    
    describe "GET" do
      before(:each) do
        @response = request(resource(*request_for_book))
      end
      
      it "responds successfully" do
        @response.should be_successful
      end
    end
    
    describe "PUT" do
      before(:each) do
        @book = Book.first
        @response = request(resource(*request_for_book), :method => "PUT", 
                            :params => { :book => {:id => @book.id, :title => "Code Complete 2nd Edition."} })
      end
      
      it "redirect to the book show action" do
        @response.should redirect_to(resource(*request_for_book))
      end
      
      it "updates the book" do
        find_book(@book.id).title.should == "Code Complete 2nd Edition."
      end
    end
    
  end
end
