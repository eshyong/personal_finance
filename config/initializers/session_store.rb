# Configure cookie session store
Rails.application.config.session_store :cookie_store, key: "_personal_finance_session", expire_after: 1.day
