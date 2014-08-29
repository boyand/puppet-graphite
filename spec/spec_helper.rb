require 'puppetlabs_spec_helper/module_spec_helper'

RSpec.configure do |c|

  c.treat_symbols_as_metadata_keys_with_true_values = true

  c.before :each do
    # Ensure that we don't accidentally cache facts and environment
    # between test cases.
    Facter::Util::Loader.any_instance.stubs(:load_all)
    Facter.clear
    Facter.clear_messages

    # Store any environment variables away to be restored later
    @old_env = {}
    ENV.each_key {|k| @old_env[k] = ENV[k]}

    c.default_facts = {
      :kernel          => 'Linux',
      :concat_basedir  => '/var/lib/puppet/concat',
      :lsbdistid       => 'Ubuntu',
      :operatingsystem => 'Ubuntu',
      :osfamily        => 'Debian',
      :lsbdistcodename        => 'precise',
      :lsbdistdescription     => 'Ubuntu 12.04.2 LTS',
      :lsbdistrelease         => '12.04',
      :lsbmajdistrelease      => '12',
      :operatingsystemrelease => '12.04',
    }

    if ENV['STRICT_VARIABLES'] == 'yes'
      Puppet.settings[:strict_variables]=true
    end
  end
end

shared_examples :compile, :compile => true do
  it { should compile.with_all_deps }
end
