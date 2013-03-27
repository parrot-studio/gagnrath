# coding: utf-8
class TimelineController < ApplicationController
  include FortUtil
  include TimeUtil

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
    date_action do |date|
      @revs = CacheData.revisions_for_date(date)
    end
  end

  def situation
    date_action do |date|
      @situation = Situation.find_by(revision: params[:rev])
      redirect_to timeline_revs_path(date: date) unless @situation
    end
  end

  def destroy
    date_action do |date|
      rev = params[:rev]
      rpath = timeline_situation_path(date: date, rev: rev)
      redirect_to rpath unless updatable_mode?
      redirect_to rpath unless valid_delete_key?(params[:dkey])
      s = Situation.find_by(revision: rev)
      s.leave! if s
      redirect_to timeline_revs_path(date: date)
    end
  end

  def fort
    date_action do |date|
      fort = params[:fort]
      gs = case fort
      when 'SE'
        fort_groups_se
      when 'TE'
        fort_groups_te
      else
        fort_groups?(fort) ? fort : nil
      end
      (redirect_to timeline_path(date: date); return) if gs.nil? || gs.empty?

      @timeline = FortTimeline.build(date, gs)
      (redirect_to timeline_path(date: date); return) unless @timeline
    end
  end

  def guild
    date_action do |date|
      gname = decode_for_url(params[:name])
      (redirect_to timeline_path(date: date); return) unless CacheData.guild_names_for_date(date).include?(gname)
      @timeline = GuildTimeline.build(date, gname)
      (redirect_to timeline_path(date: date); return) unless @timeline
    end
  end

  def union_select
    date_action do |date|
      @names = CacheData.guild_names_for_date(date)
    end
  end

  def union_redirect
    date_action do |date|
      gs = parse_guild_params(params[:guild], CacheData.guild_names_for_date(date))
      case
      when gs.empty?
        redirect_to timeline_union_select_path(date: date)
      when gs.size == 1
        redirect_to timeline_for_guild_path(date: date, name: encode_for_url(gs.first))
      else
        redirect_to timeline_for_union_path(date: date, code: create_union_code(gs))
      end
    end
  end

  def union
    date_action do |date|
      gs =  parse_union_code(params[:code], CacheData.guild_names_for_date(date))
      case
      when gs.empty?
        redirect_to timeline_union_select_path(date: date)
        return
      when gs.size == 1
        redirect_to timeline_for_guild_path(date: date, name: encode_for_url(gs.first))
        return
      end

      @timeline = GuildTimeline.build(date, gs)
      redirect_to timeline_path(date: date) unless @timeline
      add_union_histroy(gs)
      render :guild
    end
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
    add_union_histroy(@names)
  end

  private

  def date_action
    @gvdate = params[:date]
    redirect_to timeline_path unless @gvdate
    redirect_to timeline_path unless CacheData.timeline_dates.include?(@gvdate)
    yield(@gvdate) if block_given?
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
