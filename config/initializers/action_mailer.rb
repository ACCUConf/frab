unless Rails.env.development?
  ActionMailer::Base.default_url_options = {
    host: ENV.fetch('FRAB_HOST'),
    protocol: ENV.fetch('FRAB_PROTOCOL')
  }
  
  ActionMailer::Base.delivery_method = :smtp 
  # Undo all setting that we created by using the ActionMailer before the actual initialization was done
  ActionMailer::Base.smtp_settings = {} 
  %w(ADDRESS PORT DOMAIN USER_NAME PASSWORD AUTHENTICATION ENABLE_STARTTLS ENABLE_STARTTLS_AUTO SSL TLS OPENSSL_VERIFY_MODE).each do |setting|
    next unless ENV["SMTP_#{setting}"].present?
    case setting.downcase
    when "port"
      ActionMailer::Base.smtp_settings[setting.downcase.to_sym] = ENV["SMTP_#{setting}"].to_i
    when "openssl_verify_mode"
      if %w(none peer).include? ENV["SMTP_#{setting}"].downcase
        ActionMailer::Base.smtp_settings[setting.downcase.to_sym] = ENV["SMTP_#{setting}"].downcase
      end
    when "ssl", "tls", "enable_starttls", "enable_starttls_auto"
      ActionMailer::Base.smtp_settings[setting.downcase.to_sym] = ENV["SMTP_#{setting}"].downcase == "true"
    else 
      ActionMailer::Base.smtp_settings[setting.downcase.to_sym] = ENV["SMTP_#{setting}"]
    end
  end

  if ENV.fetch('SMTP_NOTLS', 'false') == 'true'
    ActionMailer::Base.smtp_settings.merge!(
      enable_starttls_auto: false,
      openssl_verify_mode: :none,
      ssl: false,
      tls: false
    )
  end
  Rails.logger.info "========> Env #{ENV.keys}"
  Rails.logger.info "!!!!!!!! #{ActionMailer::Base.smtp_settings}"
end
