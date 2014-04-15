class AdminController < ApplicationController
  include FortUtil
  include TimeUtil

  before_action :check_login, except: [:login, :add_session]
  before_action :rulers_action, only: [:rulers_show, :rulers_update, :rulers_delete]

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
    @rulers = Ruler.for_date(@date).reject(&:manual?)
    @manuals = @rulers.empty? ? Ruler.manuals.for_date(@date) : []
  end

  def rulers_update
    unless Ruler.for_date(@date).reject(&:manual?).empty?
      flash[:error] = '自動集計済みの結果なので、手動更新できません'
      redirect_to admin_rulers_data_path(@date)
      return
    end

    forts = (Situation.where('gvdate < ?', @date).last || Situation.new).forts_map
    manuals = Ruler.manuals.for_date(@date).inject({}){|h, m| h[m.fort_code] = m; h}

    updates = []
    params[:gname].each do |fcd, gname|
      next unless valid_fort_code?(fcd)
      next if gname.blank?
      r = manuals[fcd] || Ruler.new
      f = forts[fcd]

      r.gvdate = @date
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
      redirect_to admin_rulers_data_path(@date)
      return
    end

    rsl = false
    Ruler.transaction do
      updates.each(&:save!)
      GuildResult.add_result_for_date(@date)

      # Situationを登録
      st = manual_time_for(@date)
      rev = manual_revision_for(@date)
      s = Situation.find_by_revision(rev) || Situation.new
      s.set_time(st)
      fmap = s.forts_map
      updates.each do |r|
        f = fmap[r.fort_code] || Fort.new
        f.revision = s.revision
        f.gvdate = s.gvdate
        f.fort_group = r.fort_group
        f.fort_code = r.fort_code
        f.fort_name = r.fort_name
        f.formal_name = r.formal_name
        f.guild_name = r.guild_name
        f.update_time = s.update_time
        s.forts << f
      end
      s.save!

      CacheData.clear_all
      rsl = true
    end

    if rsl
      flash[:info] = "#{divided_date(@date)}の結果を更新しました"
    else
      flash[:error] = "#{divided_date(@date)}の結果を更新できませんでした"
    end

    redirect_to admin_rulers_path
  end

  def rulers_delete
    Ruler.transaction do
      Ruler.manuals.for_date(@date).each(&:destroy)
      GuildResult.add_result_for_date(@date)
      s = Situation.find_by_revision(manual_revision_for(@date))
      s.destroy if s
      CacheData.clear_all
    end

    flash[:info] = "#{divided_date(@date)}の結果を削除しました"
    redirect_to admin_rulers_path
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
    end
  end

  def manual_time_for(date)
    return unless date
    sd = Date.new(date[0..3].to_i, date[4..5].to_i, date[6..7].to_i)
    ((sd + 1).to_time - 1).to_datetime # 23:59:59
  end

  def manual_revision_for(date)
    st = manual_time_for(date)
    return unless st
    TimeUtil.time_to_revision(st)
  end

end
