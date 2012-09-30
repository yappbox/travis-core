require 'spec_helper'

describe Travis::Task::Github do
  include Travis::Testing::Stubs, Support::Formats

  let(:url)  { 'https://api.github.com/repos/travis-repos/test-project-1/issues/1/comments' }
  let(:data) { Travis::Api.data(build, :for => 'event', :version => 'v2') }
  let(:task) { Travis::Task::Github.new(data, :url => url) }

  before do
    GH.stubs(:post)
    task.stubs(:has_access?).returns(true)
  end

  describe 'run' do
    it 'posts to the request comments_url' do
      GH.expects(:post).with do |url, body|
        url == self.url
      end
      task.run
    end

    it 'posts a comment to github (passing)' do
      build.stubs(:result).returns(0)
      GH.expects(:post).with do |url, data|
        data[:body] == "This pull request [passes](http://travis-ci.org/svenfuchs/minimal/builds/#{build.id}) (merged #{request.head_commit[0..7]} into #{request.base_commit[0..7]})."
      end
      task.run
    end

    it 'posts a comment to github' do
      data['build']['result'] = 1
      GH.expects(:post).with do |url, data|
        puts data[:body]
        data[:body] == "This pull request [fails](http://travis-ci.org/svenfuchs/minimal/builds/#{build.id}) (merged #{request.head_commit[0..7]} into #{request.base_commit[0..7]})."
      end
      task.run
    end

    it 'authenticates as travisbot using the token' do
      GH.expects(:with).with do |options|
        options[:token] == 'travisbot-token'
      end
      task.run
    end
  end

  describe 'logging' do
    it 'warns about a failed request' do
      GH.stubs(:post).raises(GH::Error.new(nil, nil))
      Travis::Exceptions.expects(:handle).with { |e| e.is_a?(Travis::Task::Exceptions::GHError) }
      task.run
    end
  end
end

