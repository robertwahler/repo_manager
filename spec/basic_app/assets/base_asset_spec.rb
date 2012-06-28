require 'spec_helper'

describe Repoman::BaseAsset  do

  describe 'self.path_to_name' do

    it "should replace one or more whitespace chars with a single underscore" do
      Repoman::BaseAsset.path_to_name("/path/to a/hello  world ").should == "hello_world"
    end

    it "should strip special chars # @ % * ' ! + . -" do
      Repoman::BaseAsset.path_to_name("/path/to a/.he@@llo' !w+orl-d'").should == "hello_world"
    end

    it "should replace '&' with '_and_'" do
      Repoman::BaseAsset.path_to_name("/path/to a/&hello &world&").should == "and_hello_and_world_and"
    end

    it "should lowercase the name" do
      Repoman::BaseAsset.path_to_name("d:/path/to a/Hello worlD").should == "hello_world"
    end

  end

  context "being created" do

    describe "name" do

      it "should be nil if unless name passed to initialize " do
        asset = Repoman::BaseAsset.new
        asset.name.should be_nil
      end

      it "should be the same as asset_name param " do
        asset = Repoman::BaseAsset.new("my_asset_name")
        asset.name.should == "my_asset_name"
      end

    end
  end


end

