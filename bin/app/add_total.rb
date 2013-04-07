# coding: utf-8
require 'optparse'

options = {}
opt = OptionParser.new
opt.on('-e ENV', '--env=ENV', 'execute env, equal to RAILS_ENV=env'){|v| options[:env] = v}
opt.on('-d DATE', '--date=DATE', 'totalize only this date'){|v| options[:date] = v}
opt.on('-f DATE', '--from=DATE', 'totalize from this date'){|v| options[:from] = v}
opt.on('-t DATE', '--to=DATE', 'totalize to this date'){|v| options[:to] = v}
opt.parse!(ARGV)

RAILS_ENV = options[:env] if options[:env]

sdates = [Situation.gvdates, Ruler.gvdates].flatten.uniq.sort.compact
dates = case
when options[:date]
  exit unless Situation.gvdates.include?(options[:date])
  [options[:date]]
when  options[:from] || options[:to]
  sdates = sdates.select{|d| d >= options[:from]} if options[:from]
  sdates = sdates.select{|d| d <= options[:to]} if options[:to]
  sdates
else
  max_date = Ruler.gvdates.max
  max_date ? sdates.select{|d| d > max_date} : sdates
end

dates.sort.each do |d|
  Ruler.add_rulers_for_date(d)
  GuildResult.add_result_for_date(d)
end
CacheData.clear_all

exit
