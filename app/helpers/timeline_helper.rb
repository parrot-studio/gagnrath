# coding: utf-8
module TimelineHelper

  def timeline_span_size
    case
    when gvtype_fe?
      12
    when gvtype_te?
      6
    end
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
