Spree::Core::Engine.routes.draw do
  resource :quickpay, only: [], controller: :quickpay do
    post 'update_payment_status/:order_number', action: :update_payment_status, as: 'quickpay_update_payment_status'
    get 'validate_payment/:order_number', action: :validate_payment, as: 'quickpay_validate_payment'
  end

  namespace :api do
    namespace :v1 do
      resources :quickpay, only: [] do
        collection do
          get :methods
        end
      end
    end
  end
end