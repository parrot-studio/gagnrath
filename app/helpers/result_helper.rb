# coding: utf-8
module ResultHelper

  def result_view_for_se?
    return false unless params[:priority]
    params[:priority].downcase == 'se' ? true : false
  end

  def result_view_for_fe?
    return false unless params[:priority]
    params[:priority].downcase == 'fe' ? true : false
  end

  def result_view_for_all?
    return true unless params[:priority]
    return false if (result_view_for_se? || result_view_for_fe?)
    true
  end

  def result_subtitle
    case
    when result_view_for_se?
      ' (for SE)'
    when result_view_for_fe?
      ' (for FE)'
    else
      ''
    end
  end

end
