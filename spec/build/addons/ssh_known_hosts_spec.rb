require 'ostruct'
require 'spec_helper'

describe Travis::Build::Addons::SshKnownHosts, :sexp do
  let(:script) { stub('script') }
  let(:data)   { payload_for(:push, :ruby, config: { addons: { ssh_known_hosts: config } }) }
  let(:sh)     { Travis::Shell::Builder.new }
  let(:addon)  { described_class.new(script, sh, Travis::Build::Data.new(data), config) }
  subject      { sh.to_sexp }
  before       { addon.before_prepare }

  def add_host_cmd(host)
    "ssh-keyscan -t rsa,dsa -H #{host} 2>&1 | tee -a #{Travis::Build::HOME_DIR}/.ssh/known_hosts"
  end

  context 'with multiple host config' do
    let(:config) { ['git.example.org', 'git.example.biz'] }

    # it { should include_sexp [:cmd, add_host_cmd('git.example.org')] }
    # it { should include_sexp [:cmd, add_host_cmd('git.example.biz')] }
    it { should include_sexp [:cmd, add_host_cmd('git.example.org'), echo: true, timing: true] }
    it { should include_sexp [:cmd, add_host_cmd('git.example.biz'), echo: true, timing: true] }
  end

  context 'with singular host config' do
    let(:config) { 'git.example.org' }

    # it { should include_sexp [:cmd, add_host_cmd('git.example.org')] }
    it { should include_sexp [:cmd, add_host_cmd('git.example.org'), echo: true, timing: true] }
  end

  context 'without any hosts' do
    let(:config) { nil }

    # it { should_not include_sexp [:cmd, add_host_cmd('git.example.org')] }
    it { should_not include_sexp [:cmd, add_host_cmd('git.example.org'), echo: true, timing: true] }
  end
end
