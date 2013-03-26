# coding: utf-8
require 'optparse'

options = {}
opt = OptionParser.new
opt.on('-e ENV', '--env=ENV', 'execute env, equal to PADRINO_ENV=env'){|v| options[:env] = v}
opt.on('-d DATE', '--date=DATE', 'date of add total (this is usually unnecessary)'){|v| options[:date] = v}
opt.parse!(ARGV)

RAILS_ENV = options[:env] if options[:env]
date = options[:date] || Ruler.gvdates.max

rulers = Ruler.for_date(date)
guilds = GuildResult.for_date(date)

exit if rulers.empty? && guilds.empty?

data = {}
data['gv_date'] = date

data['forts'] = rulers.map do |r|
  f = {}
  f['fort_id'] = r.fort_code
  f['fort_name'] = r.fort_name
  f['formal_name'] = r.formal_name
  f['guild_name'] = r.guild_name
  f
end

data['guilds'] = guilds.map do |gr|
  g = {}
  g['gv_date'] = gr.gvdate
  g['name'] = gr.guild_name
  g['called'] = FortUtil.fort_groups.inject({}) do |h, g|
    count = gr.called_count_for_group(g)
    h[g] = count if count > 0
    h
  end
  g
end

c = HTTPClient.new
res = c.post("http://#{ServerSettings.viewer_target}/update", :result => data.to_json)
raise "update error" unless HTTP::Status.successful?(res.status)

exit
