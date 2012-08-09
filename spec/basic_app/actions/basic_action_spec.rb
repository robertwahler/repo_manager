require 'spec_helper'

describe BasicApp::BaseAction  do

  before :all do
    #BasicApp::Logger::Manager.new
    #Logging.appenders.stdout.level = :debug
  end

  describe "parse_options" do

    context "no parser_configuration specified" do

      before :each do
        # suppress STDOUT messages
        $stdout = StringIO.new
      end

      context "BaseAction instantiated with valid options" do
        it "should not raise errors" do
          args = ['--force']
          configuration = {}

          action = BasicApp::BaseAction.new(args, configuration)
          lambda { action.parse_options }.should_not raise_error
        end

        it "should return an instance of OptionParser" do
          args = ['--force']
          configuration = {}

          action = BasicApp::BaseAction.new(args, configuration)
          action.parse_options.is_a?(OptionParser).should be_true
        end

        it "should consume valid action.args" do
          args = ['--force']
          configuration = {}

          action = BasicApp::BaseAction.new(args, configuration)
          action.parse_options
          action.args.should be_empty
        end

        it "should not modify args param" do
          args = ['--force']
          configuration = {}

          action = BasicApp::BaseAction.new(args, configuration)
          action.parse_options
          action.args.should be_empty
          args.should == ['--force']
        end

        it "should not modify configuration param" do
          args = ['--force']
          configuration = {:options => {:something => true}}

          action = BasicApp::BaseAction.new(args, configuration)
          action.parse_options
          configuration.should == {:options => {:something => true}}
        end

        it "should modify action.configuration" do
          args = ['--force']
          configuration = {:options => {:something => true}}

          action = BasicApp::BaseAction.new(args, configuration)
          action.parse_options
          action.configuration.should == {:options => {:something => true, :force => true}}
        end

      end

      context "BaseAction instantiated with invalid options" do
        it "should raise errors" do
          args = ['--bad-option']
          configuration = {}

          action = BasicApp::BaseAction.new(args, configuration)
          lambda { action.parse_options}.should raise_error
        end

      end

    end

    context "parser_configuration with {raise_on_invalid_option=>false}" do

      context "BaseAction instantiated with invalid options" do
        it "should not raise errors" do
          args = ['--bad-option']
          configuration = {}

          action = BasicApp::BaseAction.new(args, configuration)
          lambda { action.parse_options(:raise_on_invalid_option => false)}.should_not raise_error
        end

        it "should not consume invalid 'args'" do
          args = ['--bad-option']
          configuration = {}

          action = BasicApp::BaseAction.new(args, configuration)
          lambda { action.parse_options(:raise_on_invalid_option => false)}.should_not raise_error
          action.args.should == ['--bad-option']
        end

        it "should not modify configuration param" do
          args = ['--force']
          configuration = {:options => {:something => true}}

          action = BasicApp::BaseAction.new(args, configuration)
          action.parse_options
          configuration.should == {:options => {:something => true}}
        end

      end

    end

  end
end
