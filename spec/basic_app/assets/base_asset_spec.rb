require 'spec_helper'

describe BasicApp::BaseAsset  do

  describe 'self.path_to_name' do

    it "should replace one or more whitespace chars with a single underscore" do
      BasicApp::BaseAsset.path_to_name("/path/to a/hello  world ").should == "hello_world"
    end

    it "should strip special chars # @ % * ' ! + . -" do
      BasicApp::BaseAsset.path_to_name("/path/to a/.he@@llo' !w+orl-d'").should == "hello_world"
    end

    it "should replace '&' with '_and_'" do
      BasicApp::BaseAsset.path_to_name("/path/to a/&hello &world&").should == "and_hello_and_world_and"
    end

    it "should lowercase the name" do
      BasicApp::BaseAsset.path_to_name("d:/path/to a/Hello worlD").should == "hello_world"
    end

  end

  context "being created" do

    describe "name" do

      it "should be nil if unless name passed to initialize " do
        asset = BasicApp::BaseAsset.new
        asset.name.should be_nil
      end

      it "should be the same as asset_name param " do
        asset = BasicApp::BaseAsset.new("my_asset_name")
        asset.name.should == "my_asset_name"
      end

    end
  end

  describe 'common attributes' do

    before :each do
      @asset = BasicApp::BaseAsset.new
      @asset.name = "test_asset"
    end

    describe 'description' do

      it "should be nil unless set" do
        @asset.attributes[:description].should be_nil
        @asset.description.should be_nil
      end

      it "should render mustache templates" do
        @asset.description = "This is a {{name}}"
        @asset.attributes[:description].should == "This is a {{name}}"
        @asset.description.should == "This is a test_asset"
      end

    end

    describe 'notes' do

      it "should be nil unless set" do
        @asset.attributes[:notes].should be_nil
        @asset.notes.should be_nil
      end

      it "should render mustache templates" do
        @asset.notes = "This is a {{name}}"
        @asset.attributes[:notes].should == "This is a {{name}}"
        @asset.notes.should == "This is a test_asset"
      end

    end

    describe 'path' do

      it "defaults to asset name when the path attribute is blank" do
        @asset.name = "asset_name"
        @asset.attributes[:path].should be_nil
        @asset.path.should match(/^.*\/asset_name$/)
      end

      it "should be nil unless path or name is set" do
        @asset.name = nil
        @asset.attributes[:path].should be_nil
        @asset.path.should be_nil
      end

      it "should expand '~'" do
        @asset.path = "~/test/here"
        @asset.attributes[:path].should == "~/test/here"
        @asset.path.should_not == "~/test/here"
        @asset.path.should match(/.*\/test\/here$/)
      end

      it "should expand relative paths" do
        @asset.path = "test/here"
        @asset.attributes[:path].should == "test/here"
        @asset.path.should match(/^#{File.expand_path(FileUtils.pwd)}\/test\/here$/)
      end

      it "should render mustache templates" do
        @asset.path = "test/{{name}}/here"
        @asset.attributes[:path].should == "test/{{name}}/here"
        @asset.path.should match(/^#{File.expand_path(FileUtils.pwd)}\/test\/test_asset\/here$/)
      end

    end

    describe 'tags' do

      it "should be an empty array unless set" do
        @asset.attributes[:tags].should be_nil
        @asset.tags.should be_empty
      end

    end

  end

  describe 'user defined attributes' do

    context "when not explicitly defined" do

      it "should raise 'NoMethodError' when accessing" do
        asset = BasicApp::BaseAsset.new("test_asset")
        defined?(asset.undefined_attribute).should be_false
        lambda {asset.undefined_attribute.should be_nil}.should raise_error  NoMethodError
        lambda {asset.undefined_attribute = 1}.should raise_error  NoMethodError
      end

      it "should not set that attributes hash" do
        asset = BasicApp::BaseAsset.new "test_asset"
        defined?(asset.undefined_attribute).should be_false
        lambda {asset.undefined_attribute = 1}.should raise_error  NoMethodError
        asset.attributes[:undefined_attribute].should be_nil
      end

      context "when a value exists in the main attributes hash" do
        it "should not raise 'NoMethodError' when accessing" do
          asset = BasicApp::BaseAsset.new("test_asset", {:undefined_attribute => "foo bar"})
          defined?(asset.undefined_attribute).should be_false
          lambda {asset.undefined_attribute.should be_nil}.should_not raise_error  NoMethodError
          lambda {asset.undefined_attribute = 1}.should raise_error  NoMethodError
          asset.undefined_attribute.should == "foo bar"
        end
      end

    end

    context "when explicitly creating" do

      class MyAsset < BasicApp::BaseAsset
        def my_attribute
          @my_attribute
        end
        def my_attribute=(value)
          @my_attribute = value.to_i * 2
        end
      end

      it "should not overwrite existing attributes" do
        attributes = {:user_attributes => [:my_attribute]}

        asset = BasicApp::BaseAsset.new("test_asset", attributes)
        asset.my_attribute = 2
        asset.my_attribute.should == "2"

        my_asset = MyAsset.new("test_asset", attributes)
        my_asset.my_attribute = 2
        my_asset.my_attribute.should == 4
      end

    end

    context "when explicitly defined" do

      it "should create read accessors" do
        attributes = {:user_attributes => [:undefined_attribute]}
        asset = BasicApp::BaseAsset.new("test_asset", attributes)

        defined?(asset.undefined_attribute).should be_true
        lambda {asset.undefined_attribute.should be_nil}.should_not raise_error  NoMethodError
      end

      it "should create write accessors" do
        attributes = {:user_attributes => [:undefined_attribute]}
        asset = BasicApp::BaseAsset.new("test_asset", attributes)

        lambda {asset.undefined_attribute = "1"}.should_not raise_error  NoMethodError
      end

      it "should set the attributes hash" do
        attributes = {:user_attributes => [:undefined_attribute]}
        asset = BasicApp::BaseAsset.new("test_asset", attributes)

        asset.undefined_attribute = "1"
        asset.attributes[:undefined_attribute].should == "1"
      end

    end

  end

end

