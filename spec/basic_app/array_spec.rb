require 'spec_helper'

describe Array do

  describe 'recursively_symbolize_keys!' do

    it "should recursively convert a hash with string keys to a hash with symbol keys" do
      hash_symbols = {
                        :options => {
                          :verbose => false,
                        },
                          :repos => {
                             :repo1 => {:path => "something"}
                        }
                      }

      hash_strings = {
                        'options' => {
                          'verbose' => false,
                        },
                          'repos' => {
                             'repo1' => {'path' => "something"}
                        }
                      }

      hash_symbols.should == hash_strings.recursively_symbolize_keys!
    end

    it "should should handle hashes that are already symbolized" do
      hash_symbols = {
                        :options => {
                          :verbose => false,
                        },
                          :repos => {
                             :repo1 => {:path => "something"}
                        }
                      }

      hash_copy = hash_symbols.dup

      hash_copy.should == hash_symbols.recursively_symbolize_keys!
      hash_symbols[:repos][:repo1].should == {:path => "something"}
    end

  end

end

