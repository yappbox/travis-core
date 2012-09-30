require 'spec_helper'

describe Travis::Notification::Instrument::Task::Archive do
  include Travis::Testing::Stubs

  let(:data)      { Travis::Api.data(build, :for => 'archive', :version => 'v1') }
  let(:task)      { Travis::Task::Archive.new(data) }
  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:event)     { publisher.events[1] }

  before :each do
    Travis::Notification.publishers.replace([publisher])
    task.stubs(:process!)
    task.process
  end

  it 'publishes a payload' do
    publisher.events
    event.except(:payload).should == {
      :message => "travis.task.archive.process:completed",
      :uuid => Travis.uuid
    }
    event[:payload].except(:data).should == {
      :msg => 'Travis::Task::Archive#process for #<Build id=1>',
      :repository => 'svenfuchs/minimal',
      :object_id => 1,
      :object_type => 'Build'
    }
    event[:payload][:data].should_not be_nil
  end
end

