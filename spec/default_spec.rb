require 'spec_helper'

describe package('aptitude'), if: os[:family] == 'debian' do
  it { should be_installed }
end

describe package('reboot-notifier'), if: os[:family] == 'debian' do
  it { should be_installed }
end

describe package('yum-utils'), if: os[:family] == 'redhat' do
  it { should be_installed }
end

describe package('yum-plugin-changelog'), if: os[:family] == 'redhat' do
  it { should be_installed }
end

describe user(property['vuls_target_user']) do
  it { should exist }
  it { should have_authorized_key File.open(File.expand_path('~/.ssh/dummy.pub')).read }
end

describe file('/etc/sudoers.d/vuls') do
  it { should exist }
  it { should be_file }
end

describe file('/etc/sudoers.d/vuls'), if: os[:family] == 'redhat' do
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

describe file('/etc/sudoers.d/vuls'), if: os[:family] == 'debian' do
  it { should contain "#{property['vuls_target_user']} ALL=(ALL) NOPASSWD: /usr/bin/apt-get update" }
end
