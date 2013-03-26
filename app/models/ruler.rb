# coding: utf-8
class Ruler < ActiveRecord::Base

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
  validates :source,
    presence: true,
    length: {maximum: 50}

  SOURCE_MANUAL = 'manual'
  SOURCE_SITUATION = 'situation'

  scope :for_date,  lambda{|d| where(gvdate: d)}
  scope :for_group, lambda{|g| where(fort_group: g)}
  scope :manuals,   lambda{where(source: SOURCE_MANUAL)}

  class << self

    def gvdates
      self.uniq(:gvdate).pluck(:gvdate).sort
    end

    def add_rulers_for_date(date)
      self.transaction do
        s = Situation.result_for(date)
        return unless s
        exists = self.where(gvdate: date).inject({}){|h, r| h[r.fort_code] = r; h}

        s.forts.each do |f|
          fcd = f.fort_code
          count = Caller.where(gvdate: date, fort_code: fcd).count

          r = exists[fcd] || self.new
          r.gvdate = f.gvdate
          r.fort_group = f.fort_group
          r.fort_code = f.fort_code
          r.fort_name = f.fort_name
          r.formal_name = f.formal_name
          r.guild_name = f.guild_name
          r.source = SOURCE_SITUATION
          r.full_defense = (count > 0 ? false : true)
          r.save!
        end
      end

      date
    end

    def add_rulers_for_all(from: nil, to: nil)
      dates = Situation.gvdates
      dates = dates.select{|d| d >= from} if from
      dates = dates.select{|d| d <= to} if to
      return if dates.empty?
      dates.each{|d| add_rulers_for_date(d)}
      dates
    end

  end

  def manual?
    self.source == SOURCE_MANUAL ? true : false
  end

end
