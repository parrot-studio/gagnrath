# coding: utf-8
class RootController < ApplicationController
  protect_from_forgery with: :null_session
  helper_method :reload_cycle

  before_action :check_time_mode
  before_action :protect_action, except: [:index, :menu, :delete_union_history, :not_found]

  def index
    if params[:re]
      @reload = params[:re]
      redirect_to root_path unless reload_cycle.include?(@reload)
    end
    @situation = Situation.latest || Situation.new
  end

  def menu
  end

  def delete_union_history
    reset_union_history
    begin
      redirect_to :back
    rescue
      redirect_to root_path
    end
  end

  def not_found
    render_404
  end

  def update
    Updater.update(params['d'])
    render text: 'OK'
  end

  def check_status
    render text: 'OK'
  end

  def latest
    s = Situation.latest || Situation.new

    ret = {}
    ret['id'] = s.id
    ret['gv_date'] = s.gvdate
    ret['revision'] = s.revision
    ret['update_time'] = s.update_time

    ret['forts'] = s.forts.map do |f|
      fd = {}
      fd['id'] = f.id
      fd['fort_id'] = f.fort_code
      fd['fort_name'] = f.fort_name
      fd['formal_name'] = f.formal_name
      fd['guild_name'] = f.guild_name
      fd['update_time'] = f.update_time
      fd
    end

    render json: ret.to_json
  end

  def cutin
    data = JSON.parse(params['d'])
    s = Situation.build_from(data)
    s.cut_in! if s
    render text: 'OK'
  end

  private

  def protect_action
    (head 403; return) unless updatable_mode?
    (head 403; return) unless params['k'] == ServerSettings.auth.update_key
  end

  def reload_cycle
    %w(30 60 120)
  end

end
