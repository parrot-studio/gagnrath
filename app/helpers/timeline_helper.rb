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

end
