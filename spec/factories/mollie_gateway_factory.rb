FactoryBot.define do
  factory :quickpay_gateway, class: Spree::Gateway::QuickpayGateway do
    name 'Quickpay Payment Gateway'

    before(:create) do |gateway|
      gateway.preferences[:api_key] = ENV['quickpay_API_KEY']
      gateway.preferences[:hostname] = 'https://example.com'
    end
  end
end
