require 'spec_helper'

describe Travis::Notification::Instrument::Task::Irc do
  include Travis::Testing::Stubs

  let(:data)      { Travis::Api.data(build, :for => 'event', :version => 'v2') }
  let(:task)      { Travis::Task::Irc.new(data, :channels => { ['irc.freenode.net', 1234] => ['travis'] }) }
  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:event)     { publisher.events[1] }

  before :each do
    # TODO ...
    Travis::Features.stubs(:active?).returns(true)
    Repository.stubs(:find).returns(repository)
    Url.stubs(:shorten).returns(url)

    Travis::Notification.publishers.replace([publisher])
    task.stubs(:process!)
    task.process
  end

  it 'publishes a payload' do
    event.except(:payload).should == {
      :message => "travis.task.irc.process:completed",
            :uuid => Travis.uuid
    }
    event[:payload].except(:data).should == {
      :msg => 'Travis::Task::Irc#process for #<Build id=1>',
      :repository => 'svenfuchs/minimal',
      :object_id => 1,
      :object_type => 'Build',
      :channels => { ['irc.freenode.net', 1234] => ['travis'] },
      :messages => [
        'svenfuchs/minimal#2 (master - 62aae5f : Sven Fuchs): The build passed.',
        'Change view : http://trvs.io/short',
        'Build details : http://trvs.io/short'
      ]
    }
    event[:payload][:data].should_not be_nil
  end
end

