# coding: utf-8
require 'optparse'
require 'json'
require 'date'

options = {}
opt = OptionParser.new
opt.on('-e ENV', '--env=ENV', 'execute env, equal to RAILS_ENV=env'){|v| options[:env] = v}
opt.on('-d DATE', '--date=DATE', 'import only DATE'){|v| options[:date] = v}
opt.parse!(ARGV)

RAILS_ENV = options[:env] if options[:env]

path = ARGV[0]
unless (path && File.exists?(path))
  puts "unknown path => #{path}"
  exit
end

date =  lambda do |d|
  (d && d.match(/\A\d{8}\z/)) ? d : nil
end.call(options[:date])

class Importer

  class << self

    def execute(path, date = nil)
      self.new.execute(path, date)
    end

  end

  def execute(path, date = nil)
    return unless (path && File.exists?(path))

    flist = if date
      df = File.expand_path(File.join(path, "#{date}.txt"))
      raise "date file not found => #{df}" unless File.exists?(df)
      [df]
    else
      Dir.glob("#{path}/*.txt").sort.to_a
    end

    flist.each do |f|
      if f.match(/manual.txt\z/)
        File.readlines(f).each{|l| import_for_rulers(l)}
      else
        File.readlines(f).each{|l| import_for_situations(l)}
      end
    end
  end

  private

  def import(line)
    begin
      return if line.empty?
      data = JSON.parse(line)
      return if data.empty?
      yield(data)
    rescue => e
      puts e
      puts "import failed => #{line}\n"
    end
  end

  def import_for_situations(line)
    import(line) do |data|
      s = Situation.new
      s.revision = data['revision']
      s.gvdate = data['gv_date']
      s.update_time = Time.parse(data['update_time'])

      data['forts'].each do |d|
        f = Fort.new
        f.fort_code = d['fort_id']
        next unless FortUtil.valid_fort_code?(f.fort_code)
        f.fort_group = f.fort_code.first
        next unless FortUtil.fort_groups?(f.fort_group)
        f.revision = s.revision
        f.gvdate = s.gvdate
        f.fort_name = d['fort_name']
        f.formal_name = d['formal_name']
        f.guild_name = d['guild_name']
        f.update_time = Time.parse(d['update_time'])
        s.forts << f
      end
      return if s.forts.empty?

      s.cut_in!
    end
  end

  def import_for_rulers(line)
    import(line) do |data|
      ActiveRecord::Base.transaction do
        date = data['gv_date']
        next unless date

        data['forts'].each do |fd|
          fcd = fd['fort_id']
          next unless FortUtil.valid_fort_code?(fcd)
          next unless FortUtil.fort_groups?(fcd.first)
          f = forts[fcd]

          r = Ruler.new
          r.gvdate = date
          r.fort_group = fcd.first
          r.fort_code = fcd
          r.fort_name = (f ? f.fort_name : '')
          r.formal_name = (f ? f.formal_name : '')
          r.guild_name = fd['guild_name']
          r.source = Ruler::SOURCE_MANUAL
          r.full_defense = false
          r.save!
        end
      end      
    end
  end

  def forts
    @forts ||= (Situation.latest || Situation.new).forts_map
    @forts
  end

end

Importer.execute(path, date)

exit
