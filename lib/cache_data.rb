class CacheData

  class << self

    def timeline_dates
      get_with_cache('timeline_dates') do
        Situation.gvdates.reverse
      end
    end

    def revisions_for_date(date)
      return [] unless date
      get_with_cache("revisions_for_#{date}") do
        Situation.for_date(date).map(&:revision).sort.reverse
      end
    end

    def guild_names_for_date(date)
      return [] unless date
      get_with_cache("guild_names_for_#{date}") do
        Situation.guild_names_for(date)
      end
    end

    def guild_names_for_all
      get_with_cache("guild_names_for_all") do
        Caller.uniq(:guild_name).pluck(:guild_name).sort
      end
    end

    def guild_names_for_recently(span = nil)
      span ||= ServerSettings.data_size_recently
      return [] if span < 1
      return guild_names_for_date(date) if span == 1

      get_with_cache("guild_names_for_recently_#{span}") do
        dates = timeline_dates.take(span)
        Caller.for_date(dates).uniq(:guild_name).pluck(:guild_name).sort
      end
    end

    def guild_names_for_select(all = false)
      all ? guild_names_for_all : guild_names_for_recently
    end

    def result_dates
      get_with_cache('result_dates') do
        Ruler.gvdates.reverse
      end
    end

    def clear_all
      Rails.cache.clear
    end

    private

    def cache_enable?
      return true if ServerSettings.sample_mode?
      TimeUtil.in_battle_time? ? false : true
    end

    def get_with_cache(name, &b)
      return unless (name && b)
      return b.call unless cache_enable?

      data = Rails.cache.read(name)
      return data if data

      ret = b.call
      return unless ret
      Rails.cache.write(name, ret)

      ret
    end

  end

end
