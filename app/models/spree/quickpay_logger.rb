module Spree
  class QuickpayLogger
    def self.debug(message = nil)
      return unless message.present?
      @logger ||= Logger.new(File.join(Rails.root, 'log', 'quickpay.log'))
      @logger.debug(message)
    end

    def self.logger=(logger)
      @logger = logger
    end
  end
end
