require 'net/http'

$num_threads = ( ENV["NUM_THREADS"] || "20" ).to_i
$url = ARGV[1] || ENV["URL"] || ""

$num_calls = 0

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
      res = Net::HTTP.get_response(URI($url))
      puts "got response code: #{res.code.to_s}" if res.code != "200"
    end
  }

  puts th.to_s
  return th
end

threads = Array.new($num_threads) { make_client_thread }

while true do
  puts $num_calls.to_s
  sleep(1)
end
