# frozen_string_literal: true

if ARGV.length != 3
  warn "Wrong number of argumnets!"
  exit(-1)
end

require 'oauth2'

UID    = 'ed80c9902ad958f45d92b2af4724b63f7112e47b6511bd88d9944fb2998271ec'
SECRET = 'f3034c9dfdf751ca8b5345b04fda75fb664003a57ea738eac282f2c4113babea'
MONTH  = ARGV[1]
YEAR   = ARGV[2]

begin

  client = OAuth2::Client.new(UID, SECRET, site: 'https://api.intra.42.fr')
  token  = client.client_credentials.get_token
  CAMPUS = token.get("/v2/campus?filter[name]=#{ARGV[0]}").parsed[0]['id']

  file   = File.open('ex03.out', 'w')
  File.chmod(0777,'ex03.out')
  i = 1
  loop do
    response = token.get("/v2/campus/#{CAMPUS}/users?page[number]=#{i}&filter[pool_month]=#{MONTH}&filter[pool_year]=#{YEAR}&sort=login")
    response.parsed.each do |user|
      file.puts user['login']
    end
    break if response.parsed.empty? # loop while response not empty

    sleep 0.5 # to solve limit of responses per sec (2req / sec)
    i += 1
  end

rescue OAuth2::Error => e
  if e.response.status == 500
    retry
  else
    warn e.response.status
  end

rescue NoMethodError
  warn "ERROR!\nWrite args in right way: Campus - Month - Year of a Piscine\ne.g. Moscow september 2020\n"
end
