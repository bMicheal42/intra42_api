# frozen_string_literal: true

if ARGV.length != 1
  warn "Wrong number of argumnets!\n"
  exit(-1)
end

require   'oauth2'

UID       = 'ed80c9902ad958f45d92b2af4724b63f7112e47b6511bd88d9944fb2998271ec'
SECRET    = 'f3034c9dfdf751ca8b5345b04fda75fb664003a57ea738eac282f2c4113babea'
LOGIN     = ARGV[0]

begin
  client    = OAuth2::Client.new(UID, SECRET, site: 'https://api.intra.42.fr')
  token     = client.client_credentials.get_token

  file      = File.open('ex02.out', 'w')
  File.chmod(0777,'ex02.out')

  response  = token.get('/v2/cursus/42/users')
  cursus    = token.get("/v2/users/#{LOGIN}").parsed

  month     = Date.parse("#{cursus['pool_month']}")

  file.puts "app_name:          #{response.headers['X-Application-Name']}"
  file.puts "app_id:            #{response.headers['X-Application-Id']}"
  file.puts "user_id:           #{cursus['id']}"
  file.puts "level_42:          #{cursus['cursus_users'][1]['level']}"
  file.puts "level_algo_ai:     #{cursus['cursus_users'][1]['skills'][1]['level']}"
  file.puts "level_piscine:     #{cursus['cursus_users'][0]['level']}"
  file.puts "pool:              #{month.mon} #{cursus['pool_year']}"
  file.puts "achievements:      #{cursus['achievements'].size}"
  file.puts "wallets:           #{cursus['wallet']}"
  file.puts "correction_points: #{cursus['correction_point']}"

  if File.zero?(file)
    puts 'EMPTY'
    File.delete('./ex02.out')
  end

rescue OAuth2::Error => e
  if e.response.status == 500
    retry
  else
    warn e.response.status
  end
end
