source 'https://rubygems.org'

group :rake, :development, :test do
  gem 'rspec-puppet', '>=1.0.1'
  gem 'rake',         '>=0.9.2.2'
  gem 'puppet-lint',  '>=0.1.12'
  gem 'puppetlabs_spec_helper', :require => false
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end
