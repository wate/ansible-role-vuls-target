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
  %w[aptitude reboot-notifier].each do |pkg|
    describe package(pkg) do
      it { should be_installed }
    end
  end

  describe file('/etc/sudoers.d/vuls') do
    it { should contain "#{property['vuls_target_user']} ALL=(ALL) NOPASSWD: /usr/bin/apt-get update" }
  end
end

if os[:family] == 'redhat'
  %w[yum-utils yum-plugin-changelog].each do |pkg|
    describe package(pkg) do
      it { should be_installed }
    end
  end

  describe file('/etc/sudoers.d/vuls') do
    rhel_sudo_nopassword_commands = [
      '/usr/bin/yum --color=never repolist',
      '/usr/bin/yum --color=never --security updateinfo list updates',
      '/usr/bin/yum --color=never --security updateinfo updates',
      '/usr/bin/repoquery',
      '/usr/bin/yum --color=never changelog all *'
    ]
    rhel_sudo_nopassword_command = rhel_sudo_nopassword_commands.join(', ')
    it { should contain "#{property['vuls_target_user']} ALL=(ALL) NOPASSWD: " + rhel_sudo_nopassword_command }
  end
end
