# coding: utf-8
class PostedSituation < ActiveRecord::Base

  validates :posted_time, presence: true
  validates :posted_data, presence: true 

  class << self
    def next_target
      self.where(locked: false).order(:posted_time).limit(1).first
    end

    def store_data!(data)
      return if data.blank?
      ps = self.new
      ps.posted_time = Time.now
      ps.posted_data = data
      ps.locked = false
      ps.save!
      ps
    end
  end

  def locked?
    self.locked ? true : false
  end

  def lock!
    self.locked = true
    save!
  end

end
