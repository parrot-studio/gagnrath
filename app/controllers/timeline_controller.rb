class TimelineController < ApplicationController
  include FortUtil
  include TimeUtil

  before_action :check_time_mode
  before_action :date_action, except: [:index, :span_union_select, :span_union_redirect, :span_guild, :span_union]
  before_action { add_navs('Timeline') }

  def index
    list = CacheData.timeline_dates
    default_size = ServerSettings.data_size_recently

    @dates = case
    when params[:date]
      redirect_to timeline_path unless list.include?(params[:date])
      [params[:date]]
    when params[:all]
      list
    when params[:recently]
      size = params[:recently].to_i
      redirect_to timeline_path if (size <= 0 || size == default_size)
      redirect_to timeline_path(all: 1) if size > list.size
      list.take(size)
    else
      list.take(default_size)
    end

    add_navs_for_date(@dates) if @dates.size == 1
  end

  def revs
    @revs = CacheData.revisions_for_date(@gvdate)
    add_navs_for_date(@gvdate)
  end

  def situation
    @situation = Situation.find_by(revision: params[:rev])
    (render_404; return) unless @situation
    add_navs_for_revision(@situation.revision)
  end

  def destroy
    (render_404; return) unless updatable_mode?
    rev = params[:rev]
    s = Situation.find_by(revision: rev)
    (render_404; return) unless s
    (redirect_to timeline_situation_path(date: @gvdate, rev: rev); return) unless valid_delete_key?(params[:dkey])
    s.leave!
    CacheData.clear_all
    redirect_to timeline_revs_path(date: @gvdate)
  end

  def fort
    fort = params[:fort]
    gs = case fort
    when 'SE'
      fort_groups_se
    when 'TE'
      fort_groups_te
    else fort_groups?(fort) ? fort : nil
    end
    (render_404; return) if gs.nil? || gs.empty?

    @timeline = FortTimeline.build(@gvdate, gs)
    (render_404; return) unless @timeline

    add_navs_for_date(@gvdate)
    add_navs(fort)
  end

  def guild
    gname = decode_for_url(params[:name])
    (render_404; return) unless CacheData.guild_names_for_date(@gvdate).include?(gname)
    @timeline = GuildTimeline.build(@gvdate, gname)
    (render_404; return) unless @timeline
    add_union_history(gname) unless ServerSettings.only_union_history?

    add_navs_for_date(@gvdate)
    add_navs_for_guild(gname)
  end

  def union_select
    @names = CacheData.guild_names_for_date(@gvdate)
  end

  def union_redirect
    gs = parse_guild_params(params[:guild], CacheData.guild_names_for_date(@gvdate))
    case
    when gs.empty?
      redirect_to timeline_union_path(date: @gvdate)
    when gs.size == 1
      redirect_to timeline_for_guild_path(date: @gvdate, name: encode_for_url(gs.first))
    else
      redirect_to timeline_for_union_path(date: @gvdate, code: create_union_code(gs))
    end
  end

  def union
    gs =  parse_union_code(params[:code], CacheData.guild_names_for_date(@gvdate))
    case
    when gs.empty?
      render_404; return
    when gs.size == 1
      redirect_to timeline_for_guild_path(date: @gvdate, name: encode_for_url(gs.first))
      return
    end

    @timeline = GuildTimeline.build(@gvdate, gs)
    (render_404; return) unless @timeline
    add_union_history(gs)

    add_navs_for_date(@gvdate)
    add_navs_for_guild(gs)

    render :guild
  end

  def span_union_select
    @dates = CacheData.timeline_dates
    @names = CacheData.guild_names_for_select(params[:all])
  end

  def span_union_redirect
    from, to = [params['span-from-guild'], params['span-to-guild']].sort
    (render_404; return) unless exist_timeline_gvdates_pair?(from, to)
    gs = parse_guild_params(params[:guild], CacheData.guild_names_for_all)
    case
    when gs.empty?
      redirect_to timeline_span_union_select_path
    when gs.size == 1
      redirect_to timeline_span_guild_path(from: from, to: to, name: encode_for_url(gs.first))
    else
      redirect_to timeline_span_union_path(from: from, to: to, code: create_union_code(gs))
    end
  end

  def span_guild
    gname = decode_for_url(params[:name])
    (render_404; return) unless CacheData.guild_names_for_all.include?(gname)

    from = params[:from]
    to = params[:to]
    (render_404; return) unless exist_timeline_gvdates_pair?(from, to)

    @dates = CacheData.timeline_dates.select{|d| d >= from}.select{|d| d <= to}.sort
    case
    when @dates.size == 1
      redirect_to timeline_for_guild_path(date: @dates.first, name: params[:name])
      return
    when !valid_span_timeline_size?(@dates.size)
      redirect_to timeline_span_union_select_path
      return
    end

    @timelines = @dates.inject({}){|h, d| h[d] = GuildTimeline.build(d, gname); h}
    @names = [gname]
    add_union_history(gname) unless ServerSettings.only_union_history?

    add_navs_for_date(@dates)
    add_navs_for_guild(gname)

    render :span_union
  end

  def span_union
    @names = parse_union_code(params[:code], CacheData.guild_names_for_all)
    case
    when @names.empty?
      render_404; return
    when @names.size == 1
      redirect_to timeline_span_guild_path(
        from: params[:from], to: params[:to], name: encode_for_url(@names.first))
      return
    end

    from = params[:from]
    to = params[:to]
    (render_404; return) unless exist_timeline_gvdates_pair?(from, to)

    @dates = CacheData.timeline_dates.select{|d| d >= from}.select{|d| d <= to}.sort
    case
    when @dates.size == 1
      redirect_to timeline_for_union_path(date: @dates.first, name: params[:code])
      return
    when !valid_span_timeline_size?(@dates.size)
      redirect_to timeline_span_union_select_path
      return
    end

    @timelines = @dates.inject({}){|h, d| h[d] = GuildTimeline.build(d, @names); h}
    add_union_history(@names)

    add_navs_for_date(@dates)
    add_navs_for_guild(@names)
  end

  private

  def date_action
    @gvdate = params[:date]
    render_404 unless @gvdate
    render_404 unless CacheData.timeline_dates.include?(@gvdate)
  end

  def valid_delete_key?(dkey)
    return false unless dkey
    return false if dkey.empty?
    dkey == ServerSettings.auth.delete_key ? true : false
  end

  def exist_timeline_gvdates_pair?(from, to)
    return false unless (from && to)
    return false unless (valid_gvdate?(from) && valid_gvdate?(to))
    return false unless (CacheData.timeline_dates.include?(from) && CacheData.timeline_dates.include?(to))
    true
  end

  def valid_span_timeline_size?(n)
    return false unless n
    return false if n < 2
    return false if n > ServerSettings.timeline_span_max_size
    true
  end

end
