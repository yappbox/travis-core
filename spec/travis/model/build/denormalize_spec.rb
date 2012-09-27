require 'spec_helper'

describe Build, 'denormalization' do
  include Support::ActiveRecord

  let(:repository) { build.repository }

  describe 'for a push request' do
    let(:build) { Factory(:build, :duration => 30) }

    describe 'on build:started' do
      before :each do
        build.denormalize(:start)
        build.reload
      end

      it 'denormalizes last_build_id to its repository' do
        repository.last_build_id.should == build.id
      end

      it 'denormalizes last_build_number to its repository' do
        repository.last_build_number.should == build.number
      end

      it 'denormalizes last_build_duration to its repository' do
        repository.last_build_duration.should == build.duration
      end

      it 'denormalizes last_build_started_at to its repository' do
        repository.last_build_started_at.should == build.started_at
      end

      it 'denormalizes last_build_finished_at to its repository' do
        repository.last_build_finished_at.should == build.finished_at
      end
    end

    describe 'on build:finished' do
      before :each do
        build.denormalize(:finish, :result => 0)
        build.reload
      end

      it 'denormalizes last_build_result to its repository' do
        repository.last_build_result.should == build.result
      end

      it 'denormalizes last_build_duration to its repository' do
        repository.last_build_duration.should == build.duration
      end

      it 'denormalizes last_build_finished_at to its repository' do
        repository.last_build_finished_at.should == build.finished_at
      end
    end
  end

  describe 'for a pull request request' do
    let(:push) { Factory(:build, :duration => 30) }

    let(:build) do
      build = Factory(:build, :duration => 30)
      build.stubs(:pull_request?).returns(true)
      build
    end

    describe 'on build:started' do
      before :each do
        push.denormalize(:start)
        build.denormalize(:start)
        build.reload
      end

      it 'denormalizes last_build_id to its repository' do
        repository.last_build_id.should == push.id
      end

      it 'denormalizes last_build_number to its repository' do
        repository.last_build_number.to_i.should == push.number.to_i
      end

      it 'denormalizes last_build_duration to its repository' do
        repository.last_build_duration.should == push.duration
      end

      it 'denormalizes last_build_started_at to its repository' do
        repository.last_build_started_at.should == push.started_at
      end

      it 'denormalizes last_build_finished_at to its repository' do
        repository.last_build_finished_at.should == push.finished_at
      end
    end

    describe 'on build:finished' do
      before :each do
        push.denormalize(:finish)
        build.denormalize(:finish, :result => 0)
        build.reload
      end

      it 'denormalizes last_build_result to its repository' do
        repository.last_build_result.should == push.result
      end

      it 'denormalizes last_build_duration to its repository' do
        repository.last_build_duration.should == push.duration
      end

      it 'denormalizes last_build_finished_at to its repository' do
        repository.last_build_finished_at.should == push.finished_at
      end
    end
  end
end

