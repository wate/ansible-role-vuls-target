require 'spec_helper'

describe user(property['vuls_target_user']) do
  it { should have_authorized_key File.open(File.expand_path('~/.ssh/dummy.pub')).read }
end
