module Spree
  class QuickpayPaymentSource < Spree::Base
    belongs_to :payment_method
    has_many :payments, as: :source

    def actions
      []
    end

    def transaction_id
      payment_id
    end

    def method_type
      'quickpay_payment_source'
    end

    def name
      case payment_method_name
        when ::Quickpay::Method::IDEAL then
          'iDEAL'
        when ::Quickpay::Method::CREDITCARD then
          'Credit card'
        when ::Quickpay::Method::MISTERCASH then
          'Bancontact'
        when ::Quickpay::Method::SOFORT then
          'SOFORT Banking'
        when ::Quickpay::Method::BANKTRANSFER then
          'Bank transfer'
        when ::Quickpay::Method::BITCOIN then
          'Bitcoin'
        when ::Quickpay::Method::PAYPAL then
          'PayPal'
        when ::Quickpay::Method::KBC then
          'KBC/CBC Payment Button'
        when ::Quickpay::Method::BELFIUS then
          'Belfius Pay Button'
        when ::Quickpay::Method::PAYSAFECARD then
          'paysafecard'
        when ::Quickpay::Method::PODIUMCADEAUKAART then
          'Podium Cadeaukaart'
        when ::Quickpay::Method::GIFTCARD then
          'Giftcard'
        when ::Quickpay::Method::INGHOMEPAY then
          'ING Home\'Pay'
        else
          'Quickpay'
      end
    end

    def details
      api_key = payment_method.get_preference(:api_key)
      quickpay_payment = ::Quickpay::Payment.get(payment_id, api_key: api_key)
      quickpay_payment.attributes
    end
  end
end