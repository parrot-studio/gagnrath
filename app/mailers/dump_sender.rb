# coding: utf-8
class DumpSender < ActionMailer::Base

  def env_test
    create_mail("Gagnrathテストメール")
  end

  def backup(file_path)
    return unless File.exists?(file_path)
    file = File.new(file_path)
    return unless file

    @name = File.basename(file_path)
    @time = TimeUtil.format_time(Time.now)
    @size = file.size / 1024

    attachments[@name] = file.read
    create_mail("Gagnrath backup file (#{@time})")
  end

  private

  def create_mail(subject)
    m = mail(
      :from => MailSettings.dump_sender.from,
      :to => MailSettings.dump_sender.to,
      :subject => subject
    )
    m.transport_encoding = '8bit'
    m
  end

end
