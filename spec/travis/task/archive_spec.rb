require 'spec_helper'

describe Travis::Task::Archive do
  include Travis::Testing::Stubs, Support::Formats, Support::ActiveRecord

  let(:url)      { 'http://username:password@host/builds/1' }
  let(:data)     { Travis::Api.data(build, :for => 'archive', :version => 'v1') }
  let(:task)     { Travis::Task::Archive.new(data, :url => url) }
  let(:http)     { stub('http', :put => response) }
  let(:response) { stub('response', :success? => true) }

  before do
    task.stubs(:http).returns(http)
    Build.stubs(:find_by_id).returns(build) # TODO remove the db dependency, somehow
    build.stubs(:touch)
    Travis.config.archive = { :host => 'host', :username => 'username', :password => 'password' }
  end

  describe 'run' do
    it 'posts to the archive url' do
      http.expects(:put).with { |url, body| url == self.url }.returns(response)
      task.run
    end

    it 'posts the build payload' do
      http.expects(:put).with { |url, data| data == self.data.to_json }.returns(response)
      task.run
    end

    it 'sets the build to be archived' do
      build.expects(:touch).with(:archived_at)
      task.run
    end
  end

  describe 'logging' do
    it 'logs a successful request' do
      task.expects(:info).with("Successfully archived to #{url}.")
      task.run
    end

    it 'warns about a failed request' do
      http.stubs(:put).raises(Faraday::Error::ClientError.new(:status => 403, :body => 'nono.'))
      Travis::Exceptions.expects(:handle).with do |exception|
        exception.message == '[task] Travis::Task::Archive: (Faraday::Error::ClientError) the server responded with status 403 (http://username:password@host/builds/1): 403 nono.'
      end
      task.run
    end
  end
end
