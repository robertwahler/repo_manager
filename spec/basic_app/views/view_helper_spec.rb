require 'spec_helper'

require 'repo_manager/views/view_helper'
include RepoManager::ViewHelper

describe RepoManager::ViewHelper do

  context ":repo_manager files" do
    before :each do
      @root = File.expand_path('../../../../', __FILE__)
      @file = File.join(@root, 'lib/repo_manager/app.rb')
      File.exists?(@file).should be_true
    end

    describe 'path_to :repo_manager "file asset"' do
      it "should return the absolute path of the given repo_manager file asset" do
        path_to(:repo_manager, 'lib/repo_manager/app.rb').should == @file
      end
    end

    describe 'path_to "file asset"' do
      it "should return the absolute path of the given repo_manager file asset" do
        path_to('lib/repo_manager/app.rb').should == @file
      end
    end
  end

end
