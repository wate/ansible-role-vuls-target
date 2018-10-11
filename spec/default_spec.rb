require 'spec_helper'

describe user(property['vuls_target_user']) do
  it { should exist }
end

describe file('/etc/sudoers.d/vuls') do
  it { should exist }
  it { should be_file }
  target_user = property['vuls_target_user']
  it { should contain "Defaults:#{target_user} env_keep=\"http_proxy https_proxy HTTP_PROXY HTTPS_PROXY\"" }
  it { should contain "Defaults:#{target_user} !requiretty" }
end

if os[:family] == 'debian'
  %w[debian-goodies aptitude reboot-notifier].each do |pkg|
    describe package(pkg) do
      it { should be_installed }
    end
  end
  debian_sudo_nopassword_commands = [
    '/usr/bin/apt-get update',
    '/usr/bin/stat *',
    '/usr/sbin/checkrestart'
  ]
  debian_sudo_nopassword_command = debian_sudo_nopassword_commands.join(', ')
  describe file('/etc/sudoers.d/vuls') do
    it { should contain "#{property['vuls_target_user']} ALL=(ALL) NOPASSWD: " + debian_sudo_nopassword_command }
  end
end

if os[:family] == 'redhat'
  %w[yum-plugin-ps yum-plugin-changelog].each do |pkg|
    describe package(pkg) do
      it { should be_installed }
    end
  end

  describe file('/etc/sudoers.d/vuls') do
    rhel_sudo_nopassword_commands = [
      '/usr/bin/yum -q ps all --color=never',
      '/usr/bin/stat',
      '/usr/bin/needs-restarting',
      '/usr/bin/which'
    ]
    rhel_sudo_nopassword_command = rhel_sudo_nopassword_commands.join(', ')
    it { should contain "#{property['vuls_target_user']} ALL=(ALL) NOPASSWD: " + rhel_sudo_nopassword_command }
  end
end
