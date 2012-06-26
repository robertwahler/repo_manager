require 'spec_helper'

describe BasicApp::Settings do

  before(:each) do
    @filename = 'config.conf'
    @hash_symbols = {
                      :zebra => "has stripes",
                      :options => {
                        :verbose => false
                      }
                    }
    write_file(@filename, @hash_symbols.to_conf)
  end

  describe '#new' do
    it "should read a config YAML file and return a Hash" do
      settings = BasicApp::Settings.new(FileUtils.pwd, :config => fullpath(@filename))
      settings.is_a?(Hash).should be_true
      settings.to_hash.is_a?(Hash).should be_true
    end
  end

  describe '#to_hash' do
    it "should provide a symbolized hash" do
      settings = BasicApp::Settings.new(FileUtils.pwd, :config => fullpath(@filename))
      settings[:zebra].should == "has stripes"
    end
  end

  describe 'hash value accessors' do
    it "should provide read method accessors" do
      settings = BasicApp::Settings.new(FileUtils.pwd, :config => fullpath(@filename))
      settings.to_hash[:zebra].should == settings.zebra
    end

    it "should provide write method accessors that set symbolized keys on self" do
      settings = BasicApp::Settings.new(FileUtils.pwd, :config => fullpath(@filename))
      settings.new_value = :dogfood
      settings.new_value.should == :dogfood
      settings[:new_value].should == :dogfood
      settings['new_value'].should be_nil
    end

    context "when undefined" do
      it "should return nil" do
        settings = BasicApp::Settings.new(FileUtils.pwd, :config => fullpath(@filename))
        settings.garbage.should be_nil
      end
      it "should not raise error" do
        settings = BasicApp::Settings.new(FileUtils.pwd, :config => fullpath(@filename))
        lambda { settings.garbage.should be_nil }.should_not raise_error
      end
      context "when multiple levels" do
        it "should raise error" do
          settings = BasicApp::Settings.new(FileUtils.pwd, :config => fullpath(@filename))
          lambda { settings.even_more.garbage.should be_nil }.should raise_error
        end
      end
    end

  end

end
