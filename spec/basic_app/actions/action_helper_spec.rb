require 'spec_helper'
require 'fileutils'
require 'basic_app/actions/action_helper'

class Thing
  include ::BasicApp::ActionHelper
end

describe BasicApp::ActionHelper  do

  describe 'relative_path', :posix => true do

    it "should return relative path given an absolute path" do
      thing = Thing.new
      FileUtils.stub!('pwd').and_return '/home/robert/workspace/my_app'
      thing.relative_path('/home/robert/workspace/my_app/photos').should == './photos'
      thing.relative_path('/home/robert/photos').should == '../../photos'
    end

    it "should return relative path given a relative path" do
      thing = Thing.new
      FileUtils.stub!('pwd').and_return '/home/someuser/my_app'
      thing.relative_path('cats/dogs').should == './cats/dogs'
    end

  end

  describe 'relative_path', :windows => true do

    context "on the same drive" do
      it "should return relative path given an absolute path" do
        thing = Thing.new
        FileUtils.stub!('pwd').and_return 'c:/home/robert/workspace/my_app'
        thing.relative_path('c:/home/robert/workspace/my_app/photos').should == './photos'
        thing.relative_path('c:/home/robert/photos').should == '../../photos'
      end
    end

    context "on a different drive" do
      it "should return relative path given an absolute path" do
        thing = Thing.new
        FileUtils.stub!('pwd').and_return 'c:/home/robert/workspace/my_app'
        thing.relative_path('d:/some/path/photos').should == 'd:/some/path/photos'
      end
    end

    it "should return relative path given a relative path" do
      thing = Thing.new
      FileUtils.stub!('pwd').and_return 'c:/home/someuser/my_app'
      thing.relative_path('cats/dogs').should == './cats/dogs'
    end

  end
end
