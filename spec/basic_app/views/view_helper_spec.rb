require 'spec_helper'

require 'repoman/views/view_helper'
include RepoManager::ViewHelper

describe RepoManager::ViewHelper do

  context ":repoman files" do
    before :each do
      @root = File.expand_path('../../../../', __FILE__)
      @file = File.join(@root, 'lib/repoman/app.rb')
      File.exists?(@file).should be_true
    end

    describe 'path_to :repoman "file asset"' do
      it "should return the absolute path of the given repoman file asset" do
        path_to(:repoman, 'lib/repoman/app.rb').should == @file
      end
    end

    describe 'path_to "file asset"' do
      it "should return the absolute path of the given repoman file asset" do
        path_to('lib/repoman/app.rb').should == @file
      end
    end
  end

end
