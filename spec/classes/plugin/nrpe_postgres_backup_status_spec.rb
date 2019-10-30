require 'spec_helper'

describe 'nagios::plugin::nrpe_postgres_backup_status' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end
