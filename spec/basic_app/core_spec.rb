require 'spec_helper'

describe "Core" do

  before :each do
    @hash_symbols = {
                      :options => {
                        :verbose => false,
                      },
                        :repos => {
                           :repo1 => {:path => "something"}
                      }
                    }

    @hash_strings = {
                      'options' => {
                        'verbose' => false,
                      },
                        'repos' => {
                           'repo1' => {'path' => "something"}
                      }
                    }
  end

  describe Hash do

    describe 'recursively_symbolize_keys!' do
      it "should recursively convert a hash with string keys to a hash with symbol keys" do
        @hash_symbols.should == @hash_strings.recursively_symbolize_keys!
      end

      it "should handle hashes that are already symbolized" do
        hash_copy = @hash_symbols.dup
        hash_copy.should == @hash_symbols.recursively_symbolize_keys!
        @hash_symbols[:repos][:repo1].should == {:path => "something"}
      end
    end

    describe 'to_conf' do
      it "should convert a hash to sorted YAML" do
        pending "to_conf code"
      end
    end

  end
end

