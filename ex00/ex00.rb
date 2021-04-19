# frozen_string_literal: true

if ARGV.length != 0
  warn "Wrong number of argumnets!\n"
  exit(-1)
end

require 'oauth2'
require 'net/http'
require 'uri'
require 'json'
require 'neatjson'

begin
  uri     = URI.parse('https://api.intra.42.fr/oauth/token')
  request = Net::HTTP::Post.new(uri)
  UID     = 'ed80c9902ad958f45d92b2af4724b63f7112e47b6511bd88d9944fb2998271ec'
  SECRET  = 'f3034c9dfdf751ca8b5345b04fda75fb664003a57ea738eac282f2c4113babea'

  request.set_form_data(
    'client_id' => UID,
    'client_secret' => SECRET,
    'grant_type' => 'client_credentials'
  )
  req_options = {
    use_ssl: uri.scheme == 'https'
  }

  response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    http.request(request)
  end

  parsed_json = JSON.parse(response.body)

  file        = File.open('ex00.out', 'w')
  File.chmod(0777, 'ex00.out')

  file.puts JSON.neat_generate(parsed_json, aligned: true) # perfect lookup from bMicheal)

  if File.zero?(file)
    puts 'EMPTY'
    File.delete('./ex00.out')
  end

rescue OAuth2::Error => e
  if e.response.status == 500
    retry
  else
    warn e.response.status
  end
end

# THERE iS NO ONE SUCH FORUM
#           Ill Go to Hogwarts and find original map! not std::map!
# "Slytherin will help you on your way to greatness"
