# coding: utf-8
class TimelineController < ApplicationController
  include FortUtil
  include TimeUtil

  before_filter :date_action, except: [:index, :span_union_select, :span_union_redirect, :span_guild, :span_union]

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
  end

  def revs
    @revs = CacheData.revisions_for_date(@gvdate)
  end

  def situation
    @situation = Situation.find_by(revision: params[:rev])
    (render_404; return) unless @situation
  end

  def destroy
    rev = params[:rev]
    s = Situation.find_by(revision: rev)
    (render_404; return) unless s
    rpath = timeline_situation_path(date: @gvdate, rev: rev)
    (redirect_to rpath; return) unless updatable_mode?
    (redirect_to rpath; return) unless valid_delete_key?(params[:dkey])
    s.leave!
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
  end

  def guild
    gname = decode_for_url(params[:name])
    (render_404; return) unless CacheData.guild_names_for_date(@gvdate).include?(gname)
    @timeline = GuildTimeline.build(@gvdate, gname)
    (render_404; return) unless @timeline
    add_union_history(gname) unless ServerSettings.only_union_history?
  end

  def union_select
    @names = CacheData.guild_names_for_date(@gvdate)
  end

  def union_redirect
    gs = parse_guild_params(params[:guild], CacheData.guild_names_for_date(@gvdate))
    case
    when gs.empty?
      redirect_to timeline_union_select_path(date: @gvdate)
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
      redirect_to timeline_union_select_path(date: @gvdate)
      return
    when gs.size == 1
      redirect_to timeline_for_guild_path(date: @gvdate, name: encode_for_url(gs.first))
      return
    end

    @timeline = GuildTimeline.build(@gvdate, gs)
    (render_404; return) unless @timeline
    add_union_history(gs)
    render :guild
  end

  def span_union_select
    @dates = CacheData.timeline_dates
    @names = CacheData.guild_names_for_select(params[:all])
  end

  def span_union_redirect
    from, to = [params['span-from-guild'], params['span-to-guild']].sort
    (redirect_to timeline_span_union_select_path; return) unless exist_timeline_gvdates_pair?(from, to)
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
    (redirect_to timeline_span_union_select_path; return) unless CacheData.guild_names_for_all.include?(gname)

    from = params[:from]
    to = params[:to]
    (redirect_to timeline_span_union_select_path; return) unless exist_timeline_gvdates_pair?(from, to)

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

    render :span_union
  end

  def span_union
    @names = parse_union_code(params[:code], CacheData.guild_names_for_all)
    case
    when @names.empty?
      redirect_to timeline_span_union_select_path
      return
    when @names.size == 1
      redirect_to timeline_span_guild_path(
        from: params[:from], to: params[:to], name: encode_for_url(@names.first))
      return
    end

    from = params[:from]
    to = params[:to]
    (redirect_to timeline_span_union_select_path; return) unless exist_timeline_gvdates_pair?(from, to)

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
