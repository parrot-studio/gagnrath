# coding: utf-8
class FortTimeline
  include FortUtil
  include TimeUtil

  attr_accessor :gvdate

  class << self

    def build(date, groups)
      return unless (date && groups)
      ft = self.new
      ft.gvdate = date
      ft.build(groups)
    end

  end

  def build(groups)
    gs = [groups].flatten.uniq.select{|g| fort_groups?(g)}
    return if gs.empty?

    # データ収集
    @callers = Caller.where(gvdate: self.gvdate, fort_group: gs)
    @callers.each{|c| data[key_for_caller(c)] = c}
    @forts = [gs].flatten.map{|g| fort_codes_for(g)}.flatten
    @revs = @callers.map(&:revision).sort.uniq.compact

    # 前回の結果
    bdate = before_gvdate(self.gvdate)
    bforts = Ruler.for_date(bdate).for_group(gs)
    bforts = (Situation.result_for(before_gvdate(bdate)) || Situation.new).forts if bforts.blank?
    set_result(bforts, before_result)

    # 今回の結果
    rforts = Ruler.for_date(self.gvdate).for_group(gs)
    rforts = (Situation.result_for(self.gvdate) || Situation.new).forts if rforts.blank?
    set_result(rforts, result)

    self
  end

  def callers
    @callers ||= []
    @callers
  end

  def forts
    @forts ||= []
    @forts
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

  def caller_for(rev, fort)
    data["#{rev}_#{fort}"]
  end

  private

  def data
    @data ||= {}
    @data
  end

  def key_for_caller(c)
    "#{c.revision}_#{c.fort_code}"
  end

  def set_result(forts, h)
    return if forts.blank?
    forts.each do |f|
      next unless self.forts.include?(f.fort_code)
      h[f.fort_code] = f.guild_name
    end
    h
  end

end
