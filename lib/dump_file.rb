class DumpFile
  include TimeUtil

  attr_reader :filename, :revision

  class << self
    def find_by_filename(fn)
      return unless fn
      df = self.new
      df.set_filename(fn)
      df.exist? ? df : nil
    end

    def find_by_revision(rev)
      return unless rev
      df = self.new
      df.set_revision(rev)
      df.exist? ? df : nil
    end

    def all
      Dir.glob("#{Dumper.dump_path}/dump_*").map{|fn| self.find_by_filename(fn)}.compact
    end
  end

  def set_filename(fn)
    f = File.basename(fn)
    return if f.nil? || f.empty?
    @filename = f
    @revision = f[/\Adump_(\d+)/, 1]
    self
  end

  def set_revision(rev)
    return unless rev
    @revision = rev
    @filename = "dump_#{rev}.tar.gz"
    self
  end

  def full_path
    return if filename.blank?
    File.join(Dumper.dump_path, filename)
  end

  def dump_time
    return if self.revision.blank?
    revision_to_formet_time(self.revision)
  end

  def exist?
    return false if filename.blank?
    return false if revision.blank?
    File.exist?(full_path) ? true : false
  end

  def delete!
    return unless exist?
    File.unlink(full_path)
    self
  end
end