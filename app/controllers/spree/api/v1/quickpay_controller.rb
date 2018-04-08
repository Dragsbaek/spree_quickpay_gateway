module Spree
  module Api
    module V1
      class QuickpayController < BaseController
        def methods
          quickpay = Spree::PaymentMethod.find_by_type 'Spree::Gateway::QuickpayGateway'
          payment_methods = quickpay.available_payment_methods

          render json: payment_methods
        end
      end
    end
  end
end
