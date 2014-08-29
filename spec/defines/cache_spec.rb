require 'spec_helper'

describe 'graphite::cache', :type => :define do
  let(:title) { 'a' }
  let(:params) { {:line_receiver_port => 2023,
                  :pickle_receiver_port => 2024,
                  :cache_query_port => 7022 } }
  let(:pre_condition) { 'include graphite' }

  it { should contain_concat__fragment('header').with(
      :order   => '01',
      :target  => '/opt/graphite/conf/carbon.conf'
    ) }

  it { should contain_concat__fragment('cache-a').with(
      :order   => '10',
      :target  => '/opt/graphite/conf/carbon.conf',
      :content => /^\[cache\:a\].*$/         
    ) }

  it { should contain_file('/etc/init/carbon-cache-a.conf').with_content(/^.*instance a.*$/) }

  it { should contain_service('carbon-cache-a') }


end