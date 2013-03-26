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

end
