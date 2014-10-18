guard 'shotgun' do
  watch(%r{^(app|lib)/.*\.rb})
  watch('application.rb')
  watch('config.ru')
end

guard :rspec, cmd: 'bundle exec rspec', all_on_start: true do
  watch('Guardfile')           { 'spec' }
  watch('Gemfile.lock')        { 'spec' }
  watch('app/application.rb')  { 'spec' }
  watch('spec/spec_helper.rb') { 'spec' }

  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^spec/shared_examples/(.+)\.rb$}) { 'spec' }

  watch(%r{^app/lib/([a-zA-Z_]+).*\.rb$}) { |m| "spec/unit/#{m[1]}" }

  watch(%r{^app/(?!lib)(.*)\.rb}) { 'spec' }
end
