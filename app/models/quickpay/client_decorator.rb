Quickpay::Client.class_eval do
  attr_accessor :version_strings

  def initialize(api_key = nil)
    @api_endpoint = Quickpay::Client::API_ENDPOINT
    @api_key = api_key
    @version_strings = []

    add_version_string 'QuickpaySpreeCommerce/' << SpreeQuickpayGateway::VERSION
    add_version_string 'Ruby/' << RUBY_VERSION
    add_version_string OpenSSL::OPENSSL_VERSION.split(' ').slice(0, 2).join '/'
  end
end