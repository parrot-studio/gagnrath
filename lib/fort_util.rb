module FortUtil

  module_function

  def gvtype_fe?
    ServerSettings.gvtype_fe? ? true : false
  end

  def gvtype_se?
    gvtype_fe? ? true : false
  end

  def gvtype_te?
    ServerSettings.gvtype_te? ? true : false
  end

  def fort_groups
    case
    when gvtype_fe?
      [fort_groups_fe, fort_groups_se].flatten
    when gvtype_te?
      fort_groups_te
    end
  end

  def fort_groups_fe
    ['V', 'C', 'B', 'L']
  end

  def fort_groups_se
    ['N', 'F']
  end

  def fort_groups_te
    ['G', 'K']
  end

  def fort_nums
    (1..5).to_a
  end

  def fort_groups?(t)
    return false unless t
    fort_groups.include?(t) ? true : false
  end

  def fort_groups_fe?(t)
    return unless t
    fort_groups_fe.include?(t) ? true : false
  end

  def fort_groups_se?(t)
    return unless t
    fort_groups_se.include?(t) ? true : false
  end

  def fort_groups_te?(t)
    return unless t
    fort_groups_te.include?(t) ? true : false
  end

  def valid_fort_code?(t)
    return false unless t
    m = t.match(/\A(.)(\d)\Z/)
    return false unless m
    return false unless fort_groups?(m[1])
    return false unless fort_nums.include?(m[2].to_i)
    true
  end

  def each_fort_code
    return enum_for(:each_fort_code) unless block_given?
    fort_groups.each do |fg|
      fort_nums.each do |n|
        yield("#{fg}#{n}")
      end
    end
  end

  def fort_codes_for(f)
    return [] unless fort_groups?(f)
    fort_nums.map{|i| "#{f}#{i}"}
  end

  def fort_codes_for_se
    fort_groups_se.map{|f| fort_codes_for(f)}.flatten
  end

  def fort_codes_for_te
    fort_groups_te.map{|f| fort_codes_for(f)}.flatten
  end

end
