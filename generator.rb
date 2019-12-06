require 'bundler/setup'

require 'pathname'
require 'date'
require 'erb'
require 'fileutils'

module MonkeyDiary
  Diary = Struct.new(:path, :datetime)

  class Generator
    def initialize(dist_dir = 'dist')
      @dist_dir = dist_dir
    end

    def target_files
      @target_files ||= Dir.entries('data')
                           .reject { |name| name.start_with?('.') }
                           .map { |name|
                              Diary.new(
                                Pathname.new('./').join('data', name),
                                DateTime.parse(name),
                              )
                            }
                            .sort { |s1, s2| s2.datetime <=> s1.datetime }
    end

    def generate!
      result = erb.result(binding)

      cleanup

      puts result

      File.open(Pathname(@dist_dir).join('index.html'), 'w') do |f|
        f.puts result
      end
    end

    def erb
      @erb ||= ERB.new(::File.read('template.html.erb'))
    end

    private

    def cleanup
      FileUtils.remove_dir(@dist_dir) if Dir.exist?(@dist_dir)
      FileUtils.mkdir(@dist_dir)
    end
  end
end
