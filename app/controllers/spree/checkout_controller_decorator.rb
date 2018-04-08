module Spree
  module CheckoutWithQuickpay
    # If we're currently in the checkout
    def update
      if payment_params_valid? && paying_with_quickpay?
        if @order.update_from_params(params, permitted_checkout_attributes, request.headers.env)
          payment = @order.payments.last
          payment.process!
          quickpay_payment_url = payment.payment_source.payment_url

          QuickpayLogger.debug("For order #{@order.number} redirect user to payment URL: #{quickpay_payment_url}")

          redirect_to quickpay_payment_url
        else
          render :edit
        end
      else
        super
      end
    end
  end

  CheckoutController.class_eval do
    prepend CheckoutWithQuickpay
    private

    def payment_method_id_param
      params[:order][:payments_attributes].first[:payment_method_id]
    end

    def paying_with_quickpay?
      payment_method = PaymentMethod.find(payment_method_id_param)
      payment_method.is_a? Gateway::QuickpayGateway
    end

    def payment_params_valid?
      (params[:state] === 'payment') && params[:order][:payments_attributes]
    end
  end
end