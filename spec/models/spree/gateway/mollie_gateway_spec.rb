require 'spec_helper'

RSpec.describe Spree::Gateway::QuickpayGateway, type: :model do
  let(:gateway) {create(:quickpay_gateway, auto_capture: true)}
  let(:payment) {create(:quickpay_payment, payment_method: gateway)}
  let(:payment_source) {payment.payment_source}
  let(:order) {OrderWalkthrough.up_to(:payment)}
  let(:process_quickpay_payment!) {payment.process!}
  let(:add_payment_to_order!) {order.payments << payment}
  let(:quickpay_api_payment) {create(:quickpay_api_payment)}

  describe 'payment state updating' do
    let!(:complete_order!) do
      add_payment_to_order!
      order.next!
    end

    context 'with paid Quickpay payment' do
      it 'should set payment state to paid for paid Quickpay payment' do
        quickpay_api_payment.status = 'paid'
        gateway.update_by_quickpay_status!(quickpay_api_payment, payment)
        expect(payment.state).to eq 'completed'
      end

      it 'should set order state to complete for paid Quickpay payment' do
        quickpay_api_payment.status = 'paid'
        gateway.update_by_quickpay_status!(quickpay_api_payment, payment)
        expect(payment.order.state).to eq 'complete'
      end
    end

    it 'should set payment state to failed for cancelled Quickpay payment' do
      quickpay_api_payment.status = 'cancelled'
      gateway.update_by_quickpay_status!(quickpay_api_payment, payment)
      expect(payment.state).to eq 'failed'
    end

    it 'should set payment state to failed for expired Quickpay payment' do
      quickpay_api_payment.status = 'expired'
      gateway.update_by_quickpay_status!(quickpay_api_payment, payment)
      expect(payment.state).to eq 'failed'
    end

    it 'should set payment state to failed for failed Quickpay payment' do
      quickpay_api_payment.status = 'failed'
      gateway.update_by_quickpay_status!(quickpay_api_payment, payment)
      expect(payment.state).to eq 'failed'
    end

    it 'should set payment state to void for refunded Quickpay payment' do
      quickpay_api_payment.status = 'refunded'
      gateway.update_by_quickpay_status!(quickpay_api_payment, payment)
      expect(payment.state).to eq 'void'
    end

    context 'payment method' do
      it 'should have a list of payment methods' do
        expect(gateway.available_payment_methods.first).to be_an_instance_of(Quickpay::Method)
      end

      it 'should have nested issuers on payment methods' do
        expect(gateway.available_payment_methods.first.issuers.first).to include('id' => 'ideal_TESTNL99', 'method' => 'ideal')
      end
    end
  end
end