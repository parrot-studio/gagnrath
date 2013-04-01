# Be sure to restart your server when you modify this file.

session_params = {
  key: "_gagnrath_session_#{ServerSettings.app_path}"
}
session_params[:path] = ServerSettings.app_path unless ServerSettings.app_path.blank?
Gagnrath::Application.config.session_store :encrypted_cookie_store, session_params
