# coding: utf-8
module TimeUtil

  module_function

  def format_time(t)
    return unless t
    d = t.to_datetime
    format("%04d/%02d/%02d %02d:%02d:%02d",
      d.year, d.month, d.day, d.hour, d.min, d.sec)
  end

  def format_time_only(t)
    return unless t
    d = t.to_datetime
    format("%02d:%02d:%02d", d.hour, d.min, d.sec)
  end

  def divided_date(ds)
    return unless ds
    "#{ds[0..3]}/#{ds[4..5]}/#{ds[6..7]}"
  end

  def time_to_revision(t)
    return unless t
    d = t.to_datetime
    format("%04d%02d%02d%02d%02d%02d",
      d.year, d.month, d.day, d.hour, d.min, d.sec)
  end

  def time_to_gvdate(t)
    return unless t
    d = t.to_datetime
    format("%04d%02d%02d", d.year, d.month, d.day)
  end

  def revision_to_formet_time(rev)
    return unless rev
    "#{rev[0..3]}/#{rev[4..5]}/#{rev[6..7]} #{rev[8..9]}:#{rev[10..11]}:#{rev[12..13]}"
  end

  def revision_to_format_time_only(rev)
    return unless rev
    "#{rev[8..9]}:#{rev[10..11]}:#{rev[12..13]}"
  end

  def in_battle_time?(t = nil)
    t ||= DateTime.now
    return false if t < Time.local(t.year, t.mon, t.mday, 19, 50, 0).to_datetime
    return false if t > Time.local(t.year, t.mon, t.mday, 22, 10, 0).to_datetime

    case
    when ServerSettings.gvtype_fe?
      t.sunday? ? true : false
    when ServerSettings.gvtype_te?
      t.saturday? ? true : false
    end
  end

  def shift_gvdate(gd, diff)
    return unless (gd && diff)
    d = Date.new(gd[0..3].to_i, gd[4..5].to_i, gd[6..7].to_i) + diff
    format("%04d%02d%02d", d.year, d.month, d.day)
  end

  def before_gvdate(gd)
    shift_gvdate(gd, -7)
  end

  def after_gvdate(gd)
    shift_gvdate(gd, 7)
  end

  def valid_gvdate?(d)
    return false unless d
    d.match(/\A\d{8}\z/) ? true : false
  end

  def format_span(from, to)
    return unless (from && to)
    "#{divided_date(from)} - #{divided_date(to)}"
  end

end
