module Spree
  class Gateway::QuickpayGateway < PaymentMethod
    preference :api_key, :string
    preference :hostname, :string

    has_many :spree_quickpay_payment_sources, class_name: 'Spree::QuickpayPaymentSource'

    # Only enable one-click payments if spree_auth_devise is installed
    def self.allow_one_click_payments?
      Gem.loaded_specs.has_key?('spree_auth_devise')
    end

    def payment_source_class
      Spree::QuickpayPaymentSource
    end

    def actions
      %w{credit}
    end

    def provider_class
      ::Quickpay::Client
    end

    # Always create a source which references to the selected Quickpay payment method.
    def source_required?
      true
    end

    def available_for_order?(order)
      true
    end

    def auto_capture?
      true
    end

    # Create a new Quickpay payment.
    def create_transaction(money_in_cents, source, gateway_options)
      QuickpayLogger.debug("About to create payment for order #{gateway_options[:order_id]}")

      begin
        quickpay_payment = ::Quickpay::Payment.create(
            prepare_payment_params(money_in_cents, source, gateway_options)
        )
        QuickpayLogger.debug("Payment #{quickpay_payment.id} created for order #{gateway_options[:order_id]}")

        source.status = quickpay_payment.status
        source.payment_id = quickpay_payment.id
        source.payment_url = quickpay_payment.payment_url
        source.save!
        ActiveMerchant::Billing::Response.new(true, 'Payment created')
      rescue Quickpay::Exception => e
        QuickpayLogger.debug("Could not create payment for order #{gateway_options[:order_id]}: #{e.message}")
        ActiveMerchant::Billing::Response.new(false, "Payment could not be created: #{e.message}")
      end
    end

    # Create a Quickpay customer which can be passed with a payment.
    # Required for one-click Quickpay payments.
    def create_customer(user)
      customer = Quickpay::Customer.create(
          email: user.email,
          api_key: get_preference(:api_key),
          )
      QuickpayLogger.debug("Created a Quickpay Customer for Spree user with ID #{customer.id}")
      customer
    end

    def prepare_payment_params(money_in_cents, source, gateway_options)
      spree_routes = ::Spree::Core::Engine.routes.url_helpers
      order_number = gateway_options[:order_id]
      customer_id = gateway_options[:customer_id]
      amount = money_in_cents / 100.0

      order_params = {
          amount: amount,
          description: "Spree Order: #{order_number}",
          redirectUrl: spree_routes.quickpay_validate_payment_quickpay_url(
              order_number: order_number,
              host: get_preference(:hostname)
          ),
          webhookUrl: spree_routes.quickpay_update_payment_status_quickpay_url(
              order_number: order_number,
              host: get_preference(:hostname)
          ),
          method: source.payment_method_name,
          metadata: {
              order_id: order_number
          },
          api_key: get_preference(:api_key),
      }

      source.issuer.present?
      order_params.merge! ({
        issuer: source.issuer
      })

      if customer_id.present?
        if source.payment_method_name.match(Regexp.union([::Quickpay::Method::BITCOIN, ::Quickpay::Method::BANKTRANSFER, ::Quickpay::Method::GIFTCARD]))
          order_params.merge! ({
              billingEmail: gateway_options[:email]
          })
        end

        if Spree::Gateway::QuickpayGateway.allow_one_click_payments?
          quickpay_customer_id = Spree.user_class.find(customer_id).try(:quickpay_customer_id)

          # Allow one-click payments by passing Quickpay customer ID.
          if quickpay_customer_id.present?
            order_params.merge! ({
                customerId: quickpay_customer_id
            })
          end
        end
      end

      order_params
    end

    # Create a new Quickpay refund
    def credit(credit_cents, payment_id, options)
      order_number = options[:originator].try(:payment).try(:order).try(:number)
      QuickpayLogger.debug("Starting refund for order #{order_number}")

      begin
        amount = credit_cents / 100.0
        Quickpay::Payment::Refund.create(
            payment_id: payment_id,
            amount: amount,
            description: "Refund Spree Order ID: #{order_number}",
            api_key: get_preference(:api_key)
        )
        QuickpayLogger.debug("Successfully refunded #{amount} for order #{order_number}")
        ActiveMerchant::Billing::Response.new(true, 'Refund successful')
      rescue Quickpay::Exception => e
        QuickpayLogger.debug("Refund failed for order #{order_number}: #{e.message}")
        ActiveMerchant::Billing::Response.new(false, 'Refund unsuccessful')
      end
    end

    def available_payment_methods
      ::Quickpay::Method.all(
          api_key: get_preference(:api_key),
          include: 'issuers'
      )
    end

    def update_payment_status(payment)
      quickpay_transaction_id = payment.source.payment_id
      quickpay_payment = ::Quickpay::Payment.get(
          quickpay_transaction_id,
          api_key: get_preference(:api_key)
      )

      QuickpayLogger.debug("Updating order state for payment. Payment has state #{quickpay_payment.status}")

      update_by_quickpay_status!(quickpay_payment, payment)
    end

    def update_by_quickpay_status!(quickpay_payment, payment)
      case quickpay_payment.status
        when 'paid'
          payment.complete! unless payment.completed?
          payment.order.finalize!
          payment.order.update_attributes(:state => 'complete', :completed_at => Time.now)
        when 'cancelled', 'expired', 'failed'
          payment.failure! unless payment.failed?
        when 'refunded'
          payment.void! unless payment.void?
        else
          QuickpayLogger.debug('Unhandled Quickpay payment state received. Therefore we did not update the payment state.')
      end

      payment.source.update(status: payment.state)
    end
  end
end
