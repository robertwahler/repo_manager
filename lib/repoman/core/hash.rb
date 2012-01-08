class Hash

  # sorted yaml
  def to_yaml( opts = {} )
    YAML::quick_emit( object_id, opts ) do |out|
      out.map( taguri, to_yaml_style ) do |map|
        sorted_keys = keys
        sorted_keys = begin
          sorted_keys.sort
        rescue
          sorted_keys.sort_by {|k| k.to_s} rescue sorted_keys
        end

        sorted_keys.each do |k|
          map.add( k, fetch(k) )
        end
      end
    end
  end

  # active_support hash key functions
  def symbolize_keys!
    self.replace(self.symbolize_keys)
  end

  def symbolize_keys
    inject({}) do |options, (key, value)|
      options[(key.to_sym rescue key) || key] = value
      options
    end
  end

  def recursively_symbolize_keys!
    self.symbolize_keys!
    self.values.each do |v|
      if v.is_a? Hash
        v.recursively_symbolize_keys!
      elsif v.is_a? Array
        v.recursively_symbolize_keys!
      end
    end
    self
  end

  def stringify_keys!
    self.replace(self.stringify_keys)
end

  def stringify_keys
    inject({}) do |options, (key, value)|
      options[(key.to_s rescue key) || key] = value
      options
    end
  end

  def recursively_stringify_keys!
    self.stringify_keys!
    self.values.each do |v|
      if v.is_a? Hash
        v.recursively_stringify_keys!
      elsif v.is_a? Array
        v.recursively_stringify_keys!
      end
    end
    self
  end

end
