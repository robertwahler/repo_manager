# @examples
#
#     guard --group specs
#     guard --group features
#
group :specs do
  guard 'rspec',
        :all_after_pass => false,
        :all_on_start => false,
        :cli => '--color --format nested --fail-fast',
        :version => 2 do

    watch(%r{^spec/.+_spec\.rb$})
    watch('spec/spec_helper.rb')                              { "spec" }

    # ex: lib/app_name/views.rb -> spec/app_name/views_spec.rb
    watch(%r{^lib/(.+)/(.+)\.rb$})                                 { |m| "spec/#{m[1]}/#{m[2]}_spec.rb" }

    # ex: lib/app_name/views/view_helper.rb -> spec/app_name/views/view_helper_spec.rb
    watch(%r{^lib/(.+)/(.+)/(.+)\.rb$})                                 { |m| "spec/#{m[1]}/#{m[2]}/#{m[3]}_spec.rb" }
  end
end

group :features do
  guard 'cucumber',
        # focus on wip
        #:cli => '--color --format pretty --profile wip',
        # normal, ignore wip
        :cli => '--color --format pretty --strict --tags ~wip',
        :all_after_pass => false,
        :all_on_start => false do

    watch(%r{^features/.+\.feature$})
    watch(%r{^features/support/.+$})                          { "features" }
    watch(%r{^features/step_definitions/(.+)_steps\.rb$})     { |m| Dir[File.join("**/#{m[1]}.feature")][0] || "features" }
  end
end
