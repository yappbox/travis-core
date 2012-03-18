require 'spec_helper'

describe Travis::GithubApi do

  describe ".add_service_hook" do

    it "should add a service hook" do
      client_stub = stub.tap do |client|
        client.expects(:subscribe_service_hook).with('owner/name', 'Travis', {})
      end

      Octokit::Client.stubs(:new).
        with(:oauth_token => 't0k3n').
        returns(client_stub)

      Travis::GithubApi.add_service_hook('owner', 'name', 't0k3n', {})
    end

    it "should raise an error when an unprocessable entity error occurs" do
      Octokit::Client.stubs(:new).raises(Octokit::UnprocessableEntity)
      expect {
        Travis::GithubApi.add_service_hook('owner', 'name', 't0k3n', {})
      }.to raise_error Travis::GithubApi::ServiceHookError, 'error subscribing to the GitHub push event'
    end

    it "should raise an error when an unauthorized error occurs" do
      Octokit::Client.stubs(:new).raises(Octokit::Unauthorized)
      expect {
        Travis::GithubApi.add_service_hook('owner', 'name', 't0k3n', {})
      }.to raise_error Travis::GithubApi::ServiceHookError, 'error authorizing with given GitHub OAuth token'
    end

  end

  describe ".remove_service_hook" do

    it "should remove a service hook" do
      client_stub = stub.tap do |client|
        client.expects(:unsubscribe_service_hook).with('owner/name', 'Travis')
      end

      Octokit::Client.stubs(:new).
        with(:oauth_token => 't0k3n').
        returns(client_stub)

      Travis::GithubApi.remove_service_hook('owner', 'name', 't0k3n')
    end

    it "should raise an error when an unprocessable entity error occurs" do
      Octokit::Client.stubs(:new).raises(Octokit::UnprocessableEntity)
      expect {
        Travis::GithubApi.remove_service_hook('owner', 'name', 't0k3n')
      }.to raise_error Travis::GithubApi::ServiceHookError, 'error unsubscribing from the GitHub push event'
    end

  end

  describe '.repositories_for_user' do

    it 'should get all repositories' do
      client_stub = stub.tap do |client|
        client.expects(:repositories).with('owner', {:per_page => 100})
      end

      Octokit::Client.stubs(:new).
        with(:auto_traversal => true).
        returns(client_stub)

      Travis::GithubApi.repositories_for_user('owner')
    end

  end

end
