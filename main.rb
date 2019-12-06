require 'bundler/setup'

require 'pathname'
require 'date'
require 'erb'
require 'fileutils'
require 'tmpdir'

module MonkeyDiary
  Diary = Struct.new(:path, :datetime) do
    def read_content
      File.read(path)
    end
  end

  class Generator
    def initialize(dist_dir = 'dist')
      @dist_dir = dist_dir
    end

    def targets
      @targets ||= Dir.entries('data')
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

  class Git
    REPO = "monkeydiary_web"
    URL = "github.com/ykpythemind/#{REPO}"

    def initialize(target_dir)
      @target_dir = File.absolute_path(target_dir)
    end

    def execute
      at_tmpdir do |dir|
        git "clone https://#{auth}@#{URL} ."

        git 'checkout -b gh-pages'

        FileUtils.cp_r(Pathname.new(@target_dir).glob('**/*'), dir)
        # puts `ls -la #{dir}`

        git 'add .'
        git 'commit -m "ok"'

        git "push https://#{auth}@#{URL} -f -u origin gh-pages"
      end
    end

    private

    def git(args)
      puts `git #{args}`
      raise "git operation failed" if $?.success?
    end

    def at_tmpdir
      Dir.mktmpdir do |dir|
        Dir.chdir(dir) do
          yield dir
        end
      end
    end

    def auth
      "ykpythemind:#{ENV.fetch('GITHUB_TOKEN')}"
    end
  end
end
