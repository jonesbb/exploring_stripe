class User < ActiveRecord::Base
  attr_accessible :email, :name
  
  attr_accessor :stripe_card_token
  
  def save_with_payment
    if valid?
      customer = Stripe::Charge.create(amount: 50, currency: "usd", card: stripe_card_token, description: email)
      RAILS_DEFAULT_LOGGER.debug @customer
      self.stripe_customer_token = customer.id
      save!
    end
  rescue Stripe::InvalidRequestError => e
    logger.error "Stripe error while creating customer: #{e.message}"
    errors.add :base, "There was a problem with your credit card."
    false
  end
end
