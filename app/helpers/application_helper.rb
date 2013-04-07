# coding: utf-8
module ApplicationHelper
  include TimeUtil
  include FortUtil

  def server_name
    ServerSettings.env.server_name
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

end
