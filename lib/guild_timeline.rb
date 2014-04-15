class GuildTimeline
  include FortUtil
  include TimeUtil

  attr_accessor :gvdate

  class << self

    def build(date, guilds)
      return unless (date && guilds)
      ft = self.new
      ft.gvdate = date
      ft.build(guilds)
    end

  end

  def build(guilds)
    gs = [guilds].flatten.uniq
    return if gs.empty?

    calls = Caller.where(gvdate: self.gvdate, guild_name: gs)
    ejects =  Caller.where(gvdate: self.gvdate, reject_name: gs)
    @callers = [calls, ejects].flatten.compact
    @guilds = gs
    @revs = @callers.map(&:revision).sort.uniq.compact

    # 前回の結果
    bdate = before_gvdate(self.gvdate)
    bforts = Ruler.for_date(bdate)
    bforts = (Situation.result_for(bdate) || Situation.new).forts if bforts.blank?
    set_result(bforts, gs, before_result)

    # 今回の結果
    rforts = Ruler.for_date(self.gvdate)
    rforts = (Situation.result_for(self.gvdate) || Situation.new).forts if rforts.blank?
    set_result(rforts, gs, result)

    # タイムライン生成
    # 関連する砦
    forts = @callers.map(&:fort_code).uniq.sort
    forts.each do |fcd|
      cs = @callers.select{|c| c.fort_code == fcd}.inject({}){|h, c| h[c.revision] = c; h}
      # 前回の結果が基準
      ruler = before_result[fcd]
      # revごとにcallerを分析
      @revs.each do |rev|
        c = cs[rev]
        data["#{rev}_#{fcd}"] = if c
          if gs.include?(c.guild_name)
            ruler = c.guild_name
            [:call, c.guild_name]
          else
            ruler = nil
            [:lose, c.guild_name]
          end
        else
          ruler ? [:stay, ruler] : [:none, nil]
        end
      end
    end

    self
  end

  def callers
    @callers ||= []
    @callers
  end

  def guilds
    @guilds ||= []
    @guilds
  end

  def revs
    @revs ||= []
    @revs
  end

  def result
    @result ||= {}
    @result
  end

  def before_result
    @before_result ||= {}
    @before_result
  end

  def state_for(rev, fort)
    data["#{rev}_#{fort}"]
  end

  private

  def data
    @data ||= {}
    @data
  end

  def set_result(forts, gs, h)
    return if forts.blank? || gs.blank?
    forts.each do |f|
      next unless gs.include?(f.guild_name)
      h[f.fort_code] = f.guild_name
    end
    h
  end

end
