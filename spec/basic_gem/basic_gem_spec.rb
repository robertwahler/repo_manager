require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BasicApp do
  
  describe 'VERSION' do

    it "should return a string formatted '#.#.#'" do
      BasicApp::VERSION.should match(/(^[\d]+\.[\d]+\.[\d]+$)/)
    end

  end

end
