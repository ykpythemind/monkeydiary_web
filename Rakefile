task default: :generate

desc "generate page"
task :generate do
  require_relative 'generator'

  MonkeyDiary::Generator.new.generate!
end

desc "serve"
task :serve => [:generate] do
  require 'webrick'
  srv = WEBrick::HTTPServer.new({ :DocumentRoot => './',
                                :BindAddress => '127.0.0.1',
                                :Port => 20080})
  trap("INT"){ srv.shutdown }
  srv.start
  puts "listening... http://localhost:20080"
end
