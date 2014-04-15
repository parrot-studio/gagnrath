class ResultController < ApplicationController
  include FortUtil
  include TimeUtil

  before_action :check_time_mode
  before_action :recently_result_action, only: [:recently_rank, :recently_guild, :recently_union]
  before_action :span_result_action, only: [:span_rank, :span_guild, :span_union]

  def index
  end

  def rulers
    @fort = params[:fort]
    (render_404; return) unless fort_groups?(@fort)
    @rulers = Ruler.for_group(@fort)
  end

  def dates
    list = CacheData.result_dates
    default_size = ServerSettings.data_size_recently

    @dates = case
    when params[:all]
      list
    when params[:recently]
      size = params[:recently].to_i
      redirect_to result_dates_path if (size <= 0 || size == default_size)
      redirect_to result_dates_path(all: 1) if size > list.size
      list.take(size)
    else
      list.take(default_size)
    end
  end

  def forts
    @date = params[:date]
    (render_404; return) unless CacheData.result_dates.include?(@date)
    @rulers = Ruler.for_date(@date)
  end

  def callers
    @date = params[:date]
    (render_404; return) unless CacheData.result_dates.include?(@date)
    @callers = GuildResult.for_date(@date)
  end

  def total_select
    @names = CacheData.guild_names_for_select(params[:all])
  end

  def total_redirect
    case
    when params['for-rank']
      redirect_to result_total_rank_path
    when params['for-guild']
      gs = parse_guild_params(params[:guild], CacheData.guild_names_for_all)
      case
      when gs.empty?
        redirect_to result_total_path
      when gs.size == 1
        redirect_to result_total_guild_path(name: encode_for_url(gs.first))
      else
        redirect_to result_total_union_path(code: create_union_code(gs))
      end
    else
      redirect_to result_total_path
    end
  end

  def total_rank
    @callers = GuildResult.totalize
  end

  def total_guild
    @gname = decode_for_url(params[:name])
    (render_404; return) unless CacheData.guild_names_for_all.include?(@gname)
    @results = GuildResult.for_guild(@gname)
    @total = GuildResult.combine(@results)
    add_union_history(@gname) unless ServerSettings.only_union_history?
  end

  def total_union
    @names = parse_union_code(params[:code], CacheData.guild_names_for_all)
    case
    when @names.empty?
      render_404; return
    when @names.size == 1
      redirect_to result_total_guild_path(name: encode_for_url(@names.first))
      return
    end

    @results = @names.map{|g| GuildResult.totalize_for_guild(g)}
    @total = GuildResult.combine(@results)
    add_union_history(@names)
  end

  def recently_select
    @names = CacheData.guild_names_for_select(params[:all])
  end

  def recently_redirect
    case
    when params['for-rank']
      num = params['recently-rank'].to_i
      (redirect_to result_recently_path; return) unless valid_result_size?(num)
      redirect_to result_recently_rank_path(num: num)
    when params['for-guild']
      num = params['recently-guild'].to_i
      (redirect_to result_recently_path; return) unless valid_result_size?(num)
      gs = parse_guild_params(params[:guild], CacheData.guild_names_for_all)
      case
      when gs.empty?
        redirect_to result_recently_path
      when gs.size == 1
        redirect_to result_recently_guild_path(num: num, name: encode_for_url(gs.first))
      else
        redirect_to result_recently_union_path(num: num, code: create_union_code(gs))
      end
    else
      redirect_to result_recently_path
    end
  end

  def recently_rank
    @callers = GuildResult.totalize(dates: @dates)
  end

  def recently_guild
    @gname = decode_for_url(params[:name])
    (render_404; return) unless CacheData.guild_names_for_all.include?(@gname)
    @results = GuildResult.for_guild(@gname).for_date(@dates)
    @total = GuildResult.combine(@results)
    add_union_history(@gname) unless ServerSettings.only_union_history?
  end

  def recently_union
    @names = parse_union_code(params[:code], CacheData.guild_names_for_all)
    case
    when @names.empty?
      render_404; return
    when @names.size == 1
      redirect_to result_recently_guild_path(num: @dates.size, name: encode_for_url(@names.first))
      return
    end

    @results = @names.map{|g| GuildResult.totalize_for_guild(g, dates: @dates)}
    @total = GuildResult.combine(@results)
    add_union_history(@names)
  end

  def span_select
    @names = CacheData.guild_names_for_select(params[:all])
    @dates = CacheData.result_dates
  end

  def span_redirect
    case
    when params['for-rank']
      from, to = [params['span-from-rank'], params['span-to-rank']].sort
      (redirect_to result_span_path; return) unless exist_result_gvdates_pair?(from, to)
      redirect_to result_span_rank_path(from: from, to: to)
    when params['for-guild']
      from, to = [params['span-from-guild'], params['span-to-guild']].sort
      (redirect_to result_span_path; return) unless exist_result_gvdates_pair?(from, to)
      gs = parse_guild_params(params[:guild], CacheData.guild_names_for_all)
      case
      when gs.empty?
        redirect_to result_span_path
      when gs.size == 1
        redirect_to result_span_guild_path(from: from, to: to, name: encode_for_url(gs.first))
      else
        redirect_to result_span_union_path(from: from, to: to, code: create_union_code(gs))
      end
    else
      redirect_to result_span_path
    end
  end

  def span_rank
    @callers = GuildResult.totalize(dates: @dates)
  end

  def span_guild
    @gname = decode_for_url(params[:name])
    (render_404; return) unless CacheData.guild_names_for_all.include?(@gname)
    @results = GuildResult.for_guild(@gname).for_date(@dates)
    @total = GuildResult.combine(@results)
    add_union_history(@gname) unless ServerSettings.only_union_history?
  end

  def span_union
    @names = parse_union_code(params[:code], CacheData.guild_names_for_all)
    case
    when @names.empty?
      render_404; return
    when @names.size == 1
      redirect_to result_span_guild_path(from: @dates.first, to: @dates.last, name: encode_for_url(@names.first))
      return
    end

    @results = @names.map{|g| GuildResult.totalize_for_guild(g, dates: @dates)}
    @total = GuildResult.combine(@results)
    add_union_history(@names)
  end

  private

  def valid_result_size?(num)
    return false unless num
    ServerSettings.data_size_range.include?(num) ? true : false
  end

  def exist_result_gvdates_pair?(from, to)
    return false unless (from && to)
    return false unless (CacheData.result_dates.include?(from) && CacheData.result_dates.include?(to))
    true
  end

  def recently_result_action
    num = params[:num].to_i
    redirect_to result_recently_path unless valid_result_size?(num)
    @dates = CacheData.result_dates.take(num).sort
    redirect_to result_recently_path if @dates.empty?
  end

  def span_result_action
    from = params[:from]
    to = params[:to]
    (render_404; return) unless exist_result_gvdates_pair?(from, to)
    @dates = CacheData.result_dates.select{|d| d >= from}.select{|d| d <= to}.sort
    redirect_to result_span_path unless valid_result_size?(@dates.size)
  end

end
