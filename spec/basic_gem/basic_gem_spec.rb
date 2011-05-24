require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Repoman do
  
  describe 'version' do

    it "should return a string formatted '#.#.#'" do
      Repoman::version.should match(/(^[\d]+\.[\d]+\.[\d]+$)/)
    end

  end

end
