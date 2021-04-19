# frozen_string_literal: true

require 'oauth2'
require 'time_difference'
UID = 'ed80c9902ad958f45d92b2af4724b63f7112e47b6511bd88d9944fb2998271ec'
SECRET = 'f3034c9dfdf751ca8b5345b04fda75fb664003a57ea738eac282f2c4113babea'

begin

  client = OAuth2::Client.new(UID, SECRET, site: 'https://api.intra.42.fr')
  token = client.client_credentials.get_token

  LOGIN = ARGV[0]

  file = File.open('ex06.out', 'w')
  File.chmod(0777,'ex06.out')
  #=================================================== VARIABLES =========================================================
  i                = 1
  logged_times     = 0
  total_time       = 0
  Logs_struct      = Struct.new(:sess, :host)
  curr_logs        = Logs_struct.new(1, nil)
  max_logs         = Logs_struct.new(0, nil)
  Host_time_struct = Struct.new(:time_host, :host)
  curr_host_time   = Host_time_struct.new(0.0, nil)
  max_host_time    = Host_time_struct.new(0.0, nil)
  #==================================================== RESPONSE =========================================================
  loop do
    response = token.get("/v2/users/#{LOGIN}/locations?page[number]=#{i}&sort=host")

    response.parsed.each do |session|
      # puts session
      next if session['end_at'].nil?

      total_time += TimeDifference.between(session['begin_at'], session['end_at']).in_seconds
      if session['host'] == curr_logs.host
        curr_logs.sess += 1
      else
        if max_logs.sess < curr_logs.sess
          max_logs.sess  = curr_logs.sess
          max_logs.host  = curr_logs.host
        end
        curr_logs.sess   = 1
        curr_logs.host   = session['host']
        max_logs.host    = curr_logs.host if max_logs.host.nil?
      end
    end

    logged_times += response.parsed.length
    break if response.parsed.empty?

    sleep 0.5 # to solve limit of responses per sec (2req / sec)
    i += 1
  end

  i = 0
  #================================================== RESPONSE 2 =========================================================
  loop do
    response = token.get("/v2/users/#{LOGIN}/locations?page[size]=100&page[number]=#{i}&sort=host")

    response.parsed.each do |session|
      next if session['end_at'].nil?

      # total_time += TimeDifference.between(session['begin_at'], session['end_at']).in_seconds
      if session['host'] == curr_logs.host
        curr_host_time.time_host += TimeDifference.between(session['begin_at'], session['end_at']).in_seconds
      else
        if max_host_time.time_host < curr_host_time.time_host
          max_host_time.time_host  = curr_host_time.time_host
          max_host_time.host       = curr_host_time.host
        end
        curr_host_time.time_host   = TimeDifference.between(session['begin_at'], session['end_at']).in_seconds
        curr_host_time.host        = session['host']
        if max_host_time.host.nil?
          max_host_time.host       = curr_host_time.host
          max_host_time.time_host  = curr_host_time.time_host
        end
      end
    end

    break if response.parsed.empty?

    sleep 0.5 # to solve limit of responses per sec (2req / sec)
    i += 1
  end
  #======================================= PUT INTO THE FILE =============================================================
  if logged_times.zero?
    file.puts 'No location'
    exit(0)
  end

  file.puts "Total number of connections : #{logged_times}"
  file.puts "Most connected host : #{max_logs.host} with #{max_logs.sess} connections"

  mm, ss = total_time.divmod(60.0)
  hh, mm = mm.divmod(60)
  dd, hh = hh.divmod(24)
  file.puts "Scolarity log time : %d days, %d:%.2d:%09.6f" % [dd, hh, mm, ss]

  mm, ss = max_host_time.time_host.divmod(60.0)
  hh, mm = mm.divmod(60)
  dd, hh = hh.divmod(24)
  file.puts "Most logged host : #{max_host_time.host} with a logtime of %d days, %d:%.2d:%09.6f" % [dd, hh, mm, ss]

  if File.zero?(file)
    puts 'EMPTY'
    File.delete('./ex06.out')
  end

  rescue OAuth2::Error => e
    if e.response.status == 500
      retry
    else
      warn e.response.status
    end
end