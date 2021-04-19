# frozen_string_literal: true

if ARGV.length != 1
  warn "Wrong number of argumnets!\n"
  exit(-1)
end

require 'oauth2'
UID     = 'ed80c9902ad958f45d92b2af4724b63f7112e47b6511bd88d9944fb2998271ec'
SECRET  = 'f3034c9dfdf751ca8b5345b04fda75fb664003a57ea738eac282f2c4113babea'
LOGIN   = ARGV[0]

begin
  client = OAuth2::Client.new(UID, SECRET, site: 'https://api.intra.42.fr')
  token = client.client_credentials.get_token

  file = File.open('ex01.out', 'w')
  File.chmod(0777, 'ex01.out')

  response      = token.get("/v2/users/#{LOGIN}")
  Parsed_login  = response.parsed['login']
  Parsed_id     = response.parsed['id']

  # if response.nil?
  #   warn 'EMPTY'
  #   exit(-1)
  # end

  if LOGIN == Parsed_login
    file.puts "user_id: #{Parsed_id}"
  else
    file.puts "login:   #{Parsed_login}"
  end

  if File.zero?(file)
    puts 'EMPTY'
    File.delete('./ex01.out')
  end

rescue OAuth2::Error => e
  if e.response.status == 500
    retry
  else
    warn e.response.status
  end
end
