require 'spec_helper'

describe Travis::Github::Sync::Repositories do
  include Support::ActiveRecord

  let(:user) { Factory(:user) }
  let(:sync) { Travis::Github::Sync::User.new(user) }

  describe 'can_sync?' do
    before :each do
      GH.stubs(:[]).returns stub(:headers => { 'x-ratelimit-remaining' => 5000 })
    end

    it 'returns false if the user is syncing' do
      user.is_syncing = true
      sync.can_sync?.should be_false
    end

    it 'returns false if the remaining rate limit for this user is lesser than 1000' do
      GH.stubs(:[]).returns stub('data', :headers => { 'x-ratelimit-remaining' => 999 })
      sync.can_sync?.should be_false
    end

    it 'returns true if the user is not syncing and the rate limit is greater than 1000' do
      sync.can_sync?.should be_true
    end
  end

  describe 'syncing' do
    it 'returns the block value' do
      sync.syncing { 42 }.should == 42
    end

    it 'sets is_syncing?' do
      user.should_not be_syncing
      sync.syncing { user.should be_syncing }
      user.should_not be_syncing
    end

    it 'sets synced_at' do
      time = Time.now
      sync.syncing { }
      user.synced_at.should >= time
    end
  end
end
