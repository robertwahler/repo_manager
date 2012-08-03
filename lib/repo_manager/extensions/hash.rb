# This is a modified version of the unreleased (as of 3/9/2012) Hashie Version 2
#
# It is modified to always convert new attributes to symbols and
# return nil if missing attribute so it works more like OpenStruct but
# still retains Hash as super
module RepoManager
  module Extensions

    # MethodReader allows you to access keys of the hash
    # via method calls. This gives you an OStruct like way
    # to access your hash's keys. It will recognize keys
    # either as strings or symbols.
    #
    # @example Extending the Hash class
    #
    #     class User < Hash
    #       include RepoManager::Extensions::MethodReader
    #     end
    #
    #     user = User.new
    #     user['first_name'] = 'Michael'
    #     user.first_name # => 'Michael'
    #
    #     user[:last_name] = 'Bleigh'
    #     user.last_name # => 'Bleigh'
    #
    #     user[:birthday] = nil
    #     user.birthday # => nil
    #
    #     user.not_declared # => nil
    #
    module MethodReader
      def respond_to?(name)
        return true if key?(name.to_s) || key?(name.to_sym)
        super
      end

      def method_missing(name, *args)
        return self[name.to_s] if key?(name.to_s)
        return self[name.to_sym] if key?(name.to_sym)

        # mod to return nil instead of 'undefined method'
        return nil if args.length == 0

        super
      end
    end

    # MethodWriter gives you #key_name= shortcuts for
    # writing to your hash. Keys are written as symbols
    #
    # Note that MethodWriter also overrides #respond_to such
    # that any #method_name= will respond appropriately as true.
    #
    # @example
    #
    #     class MyHash < Hash
    #       include RepoManager::Extensions::MethodWriter
    #     end
    #
    #     h = MyHash.new
    #     h.awesome = 'sauce'
    #     h['awesome'] # => 'sauce'
    #
    module MethodWriter
      def respond_to?(name)
        return true if name.to_s =~ /=$/
        super
      end

      def method_missing(name, *args)
        if args.size == 1 && name.to_s =~ /(.*)=$/
          return self[convert_key($1)] = args.first
        end

        super
      end

      def convert_key(key)
        # mod to return symbol keys instead of string keys
        key.to_sym
      end
    end

  end
end
