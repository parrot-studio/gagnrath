# coding: utf-8
class ServerSettings < Settingslogic
  source File.expand_path('../../config/settings.yml', __FILE__)
  namespace Rails.env
  load!

  class << self

    def app_path
      self.env.app_path || ''
    end

    def secret_key_base
      base = self.env.secret_key_base
      if base.blank? || base.size < 30
        raise 'You may not set "env.secret_key_base" setting. You need execute "rake secret", and add value.'
      end
      base
    end

    def sample_mode?
      self.env.sample_mode ? true : false
    end

    def view_mode?
      self.env.view_mode ? true : false
    end

    def time_lock?
      self.env.time_lock ? true : false
    end

    def basic_auth_params
      {name: self.auth.basic.user, password: self.auth.basic.pass}
    end

    def gvtype
      t = self.env.gvtype.to_s
      case t.upcase
      when 'FE', 'SE', 'FESE'
        'FE'
      when 'TE'
        'TE'
      else
        'FE'
      end
    end

    def gvtype_fe?
      gvtype == 'FE' ? true : false
    end

    def gvtype_te?
      gvtype == 'TE' ? true : false
    end

    def memcache_server
      self.memcache.server.blank? ? 'localhost:11211' : self.memcache.server
    end

    def memcache_namespace
      self.memcache.namespace + '_gagnrath'
    end

    def memcache_expire_time
      min = self.memcache.expire.to_i
      (min > 0 ? min : 1).minutes
    end

    def data_size_recently
      val = self.env.data_size.recently.to_i
      return 6 if val < data_size_min || val > data_size_max
      val
    end

    def data_size_min
      val = self.env.data_size.min.to_i
      return 4 if val < 1
      val
    end

    def data_size_max
      val = self.env.data_size.max.to_i
      return 12 if val < 1
      val
    end

    def data_size_range
      (data_size_min..data_size_max)
    end

    def timeline_span_max_size
      val = self.env.timeline.span_max_size.to_i
      return 1 if val <= 0
      return data_size_max if val > data_size_max
      val
    end

    def use_mail?
      self.env.use_mail ? true : false
    end

    def union_history_size
      size = self.env.union_history.max_size
      size.to_i > 0 ? size : 10
    end

    def only_union_history?
      self.env.union_history.only_union ? true : false
    end

    def dump_generation
      g = self.env.dump_generation.to_i
      g > 0 ? g : 0
    end

  end

end
