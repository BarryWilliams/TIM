require 'faraday'

puts ARGV

$num_threads = ( ENV["NUM_THREADS"] || "1" ).to_i
$timeout =     ( ENV["TIMEOUT"]     || "1.0" ).to_f

$url = ARGV[0] || ENV["URL"] || ""

$num_calls = 0
$non_200   = 0
$num_timeouts = 0

if not $url.include? "http" then
  puts "Invalid URL: #{$url.to_s}"
  puts "exiting"
  exit 1
end

puts "NUM_THREADS = #{$num_threads.to_s}"

def startup
  full_cpu if $consumed_cpu_mode == "full"
end


def make_client_thread
  th = Thread.new {
    i = 0
    while true do
      $num_calls += 1
      con = Faraday::Connection.new
      con.options.timeout = $timeout
      begin
        r = con.get($url)
        $non_200 += 1 if r.status != 200
      rescue
        $num_timeouts += 1 
      end
    end
  }

  puts th.to_s
  return th
end

threads = Array.new($num_threads) { make_client_thread }

while true do
  puts "Calls: #{$num_calls.to_s}    Non-200: #{$non_200.to_s}    Timeouts: #{$num_timeouts}"
  sleep(1)
end
