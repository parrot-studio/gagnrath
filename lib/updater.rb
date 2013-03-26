# coding: utf-8
require 'singleton'

class Updater
  include Singleton

  class << self
    def update(data)
      self.instance.update(data)
    end
  end

  def update(data)
    PostedSituation.store_data!(data)
    apply
  end

  def apply
    loop do
      ps = PostedSituation.next_target
      break unless ps
      ps.lock!

      begin
        Situation.apply(JSON.parse(ps.posted_data))
      ensure
        ps.destroy if ps
      end
    end
  end

end
