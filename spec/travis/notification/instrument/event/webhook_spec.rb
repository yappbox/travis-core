require 'spec_helper'

describe Travis::Notification::Instrument::Event::Handler::Webhook do
  include Travis::Testing::Stubs

  let(:build)     { stub_build(:config => { :notifications => { :webhooks => 'http://example.com' } }) }
  let(:handler)   { Travis::Event::Handler::Webhook.new('build:finished', build) }
  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:event)     { publisher.events[1] }

  before :each do
    Travis::Notification.publishers.replace([publisher])
    handler.stubs(:handle)
    handler.notify
  end

  it 'publishes a payload' do
    event.except(:payload).should == {
      :message => "travis.event.handler.webhook.notify:completed",
      :uuid => Travis.uuid
    }
    event[:payload].except(:payload).should == {
      :msg => 'Travis::Event::Handler::Webhook#notify(build:finished) for #<Build id=1>',
      :repository => 'svenfuchs/minimal',
      :request_id => 1,
      :object_id => 1,
      :object_type => 'Build',
      :event => 'build:finished',
      :targets => ['http://example.com']
    }
    event[:payload][:payload].should_not be_nil
  end
end
