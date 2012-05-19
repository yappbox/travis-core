require 'spec_helper'
require 'travis/api'
require 'travis/api/support/stubs'

describe Travis::Api::Json::Http::Organizations do
  include Support::Stubs, Support::Formats

  let(:data) { Travis::Api::Json::Http::Organizations.new([organization]).data }

  it 'data' do
    data.first.should == {
      'id' => organization.id,
      'name' => organization.name,
      'login' => organization.login,
    }
  end
end
