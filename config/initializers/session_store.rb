# Be sure to restart your server when you modify this file.

session_params = {
  key: "_gagnrath_session_#{ServerSettings.app_path}"
}
session_params[:path] = ServerSettings.app_path unless ServerSettings.app_path.blank?
Rails.application.config.session_store :cookie_store, session_params
