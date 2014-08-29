require 'spec_helper'

describe 'graphite::relay', :type => :define do
  let(:title) { 'a' }
  let(:params) { {:line_receiver_port => 2033,
                  :pickle_receiver_port => 2034,
                  :relay_method => 'consistent_hashing',
                  :replication_factor => 2,
                  :destinations => ['127.0.0.1', '192.168.10.1'],
                  :carboncache_instances => ['2013:a','2014:b']
  } }
  let(:pre_condition) { 'include graphite' }

  it { should contain_concat__fragment('header').with(
      :order   => '01',
      :target  => '/opt/graphite/conf/carbon.conf'
  ) }

  it { should contain_concat__fragment('relay-a').with(
      :order   => '20',
      :target  => '/opt/graphite/conf/carbon.conf',
      :content => /^\[relay\:a\].*$/
  ) }

  it { should contain_file('/etc/init/carbon-relay-a.conf').with_content(/^.*instance a.*$/) }

  it { should contain_service('carbon-relay-a') }

end