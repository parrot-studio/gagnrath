# coding: utf-8
class Fort < ActiveRecord::Base
  include FortUtil
  include TimeUtil

  belongs_to :situation

  validates :revision,
    presence: true,
    length: {maximum: 30}
  validates :gvdate,
    presence: true,
    length: {maximum: 10}
  validates :fort_group,
    presence: true,
    length: {maximum: 10}
  validates :fort_code,
    presence: true,
    length: {maximum: 10}
  validates :fort_name,
    allow_nil: true,
    length: {maximum: 100}
  validates :formal_name,
    allow_nil: true,
    length: {maximum: 100}
  validates :guild_name,
    presence: true,
    length: {maximum: 50}
  validates :update_time,
    presence: true

  class << self
    include FortUtil

    def create_from_data(d)
      return if d.nil? || d.empty?

      f = Fort.new
      f.fort_code = d['id']
      return unless valid_fort_code?(f.fort_code)
      f.fort_group = f.fort_code.first
      return unless fort_groups?(f.fort_group)
      f.fort_name = d['name']
      f.formal_name = d['formal_name']
      f.guild_name = d['guild_name']
      f.update_time = Time.parse(d['update_time'])
      f
    end

  end

  def changed?(f)
    return false unless f
    return false if self.update_time > f.update_time
    return false if self.guild_name == f.guild_name
    true
  end

  def stay?(f)
    self.changed?(f) ? false : true
  end

  def uptime_from(t)
    return unless t
    (t - self.update_time).to_i
  end

  def hot?(t)
    ut = uptime_from(t)
    return false unless ut
    ut <= ServerSettings.env.attention_minitues * 60 ? true : false
  end

end
