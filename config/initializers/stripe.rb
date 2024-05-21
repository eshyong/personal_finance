# Set the stripe secret API key based on the environment
Stripe.api_key = if Rails.env.production?
  Rails.application.credentials.stripe_live_secret_key
else
  Rails.application.credentials.stripe_test_secret_key
end
