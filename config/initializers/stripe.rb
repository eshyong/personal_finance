# Set the stripe secret API key based on the environment
Stripe.api_key = if Rails.env.production?
  Rails.application.credentials.stripe.live_secret_key!
else
  Rails.application.credentials.stripe.test_secret_key!
end
