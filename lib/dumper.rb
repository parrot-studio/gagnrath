# coding: utf-8
class Dumper
  include TimeUtil

  class << self
    def dump_path
      File.expand_path(File.join(Rails.root, 'dump'))
    end

    def execute
      self.new.execute
    end
  end

  def dump_path
    self.class.dump_path
  end

  def dump_time
    @dump_time ||= DateTime.now
    @dump_time
  end

  def dump_name
    "dump_#{time_to_revision(dump_time)}.sql"
  end

  def dump_output_path
    File.join(dump_path, dump_name)
  end

  def archive_file_name
    "dump_#{time_to_revision(dump_time)}.tar.gz"
  end

  def archive_file_path
    File.join(dump_path, archive_file_name)
  end

  def config
    @config ||= lambda do
      path = File.expand_path(File.join(Rails.root, 'config', 'database.yml'))
      conf = YAML.load(File.read(path))
      conf[Rails.env]
    end.call
    @config
  end

  def dump
    FileUtils.mkdir_p(dump_path) unless File.exist?(dump_path)
    FileUtils.rm_r(dump_output_path) if File.exist?(dump_output_path)

    cmd = "mysqldump -u #{config['username']} -p#{config['password']}"
    cmd << " -h #{config['host']}" if config['host']
    cmd << " -P #{config['port']}" if config['port']
    cmd << " #{config['database']} > #{dump_output_path}"

    rsl = ExecuteCommand.execute(cmd)
    raise "dump error => #{rsl.result}" if rsl.has_error?
    raise "dump missing" unless File.exist?(dump_output_path)

    self
  end

  def archive
    File.unlink(archive_file_path) if File.exist?(archive_file_path)
    return self unless File.exist?(dump_output_path)

    cmd = "cd #{dump_path}; tar czf #{archive_file_name} #{dump_name}"
    rsl = ExecuteCommand.execute(cmd)
    raise "archive error => #{rsl.result}" if rsl.has_error?
    raise "archive missing" unless File.exist?(archive_file_path)
    FileUtils.rm_r(dump_output_path) if File.exist?(dump_output_path)

    self
  end

  def send_mail
    m = AdminMailer.dump_backup(archive_file_path)
    m.deliver if m
    m
  end

  def clear_dump
    return if ServerSettings.dump_generation <= 0
    return self unless File.exist?(dump_path)

    flist =[]
    Dir.glob("#{dump_path}/*.tar.gz").each do |f|
      flist << [f, File.mtime(f)]
    end

    file_list = flist.sort_by{|f| -f.last.to_i}.map(&:first)
    ServerSettings.dump_generation.times{ file_list.shift }
    return if file_list.empty?
    file_list.each{|f| File.unlink(f)}

    file_list
  end

  def execute
    dump.archive
    send_mail if ServerSettings.use_mail?
    clear_dump if ServerSettings.dump_generation > 0
    self
  end
end