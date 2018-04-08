require 'spec_helper'

RSpec.describe Quickpay::Client, type: :model do
  let(:client) {Quickpay::Client.new}

  it 'set the correct version string' do
    expect(client.version_strings.first).to include 'QuickpaySpreeCommerce'
  end
end