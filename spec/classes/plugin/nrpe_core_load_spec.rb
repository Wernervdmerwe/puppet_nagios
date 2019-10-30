require 'spec_helper'

describe 'nagios::plugin::nrpe_core_load' do
  on_supported_os.each do |os, os_facts|
    print os + "\n"
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end
