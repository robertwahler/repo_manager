module Repoman

  module AssetAccessors

    # Given an array, create accessors
    # NOTE: This is similar to using method_missing with a whitelist
    #
    # @return [void]
    def create_accessors(*attrs)
      return unless attrs
      raise ArgumentError, "Expected 'user_attributes' to be an array" unless attrs.is_a? Array

      # Define each of the attributes
      attrs.flatten.each do |attr|
        create_accessor(attr)
      end
    end

    def create_accessor(attr)
      create_reader(attr)
      create_writer(attr)
    end

    def create_reader(attr)
      return unless attr

      method = "#{attr}".to_sym

      if self.kind_of? Repoman::BaseAsset
        return if self.respond_to? method

        self.class.send(:define_method, method) do
          render(attributes[method])
        end
      else
        return if respond_to? method

        define_method(method) do
          render(attributes[method])
        end
      end
    end

    def create_writer(attr)
      return unless attr

      method = "#{attr}=".to_sym

      if self.kind_of? Repoman::BaseAsset
        return if self.respond_to? method

        self.class.send(:define_method, method) do |value|
          attributes[attr] = value
        end
      else
        return if respond_to? method

        define_method(method) do |value|
          attributes[attr] = value
        end
      end

    end

  end

end
