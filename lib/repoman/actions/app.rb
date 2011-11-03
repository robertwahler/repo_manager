####################################################
# The file is was originally cloned from "Basic App"
# More information on "Basic App" can be found in the
# "Basic App" repository.
#
# See http://github.com/robertwahler
####################################################
module Repoman

  # An abstract superclass for basic action functionality specific to an
  # application implementation.  Put application specific code here.
  class AppAction < BaseAction

    # @return [Array] of Repo
    def repos(filters=['.*'])
      raise "config file not found" unless configuration[:repo_configuration_filename]
      match_count = 0
      filters = ['.*'] if filters.empty?
      base_dir = File.dirname(configuration[:repo_configuration_filename])
      result = []
      repo_config = configuration[:repos]
      repo_config.keys.sort_by{ |sym| sym.to_s}.each do |key|
        name = key.to_s
        attributes = {:name => name, :base_dir => base_dir}
        attributes = attributes.merge(repo_config[key]) if repo_config[key]
        path = attributes[:path]
        if filters.find {|filter| matches?(name, filter)}
          result << Repoman::Repo.new(path, attributes.dup)
          match_count += 1
          break if ((options[:match] == 'FIRST') || (options[:match] == 'EXACT'))
          raise "match mode = ONE, multiple repos found" if (options[:match] == 'ONE' && match_count > 1)
        end
      end
      result
    end

    private

    def matches?(str, filter)
      if (options[:match] == 'EXACT')
        str == filter
      else
        str.match(/#{filter}/)
      end
    end

  end
end
