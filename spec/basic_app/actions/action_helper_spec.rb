require 'spec_helper'
require 'fileutils'
require 'basic_app/actions/action_helper'

class Thing
  include ::BasicApp::ActionHelper
end

describe BasicApp::ActionHelper  do

  describe 'relative_path' do

    it "should return relative path given an absolute path" do
      thing = Thing.new
      FileUtils.stub!('pwd').and_return '/home/robert/workspace/basic_app'
      thing.relative_path('/home/robert/workspace/basic_app/photos').should == './photos'
      thing.relative_path('/home/robert/photos').should == '../../photos'
    end

    it "should return relative path given an absolute path", :windows => true do
      thing = Thing.new
      FileUtils.stub!('pwd').and_return 'c:/home/workspace/basic_app'
      thing.relative_path('c:/home/robert/workspace/basic_app/photos').should == './photos'
      thing.relative_path('c:/home/workspace/robert/photos').should == '../../photos'
    end

    it "should return relative path given a relative path" do
      thing = Thing.new
      FileUtils.stub!('pwd').and_return '/home/robert/workspace/basic_app'
      thing.relative_path('cats/dogs').should == './cats/dogs'
    end

  end
end
