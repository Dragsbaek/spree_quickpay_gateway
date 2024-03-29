Spree::Payment.class_eval do
  delegate :transaction_id, to: :source

  def build_source
    return unless new_record?
    if source_attributes.present? && source.blank? && payment_method.try(:payment_source_class)
      self.source = payment_method.payment_source_class.new(source_attributes)
      source.payment_method_id = payment_method.id
      source.user_id = order.user_id if order

      # Spree will not process payments if order is completed.
      # We should call process! for completed orders to create a new Quickpay payment.
      process! if order.completed?
    end
  end
end