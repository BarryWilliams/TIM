require 'sinatra'

start_time = Time.now

$ready_mode           = ENV["READY_MODE"]           || "normal"
$consumed_cpu_mode    = ENV["CONSUMED_CPU_MODE"]    || "minimal"
$consumed_memory_mode = ENV["CONSUMED_MEMORY_MODE"] || "minimal"
$html_bg_color        = ENV["HTML_BG_COLOR"]        || "white"

puts "READY_MODE = #{$ready_mode}"
puts "CONSUMED_CPU_MODE = #{$consumed_cpu_mode}"
puts "CONSUMED_MEMORY_MODE = #{$consumed_memory_mode}"
puts "HTML_BG_COLOR = #{$html_bg_color}"

def startup
  full_cpu if $consumed_cpu_mode == "full"
  random_cpu if $consumed_cpu_mode == "random"
  eat_memory if $consumed_memory_mode == "unlimited"
end

set :bind, '0.0.0.0'

def full_cpu
  puts 'creating a 100% cpu thread'
  Thread.new do
    while true do
    end
  end
end

def random_cpu
  puts 'doing random cpu usage'
  granularity_seconds = 1.00
  min_cpu = 0.2
  max_cpu = 0.6
  Thread.new do
    loop do
      t = Time.now.to_f

      Thread.new do
        r = rand(min_cpu..max_cpu) * granularity_seconds
        while Time.now.to_f < t + r do
          for i in 1..100000 do
            #noop
          end
        end
      end

      sleep granularity_seconds
    end
  end
end

def eat_memory
  puts "eating memory"
  Thread.new do
    m = []
    while true do
      m.append 'munch!'
    end
  end
end

def kill_me
  puts "killing process"
  Thread.new do
    pid = Process.pid
    system 'kill', pid.to_s
  end
end

def braindead
  puts "going braindead"
  Thread.new do
    Thread.list.each {|th|
      if th.to_s.include? "reactor"
        puts "killing #{th.to_s}"
        th.kill
      end
    }
  end
end

get '/' do
  br = "\n"
  out = ""
  out << "<body style=\"background-color:#{$html_bg_color};\">"
  out << "<pre>"
  out << "
 .----------------.  .----------------.  .----------------.  .----------------.  .----------------. 
| .--------------. || .--------------. || .--------------. || .--------------. || .--------------. |
| |  _________   | || |     _____    | || | ____    ____ | || | ____    ____ | || |  ____  ____  | |
| | |  _   _  |  | || |    |_   _|   | || ||_   \\  /   _|| || ||_   \\  /   _|| || | |_  _||_  _| | |
| | |_/ | | \\_|  | || |      | |     | || |  |   \\/   |  | || |  |   \\/   |  | || |   \\ \\  / /   | |
| |     | |      | || |      | |     | || |  | |\\  /| |  | || |  | |\\  /| |  | || |    \\ \\/ /    | |
| |    _| |_     | || |     _| |_    | || | _| |_\\/_| |_ | || | _| |_\\/_| |_ | || |    _|  |_    | |
| |   |_____|    | || |    |_____|   | || ||_____||_____|| || ||_____||_____|| || |   |______|   | |
| |              | || |              | || |              | || |              | || |              | |
| '--------------' || '--------------' || '--------------' || '--------------' || '--------------' |
 '----------------'  '----------------'  '----------------'  '----------------'  '----------------' 
"
  out << br
  out << "$HOSTNAME = #{ENV["HOSTNAME"]}" + br
  out << br
  out << "AVAILABLE ROUTES" + br

  Sinatra::Application.routes["GET"].each do |route|
    out << route[0].to_s + br
  end
  out << "</pre>"
  out
end

get '/cpu' do
  random_cpu
  'I feel crazy!'
end

get '/fullcpu' do
  full_cpu
  'Ramp it up!'
end

get '/memory' do
  eat_memory
  'munch munch munch'
end

get '/kill' do
  kill_me
  'What a world! What a world!'
end

get '/braindead' do
  braindead
  "I'm gone"
end

get '/alive' do
  "I'm doing science and I'm still alive (since #{start_time.inspect})"
end

get '/ready' do
  if $ready_mode == "fast" || start_time < Time.now - 30 && $ready_mode != "never"
    'Thunder cats are go!'
  else
    status 500
    "I'm not ready yet"
  end
end

startup
