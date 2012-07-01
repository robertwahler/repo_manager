require 'spec_helper'

require 'basic_app/views/view_helper'
include BasicApp::ViewHelper

describe BasicApp::ViewHelper do

  context ":basic_app files" do
    before :each do
      @root = File.expand_path('../../../../', __FILE__)
      @file = File.join(@root, 'lib/basic_app/app.rb')
      File.exists?(@file).should be_true
    end

    describe 'path_to :basic_app "file asset"' do
      it "should return the absolute path of the given basic_app file asset" do
        path_to(:basic_app, 'lib/basic_app/app.rb').should == @file
      end
    end

    describe 'path_to "file asset"' do
      it "should return the absolute path of the given basic_app file asset" do
        path_to('lib/basic_app/app.rb').should == @file
      end
    end
  end

end
