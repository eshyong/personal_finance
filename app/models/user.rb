class User < ApplicationRecord
  has_secure_password
  before_save :downcase_email
  before_destroy :delete_stripe_customer

  has_many :financial_accounts, dependent: :destroy

  validates :email, presence: true
  validates_format_of :email, with: URI::MailTo::EMAIL_REGEXP

  def confirm!
    update_columns(confirmed_at: Time.current)
  end

  def confirmed?
    confirmed_at.present?
  end

  def unconfirmed?
    !confirmed?
  end

  def generate_confirmation_token
    signed_id expires_in: 5.minutes
  end

  def send_confirmation_email!
    confirmation_token = generate_confirmation_token
    UserMailer.confirmation(self, confirmation_token).deliver_now
  end

  def downcase_email
    self.email = email.downcase
  end

  def delete_stripe_customer
    begin
      Stripe::Customer.delete(stripe_customer_id)
    rescue Stripe::InvalidRequestError
      # Customer may have been deleted already
    end
  end
end
