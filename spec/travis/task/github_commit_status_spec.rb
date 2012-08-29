require 'spec_helper'

describe Travis::Task::GithubCommitStatus do
  include Travis::Testing::Stubs, Support::Formats

  let(:url)       { "https://api.github.com/repos/travis-repos/test-project-1/statuses/#{sha}" }
  let(:build_url) { 'http://travis-ci.org/#!/travis-repos/test-project-1/1234' }
  let(:sha)       { 'ab2784e55bcf71ac9ef5f6ade8e02334c6524eea' }
  let(:token)     { '12345' }
  let(:data)      { Travis::Api.data(build, :for => 'event', :version => 'v2') }
  let(:task)      { Travis::Task::GithubCommitStatus.new(data, :url => url, :sha => sha, :build_url => build_url, :token => token) }

  before :each do
    GH.stubs(:post)
  end

  describe 'run' do
    it 'posts to the pull requests statuses sha url' do
      GH.expects(:post).with do |url, body|
        url == self.url
      end
      task.run
    end

    it 'sets the status of the commit to pending' do
      build.stubs(:result).returns(nil)
      GH.expects(:post).with do |url, data|
        data == { :description => 'The Travis build is in progress', :target_url => build_url, :state => 'pending' }
      end
      task.run
    end

    it 'sets the status of the commit to success' do
      build.stubs(:result).returns(0)
      GH.expects(:post).with do |url, data|
        data == { :description => 'The Travis build passed', :target_url => build_url, :state => 'success' }
      end
      task.run
    end

    it 'sets the status of the commit to failure' do
      build.stubs(:result).returns(1)
      GH.expects(:post).with do |url, data|
        data == { :description => 'The Travis build failed', :target_url => build_url, :state => 'failure' }
      end
      task.run
    end

    it 'authenticates using the token passed into the task' do
      GH.expects(:with).with do |options|
        options[:token] == token
      end
      task.run
    end
  end

  describe 'logging' do
    it 'logs a successful request' do
      task.expects(:info).with("Successfully updated the PR status on #{url}.")
      task.run
    end

    it 'warns about a failed request' do
      GH.stubs(:post).raises(Faraday::Error::ClientError.new(:status => 403, :body => 'nono.'))
      Travis::Exceptions.expects(:handle).with { |e| e.is_a?(Travis::Task::Exceptions::FaradayError) }
      task.run
    end
  end
end

