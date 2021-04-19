# frozen_string_literal: true

if ARGV.length != 3
  warn "Wrong number of argumnets!"
  exit(-1)
end

require 'oauth2'
require 'date'

UID     = 'ed80c9902ad958f45d92b2af4724b63f7112e47b6511bd88d9944fb2998271ec'
SECRET  = 'f3034c9dfdf751ca8b5345b04fda75fb664003a57ea738eac282f2c4113babea'
MIN     = ARGV[2]

begin

  client  = OAuth2::Client.new(UID, SECRET, site: 'https://api.intra.42.fr')
  token   = client.client_credentials.get_token
  CAMPUS  = token.get("/v2/campus?filter[name]=#{ARGV[0]}").parsed[0]['id']
  PROJECT = token.get("v2/projects?filter[name]=#{ARGV[1]}").parsed[0]['id']

  file    = File.open('ex04.out', 'w')
  File.chmod(0777,'ex04.out')

  today     = Time.now
  first     = Date.civil(today.year-1, today.month, today.day)
  last      = Date.civil(today.year, today.month, today.day)
  cursus    = token.get("/v2/projects/#{PROJECT}/projects_users?filter[campus]=#{CAMPUS}" \
              "&marked=true&range[final_mark]=#{MIN},125&range[marked_at]=#{first},#{last}&sort=final_mark").parsed

  arr = []
  cursus.each do |i|
    arr << [i['final_mark'].to_i, i['user']['login']]
  end

  arr.sort_by! { |str| [-str[0].to_i, str[1]] }
  file.puts(arr.map { |str| str.join(' ') })

  if File.zero?(file)
    puts 'EMPTY'
    File.delete('./ex04.out')
  end

rescue OAuth2::Error => e
  if e.response.status == 500
    retry
  else
    warn e.response.status
  end

rescue NoMethodError
  warn "ERROR!\nWrite args in right way: Campus - Project - Mark\ne.g. Moscow ft_printf 115\n"
end
