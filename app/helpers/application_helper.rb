module ApplicationHelper
  include TimeUtil
  include FortUtil

  def site_title
    ServerSettings.site_title
  end

  def site_sub_title
    ServerSettings.site_sub_title
  end

  def title_navs
    return if @title_navs.blank?
    [@title_navs].flatten.reject(&:blank?).reverse.inject(""){|s, n| s << "#{n} | " }
  end

  def data_size_recently
    ServerSettings.data_size_recently
  end

  def data_size_min
    ServerSettings.data_size_min
  end

  def data_size_max
    ServerSettings.data_size_max
  end

  def create_option_from_names(names)
    opts = "<option value=''>-</option>"
    (names || []).sort.each do |n|
      opts << "<option value='#{h(n)}'>#{h(n)}</option>"
    end
    opts
  end

  def create_name_table(names)
    ns = [names].flatten.uniq.compact
    return {} if ns.empty?

    h = {}
    if ns.size == 1
      h[ns.first] = '★'
    else
      ch = 'A'
      ns.each do |n|
        h[n] = ch
        ch = ch.succ
      end
    end

    h
  end

  def adsense
    path = File.join(Rails.root, 'tmp', 'adsence.txt')
    return '' unless File.exist?(path)
    File.read(path)
  end

  def analytics
    path = File.join(Rails.root, 'tmp', 'analytics.txt')
    return '' unless File.exist?(path)
    File.read(path)
  end

  def amazon
    path = File.join(Rails.root, 'tmp', 'amazon.txt')
    return '' unless File.exist?(path)
    File.read(path)
  end

end
