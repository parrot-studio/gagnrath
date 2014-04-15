class MailSettings < Settingslogic
  source File.expand_path('../../config/mail.yml', __FILE__)
  namespace Rails.env
  load!

  class << self

    def set_mail_config(config)
      return unless ServerSettings.use_mail?
      return unless config

      case self.delivery_method.to_s.to_sym
      when :smtp
        config.action_mailer.delivery_method = :smtp
        config.action_mailer.smtp_settings = symbolize(self.smtp_settings) unless self.smtp_settings.blank?
      when :sendmail
        config.action_mailer.delivery_method = :sendmail
        config.action_mailer.sendmail_settings = symbolize(self.sendmail_settings) unless self.sendmail_settings.blank?
      else
        config.action_mailer.delivery_method = :test
      end

      config
    end

    private

    def symbolize(sets)
      ret = {}
      sets.each{|k, v| ret[k.to_sym] = v}
      ret
    end

  end

end
