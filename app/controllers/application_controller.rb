# coding: utf-8
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  unless ServerSettings.sample_mode?
    http_basic_authenticate_with(ServerSettings.basic_auth_params)
  end

  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception, with: :server_error
  end

  helper_method :sample_mode?, :view_mode?, :updatable_mode?, :encode_for_url,
    :union_history, :create_union_code

  private

  def render_404
    render 'root/not_found', status: 404
  end

  def sample_mode?
    ServerSettings.sample_mode? ? true : false
  end

  def view_mode?
    ServerSettings.view_mode? ? true : false
  end

  def updatable_mode?
    return false if sample_mode?
    view_mode? ? false : true
  end

  def encode_for_url(s)
    URI.encode_www_form_component(s.gsub('.', '%2e')).gsub('+', '%20')
  end

  def decode_for_url(s)
    URI.decode_www_form_component(s.gsub('%20', '+')).gsub('%2e', '.')
  end

  def encode_base64_for_url(s)
    begin
      Base64.urlsafe_encode64(s)
    rescue
      ''
    end
  end

  def decode_base64_for_url(s)
    begin
      Base64.urlsafe_decode64(s).force_encoding('UTF-8')
    rescue
      ''
    end
  end

  def parse_guild_params(gname, names)
    return [] if gname.nil? || gname.empty? || names.empty?
    [gname].flatten.uniq.reject(&:blank?).select{|n| names.include?(n)}
  end

  def parse_union_code(code, names)
    return [] if code.nil? || code.empty? || names.empty?
    code.split(/,/).uniq.reject(&:blank?).map{|s| decode_base64_for_url(s)}.select{|g| names.include?(g)}
  end

  def create_union_code(gs)
    [gs].flatten.uniq.reject(&:blank?).map{|n| encode_base64_for_url(n)}.flatten.join(',')
  end

  def server_error
    render template: 'root/error', status: 500
  end
  
  def add_union_history(guilds)
    gs = [guilds].flatten.uniq.compact
    return if gs.empty?
    orgs = union_history(raw: true)
    str = gs.join("\t")
    orgs.delete(str)
    orgs << str
    size = ServerSettings.union_history_size
    list = orgs.size > size ? orgs.reverse.take(size).reverse : orgs
    set_union_history(list)
  end

  def set_union_history(list)
    val = (list || []).to_json
    cookie_params = {
      value: val,
      expires: 14.days.from_now
    }
    cookie_params[:path] = ServerSettings.app_path unless ServerSettings.app_path.blank?
    cookies[:union_history] = cookie_params
  end

  def reset_union_history
    cookie_params = {
      value: '',
      expires: Time.at(0)
    }
    cookie_params[:path] = ServerSettings.app_path unless ServerSettings.app_path.blank?
    cookies[:union_history] = cookie_params
  end

  def union_history(raw: false)
    begin
      return [] unless cookies[:union_history]
      list = JSON.parse(cookies[:union_history])
      return list if raw
      list.map{|str| str.split("\t")}
    rescue
      []
    end
  end

end
