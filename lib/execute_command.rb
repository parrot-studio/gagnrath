class ExecuteCommand

  attr_reader :result

  class << self

    def execute(cmd)
      return if cmd.blank?
      self.new.execute(cmd)
    end

  end

  def execute(cmd)
    return if cmd.blank?
    @result = %x(#{cmd})
    @exit_status = $?
    self
  end

  def exit_status_code
    @exit_status.exitstatus
  end

  def has_error?
    exit_status_code != 0 ? true : false
  end
end
