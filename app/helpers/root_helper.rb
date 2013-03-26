# coding: utf-8
module RootHelper

  def create_option_from_names(names)
    opts = "<option value=''>-</option>"
    (names || []).sort.each do |n|
      opts << "<option value='#{h(n)}'>#{h(n)}</option>"
    end
    opts
  end

end
