require 'sinatra'

$br = "\n"

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
    m = ["eat me"]
    i = 0
    while true do
      m[i] = 'munch!'
      i = i + 100000 #about 225MB/min
      sleep 0.20
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
    sleep 5
    Thread.list.each {|th|
      if th.to_s.include? "reactor" or th.to_s.include? "app.rb" then
        puts "killing #{th.to_s}"
        th.kill
      end
    }
  end
end

# Formatting helpers

def escape_html(s)
  html_escape_table = {
    '&' => '&amp;',
    '"' => '&quot;',
    "'" => '&#x27;',
    '<' => '&lt;',
    '>' => '&gt;'
  }
  return s.gsub(/[&"'<>]/, html_escape_table)
end

def bold(s)
  return "<b>" + s.to_s + "</b>"
end

def pre(s)
  return "<pre>" + s.to_s + "</pre>"
end 

before do
  response.body << "<body style=\"background-color:#{$html_bg_color};\">"
  out = ""
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
  out << $br
  response.body << (bold pre escape_html out)
end

get '/' do
  out = ""
  out << "AVAILABLE ROUTES" + $br
  Sinatra::Application.routes["GET"].each do |route| out << route[0].to_s + $br
  end
  response.body << (bold pre escape_html out)
end

get '/cpu' do
  random_cpu
  out = bold "Let's do some work!"
  response.body << out
end

get '/fullcpu' do
  full_cpu
  out = bold 'FULL THROTTLE!'
  response.body << out
end

get '/memory' do
  eat_memory
  out = bold 'Munch! Munch! Munch!'
  response.body << out
end

get '/kill' do
  kill_me
  out = bold 'What a world! What a world!'
  response.body << out
end

get '/braindead' do
  braindead
  out = bold "The lights are on, but there's no one home."
  response.body << out
end

get '/alive' do
  out = bold "I'm doing science and I'm still alive (since #{start_time.inspect})"
  response.body << out
end

get '/ready' do
  out = ""
  if $ready_mode == "fast" || start_time < Time.now - 30 && $ready_mode != "never"
    out = 'Thunder cats are go!'
  else
    status 500
    out = "<p style=\"color:red;font-size:300%;-webkit-text-stroke-width: 2px;-webkit-text-stroke-color: black;\">I'm not ready yet!!</p>"
  end
  response.body << (bold out)
end

get '/threads' do
  out = ""
  Thread.list.each {|th| out << escape_html(th.to_s) + $br}
  response.body << (pre out)
end

after do
  out = ""
  out << $br
  out << $br
  out << $br
  out << "-------------------" + $br
  out << bold("HOSTNAME: #{ENV["HOSTNAME"].to_s}")
  out << $br
  out << $br
  out << "ENVIRONMENT VARIABLES"
  out << $br
  out << $br
  for v in ENV
    out << v.to_s + $br
  end
  response.body << pre(out)
end

after do

end

startup
