class Situation < ActiveRecord::Base
  include FortUtil
  include TimeUtil

  has_many :forts,   dependent: :destroy
  has_many :callers, dependent: :destroy

  validates :revision,
    presence: true,
    length: {maximum: 30},
    uniqueness: true
  validates :gvdate,
    presence: true,
    length: {maximum: 10}
  validates :update_time,
    presence: true

  scope :for_date, lambda{|d| where(gvdate: d)}

  class << self
    def latest
      self.order("revision DESC").limit(1).first
    end

    def gvdates
      self.uniq(:gvdate).pluck(:gvdate).sort
    end

    def gvdate_before(base, diff = 1)
      return unless base
      return if diff.to_i < 1
      list = self.gvdates.select{|d| d < base}.sort.reverse.take(diff)
      list.size == diff ? list.last : nil
    end

    def gvdate_after(base, diff = 1)
      return unless base
      return if diff.to_i < 1
      self.gvdates.select{|d| d > base}.sort.take(diff)
      list.size == diff ? list.last : nil
    end

    def revision_before(rev, diff = 1)
      return unless rev
      return if diff.to_i < 1
      list = self.where('revision < ?', rev).order('revision DESC').limit(diff)
      list.size == diff ? list.last : nil
    end

    def revision_after(rev, diff = 1)
      return unless rev
      return if diff.to_i < 1
      list = self.where('revision > ?', rev).order('revision ASC').limit(diff)
      list.size == diff ? list.last : nil
    end

    def guild_names_for(date)
      return [] unless date
      Fort.where(gvdate: date).uniq(:guild_name).pluck(:guild_name).sort
    end

    def build_from(data)
      return if (data.nil? || data.empty?)
      utime = data.delete('update_time')
      return unless utime
      time = Time.parse(utime)

      s = self.new
      s.set_time(time)

      data.each do |k, d|
        f = Fort.create_from_data(d)
        next unless f
        f.revision = s.revision
        f.gvdate = s.gvdate
        s.forts << f
      end

      s.forts.empty? ? nil : s
    end

    def apply(data)
      s = build_from(data)
      return unless s
      (self.latest || self.new).connect!(s)
    end

    def result_for(date)
      return unless date
      self.for_date(date).order("revision DESC").limit(1).first
    end
  end

  def guild_names
    self.forts.map(&:guild_name).uniq.compact.sort
  end

  def forts_map
    self.forts.inject({}){|h, f| h[f.fort_code] = f;h}
  end

  def set_time(t)
    return unless t
    self.update_time = t
    self.gvdate = time_to_gvdate(t)
    self.revision = time_to_revision(t)
    self
  end

  def fort_changed?
    return false if self.forts.empty?
    self.callers.empty? ? false : true
  end

  def fort_stay?
    self.fort_changed? ? false : true
  end

  def before(diff = 1)
    return if diff.to_i < 1
    s = self.class.revision_before(self.revision, diff)
    return unless s
    self.gvdate == s.gvdate ? s : nil
  end

  def after(diff = 1)
    return if diff.to_i < 1
    s = self.class.revision_after(self.revision, diff)
    return unless s
    self.gvdate == s.gvdate ? s : nil
  end

  def connect(a)
    return unless a
    afm = a.forts_map
    bfm = self.forts_map
    cmap = a.callers.inject({}){|h, c| h[c.fort_code] = c; h}

    cs = []
    [bfm.keys, afm.keys].flatten.uniq.compact.each do |cd|
      bf = bfm[cd]
      af = afm[cd]
      next unless af

      # 最終更新時間
      if bf && bf.fort_stay?(af)
        af.update_time = bf.update_time
        next
      end
      af.update_time = a.update_time

      # caller生成
      cs << lambda do
        c = cmap[af.fort_code] || Caller.new
        c.revision = a.revision
        c.gvdate = a.gvdate
        c.fort_group = af.fort_group
        c.fort_code = af.fort_code
        c.guild_name = af.guild_name
        c.reject_name = (bf ? bf.guild_name : '')
        c
      end.call
    end

    # 存在するデータを生かしつつ更新
    [cmap.keys, cs.map(&:fort_code)].flatten.uniq.compact.each do |fcd|
      org = cmap[fcd]
      cre = cs.find{|c| c.fort_code == fcd}
      case
      when org && cre.nil?
        # 新しいリストにない
        org.destroy
      when org.nil? && cre
        # 新しいリストにしかない
        a.callers << cre
      else
        # 両方にある => 更新を保存
        org.save!
      end
    end

    a
  end

  def connect!(a)
    return unless a
    self.class.transaction do
      self.connect(a)
      return unless a.fort_changed?
      a.save!
      a
    end
  end

  def leave!
    self.class.transaction do
      be = self.class.revision_before(self.revision) || Situation.new
      af = self.class.revision_after(self.revision)
      be.connect!(af) if af
      self.destroy
    end
  end

  def cut_in!
    return if self.forts.empty?
    return if Situation.find_by(revision: self.revision)

    self.class.transaction do
      be = self.class.revision_before(self.revision) || Situation.new
      af = self.class.revision_after(self.revision)
      be.connect!(self)
      self.connect!(af) if af

      self
    end
  end

end
