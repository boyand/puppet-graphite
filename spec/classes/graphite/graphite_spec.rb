require 'spec_helper'

describe 'graphite', :type => :class do

  it { should create_class('graphite::config')}
  it { should create_class('graphite::install')}

  it { should contain_package('whisper')}
  it { should create_exec('carbon')}
  it { should create_exec('graphite-web')}

  it { should contain_service('httpd') }

  it { should contain_file('/opt/graphite/conf/storage-aggregation.conf') }
  it { should contain_file('/opt/graphite/conf/storage-schemas.conf') }

  it { should contain_apache__vhost('graphite').with_port(8888) }

  context 'cluster webapp' do 
    let(:params) { {'memcache_hosts' => ['10.2.1.1','10.2.2.2','10.3.3.3'],
                    'local_ip_address' => '10.2.1.1',
                    'webapp_cluster_nodes' =>  ['10.2.1.1','10.2.2.2','10.3.3.3'],
                    'carbonlink_hosts' => ['127.0.0.1:7002:a','127.0.0.1:7102:b']
                  }}
    it { should contain_file('/opt/graphite/webapp/graphite/local_settings.py').with_content(/^.*\'10.2.1.1:11211\',\'10.2.2.2:11211\'.*$/)}
    it { should contain_file('/opt/graphite/webapp/graphite/local_settings.py').with_content(/^.*\'10.2.2.2:8888\',\'10.3.3.3:8888\'.*$/)}
    it { should contain_file('/opt/graphite/webapp/graphite/local_settings.py').with_content(/^.*\'127.0.0.1:7002:a\',\'127.0.0.1:7102:b\'.*$/)}
  end

  context 'with host' do
    let(:params) { {'port' => 9000} }
    it { should contain_apache__vhost('graphite').with_port(9000) }
  end

  context 'with admin password' do
    let(:params) { {'admin_password' => 'should be a hash' }}
    it { should contain_file('/opt/graphite/webapp/graphite/initial_data.json').with_content(/should be a hash/) }
  end

  context 'with blacklist' do
    let(:params) { {'blacklist' => ['^.*\.nsq.*ephemeral.*','test','test2'] }}
    it { should contain_file('/opt/graphite/conf/blacklist.conf').with_content(/^.*nsq.*$/)}
  end

  context 'with whitelist only' do
    let(:params) { {'whitelist' => ['^.*\.nsq.*ephemeral.*','test','test2'] }}
    it { should contain_file('/opt/graphite/conf/whitelist.conf').with_content(/^.*test2.*$/)}
    it { should_not contain_file('/opt/graphite/conf/blacklist.conf') }
  end

end
