class Array
  def recursively_symbolize_keys!
    self.each do |item|
      if item.is_a? Hash
        item.recursively_symbolize_keys!
      elsif item.is_a? Array
        item.recursively_symbolize_keys!
      end
    end
  end

  def recursively_stringify_keys!
    self.each do |item|
      if item.is_a? Hash
        item.recursively_stringify_keys!
      elsif item.is_a? Array
        item.recursively_stringify_keys!
      end
    end
  end
end
