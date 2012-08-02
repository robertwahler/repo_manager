require 'spec_helper'

describe Git do

  describe 'Git::Lib.native' do

    it "should validate the Git binary once and only once" do

      lib1 = Git::Lib.new(:working_directory => fullpath('.'))
      lib1.stub!(:required_command_version).and_return( [20, 0, 0, 1])

      $stderr.should_receive(:puts).with(/gem requires git 20.0.0.1 or later/i)
      # NOTE: any native git command will suffice for this test, 'version' is just
      # fast and doesn't require a repo setup
      lib1.native 'version'

      # do it again with same instance
      $stderr.should_not_receive(:puts).with(/gem requires git 20.0.0.1 or later/i)
      lib1.native 'version'

      # do it again with new instance
      lib2 = Git::Lib.new(:working_directory => fullpath('.'))
      lib2.stub!(:required_command_version).and_return( [20, 0, 0, 1])

      $stderr.should_not_receive(:puts).with(/gem requires git 20.0.0.1 or later/i)
      lib2.native 'version'
    end
  end

end

