# coding: utf-8
class RootController < ApplicationController
  protect_from_forgery with: :null_session
  helper_method :reload_cycle

  def index
    if params[:re]
      @reload = params[:re]
      redirect_to root_path unless reload_cycle.include?(@reload)
    end
    @situation = Situation.latest || Situation.new
  end

  def menu
  end

  def delete_union_histroy
    reset_union_histroy
    begin
      redirect_to :back
    rescue
      redirect_to root_path
    end
  end

  def not_found
    render status: 404
  end

  def update
    protect_action do
      Updater.update(params['d'])
      render text: 'OK'
    end
  end

  def check_status
    protect_action do
      render text: 'OK'
    end
  end

  def latest
    protect_action do
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
  end

  private

  def protect_action
    (head 403; return) unless updatable_mode?
    (head 403; return) unless params['k'] == ServerSettings.auth.update_key
    yield if block_given?
  end

  def reload_cycle
    ['30', '60', '120']
  end

end
