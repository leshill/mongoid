require "spec_helper"

describe Mongoid::Criterion::Optional do

  before do
    @criteria = Mongoid::Criteria.new(Person)
    @canvas_criteria = Mongoid::Criteria.new(Canvas)
  end

  describe "#extras" do

    context "filtering" do

      context "when page is provided" do

        it "sets the limit and skip options" do
          @criteria.extras({ :page => "2" })
          @criteria.page.should == 2
          @criteria.options.should == { :skip => 20, :limit => 20 }
        end

      end

      context "when per_page is provided" do

        it "sets the limit and skip options" do
          @criteria.extras({ :per_page => 45 })
          @criteria.options.should == { :skip => 0, :limit => 45 }
        end

      end

      context "when page and per_page both provided" do

        it "sets the limit and skip options" do
          @criteria.extras({ :per_page => 30, :page => "4" })
          @criteria.options.should == { :skip => 90, :limit => 30 }
          @criteria.page.should == 4
        end

      end

    end

    it "adds the extras to the options" do
      @criteria.limit(10).extras({ :skip => 10 })
      @criteria.options.should == { :skip => 10, :limit => 10 }
    end

    it "returns self" do
      @criteria.extras({}).should == @criteria
    end

  end

  describe "#id" do

    context "when passing a single id" do

      it "adds the _id query to the selector" do
        id = Mongo::ObjectID.new.to_s
        @criteria.id(id)
        @criteria.selector.should == { :_type => { "$in" => ["Doctor", "Person"] }, :_id => id }
      end

      it "returns self" do
        id = Mongo::ObjectID.new.to_s
        @criteria.id(id.to_s).should == @criteria
      end

    end

    context "when passing in an array of ids" do

      before do
        @ids = []
        3.times { @ids << Mongo::ObjectID.new.to_s }
      end

      it "adds the _id query to the selector" do
        @criteria.id(@ids)
        @criteria.selector.should ==
          { :_type => { "$in" => ["Doctor", "Person"] }, :_id => { "$in" => @ids } }
      end

    end

  end

  describe "#limit" do

    context "when value provided" do

      it "adds the limit to the options" do
        @criteria.limit(100)
        @criteria.options.should == { :limit => 100 }
      end

    end

    context "when value not provided" do

      it "defaults to 20" do
        @criteria.limit
        @criteria.options.should == { :limit => 20 }
      end

    end

    it "returns self" do
      @criteria.limit.should == @criteria
    end

  end

  describe "#offset" do

    context "when the per_page option exists" do

      before do
        @criteria = Mongoid::Criteria.new(Person).extras({ :per_page => 20, :page => 3 })
      end

      it "returns the per_page option" do
        @criteria.offset.should == 40
      end

    end

    context "when the skip option exists" do

      before do
        @criteria = Mongoid::Criteria.new(Person).extras({ :skip => 20 })
      end

      it "returns the skip option" do
        @criteria.offset.should == 20
      end

    end

    context "when an argument is provided" do

      before do
        @criteria = Mongoid::Criteria.new(Person)
        @criteria.offset(40)
      end

      it "delegates to skip" do
        @criteria.options[:skip].should == 40
      end

    end

    context "when no option exists" do

      context "when page option exists" do

        before do
          @criteria = Mongoid::Criteria.new(Person).extras({ :page => 2 })
        end

        it "adds the skip option to the options and returns it" do
          @criteria.offset.should == 20
          @criteria.options[:skip].should == 20
        end

      end

      context "when page option does not exist" do

        before do
          @criteria = Mongoid::Criteria.new(Person)
        end

        it "returns nil" do
          @criteria.offset.should be_nil
          @criteria.options[:skip].should be_nil
        end

      end

    end

  end

  describe "#order_by" do

    context "when field names and direction specified" do

      it "adds the sort to the options" do
        @criteria.order_by([[:title, :asc], [:text, :desc]])
        @criteria.options.should == { :sort => [[:title, :asc], [:text, :desc]] }
      end

    end

    it "returns self" do
      @criteria.order_by.should == @criteria
    end

  end

  describe "#page" do

    context "when the page option exists" do

      before do
        @criteria = Mongoid::Criteria.new(Person).extras({ :page => 5 })
      end

      it "returns the page option" do
        @criteria.page.should == 5
      end

    end

    context "when the page option does not exist" do

      before do
        @criteria = Mongoid::Criteria.new(Person)
      end

      it "returns 1" do
        @criteria.page.should == 1
      end

    end

  end

  describe "#skip" do

    context "when value provided" do

      it "adds the skip value to the options" do
        @criteria.skip(20)
        @criteria.options.should == { :skip => 20 }
      end

    end

    context "when value not provided" do

      it "defaults to zero" do
        @criteria.skip
        @criteria.options.should == { :skip => 0 }
      end

    end

    it "returns self" do
      @criteria.skip.should == @criteria
    end

  end
end
