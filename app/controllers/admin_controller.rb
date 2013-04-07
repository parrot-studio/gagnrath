# coding: utf-8
class AdminController < ApplicationController
  include FortUtil
  include TimeUtil

  before_action :check_login, except: [:login, :add_session]

  def index
  end

  def login
    clear_session
    (redirect_to root_path; return) unless updatable_mode?
  end

  def add_session
    clear_session
    (redirect_to root_path; return) unless updatable_mode?
    unless valid_admin?(params[:user], params[:password])
      flash[:error] = 'ユーザ名かパスワードが誤っています'
      redirect_to admin_login_path
      return
    end
    update_session
    redirect_to admin_path
  end

  def backup
    @files = DumpFile.all
  end

  def backup_execute
    begin
      Dumper.execute
    rescue
      flash[:error] = 'バックアップに失敗しました'
    end
    redirect_to admin_backup_path
  end

  def backup_download
    df = DumpFile.find_by_revision(params[:rev])
    (redirect_to admin_backup_path; return) unless df
    send_file(df.full_path, type: 'application/x-gzip', filename: df.filename)
  end

  def backup_delete
    df = DumpFile.find_by_revision(params[:rev])
    df.delete! if df
    redirect_to admin_backup_path
  end

  def result
    @dates = [Situation.gvdates, Ruler.gvdates].flatten.uniq.sort.compact.reverse
  end

  def add_result
    sdates = [Situation.gvdates, Ruler.gvdates].flatten.uniq.sort.compact
    date = params['add-date']
    dates = if date
      sdates.include?(date) ? [date] : []
    else
      sdates - Ruler.gvdates
    end

    dates.sort.each do |d|
      Ruler.add_rulers_for_date(d)
      GuildResult.add_result_for_date(d)
    end
    CacheData.clear_all

    flash[:info] = if dates.empty? 
      '集計対象はありませんでした'
    else
      "データ集計が完了しました(#{dates.map{|d| divided_date(d)}.join(',')})"
    end
    redirect_to admin_result_path
  end

  def rulers
    @manuals = Ruler.manuals.uniq(:gvdate).pluck(:gvdate).sort
    @dates = Ruler.gvdates
  end

  def rulers_new
    begin
      date = format('%04d%02d%02d', params[:year].to_i, params[:month].to_i, params[:day].to_i)
      Date.parse(date)
      redirect_to admin_rulers_data_path(date: date)
    rescue ArgumentError
      flash[:error] = '日付指定が異常です'
      redirect_to admin_rulers_path
    end
  end

  def rulers_show
    rulers_action do |date|
      @rulers = Ruler.for_date(date).reject(&:manual?)
      @manuals = @rulers.empty? ? Ruler.manuals.for_date(date) : []
    end
  end

  def rulers_update
    rulers_action do |date|
      unless Ruler.for_date(date).reject(&:manual?).empty?
        flash[:error] = '自動集計済みの結果なので、手動更新できません'
        redirect_to admin_rulers_data_path(date)
        return
      end

      forts = (Situation.latest || Situation.new).forts_map
      manuals = Ruler.manuals.for_date(date).inject({}){|h, m| h[m.fort_code] = m; h}

      updates = []
      params[:gname].each do |fcd, gname|
        next unless valid_fort_code?(fcd)
        next if gname.blank?
        r = manuals[fcd] || Ruler.new
        f = forts[fcd]

        r.gvdate = date
        r.fort_group = fcd[0]
        r.fort_code = fcd
        r.fort_name = (f ? f.fort_name : '')
        r.formal_name = (f ? f.formal_name : '')
        r.guild_name = gname
        r.source = Ruler::SOURCE_MANUAL
        r.full_defense = false

        updates << r
      end

      if updates.empty?
        flash[:error] = '結果が入力されていません'
        redirect_to admin_rulers_data_path(date)
        return
      end

      rsl = false
      Ruler.transaction do
        updates.each(&:save!)
        GuildResult.add_result_for_date(date)
        CacheData.clear_all
        rsl = true
      end

      if rsl
        flash[:info] = "#{divided_date(date)}の結果を更新しました"
      else
        flash[:error] = "#{divided_date(date)}の結果を更新できませんでした"
      end

      redirect_to admin_rulers_path
    end
  end

  def rulers_delete
    rulers_action do |date|
      Ruler.transaction do
        Ruler.manuals.for_date(date).each(&:destroy)
        GuildResult.add_result_for_date(date)
        CacheData.clear_all
      end

      flash[:info] = "#{divided_date(date)}の結果を削除しました"
      redirect_to admin_rulers_path
    end
  end

  private

  def admin_user
    ServerSettings.auth.admin.user
  end

  def check_login
    (redirect_to root_path; return false) unless updatable_mode?
    unless logined?
      flash[:error] = 'ログインが確認できませんでした'
      redirect_to admin_login_path
      return false
    end

    update_session
    true
  end

  def logined?
    hash = session[:hash]
    time = session[:time]
    return false if (hash.blank? || time.blank?)
    return false unless hash == create_hash(admin_user, time)
    return false if Time.now.to_i - time.to_i > ServerSettings.memcache_expire_time
    true
  end

  def valid_admin?(user, pass)
    return false unless admin_user == user
    return false unless ServerSettings.auth.admin.pass == pass
    true
  end

  def update_session
    time = Time.now.to_i
    session[:time] = time
    session[:hash] = create_hash(admin_user, time)
    time
  end

  def clear_session
    session.delete(:time)
    session.delete(:hash)
    nil
  end

  def create_hash(user, seed)
    return unless (user && seed)
    s = "#{user}-#{ServerSettings.secret_key_base}-#{seed}"
    Digest::SHA1.hexdigest(s)
  end

  def rulers_action
    @date = params[:date]
    unless valid_gvdate?(@date)
      flash[:error] = '日付指定が異常です'
      redirect_to admin_rulers_path
      return
    end
    yield(@date)
  end

end
