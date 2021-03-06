require 'zip'

module Moodle2CC::Moodle
  class Backup
    include HappyMapper

    attr_accessor :backup_file, :files

    tag 'MOODLE_BACKUP'
    has_one :info, Info
    has_one :course, Course

    def self.read(backup_file)
      Zip::File.open(backup_file) do |zipfile|
        xml = zipfile.read("moodle.xml")
        backup = parse xml
        backup.backup_file = backup_file
        backup.files = zipfile.entries.select { |e| e.name =~ /^course_files/ && !e.directory? }.
          map { |e| e.name.sub('course_files/', '') }.sort
        backup
      end
    end

    def copy_files_to(dir)
      Zip::File.open(@backup_file) do |zipfile|
        @files.each do |file|
          destination_file = File.join(dir, file)
          FileUtils.mkdir_p(File.dirname(destination_file))
          File.open(destination_file, 'w') do |f|
            f.write zipfile.read("course_files/#{file}")
          end
        end
      end
    end
  end
end
