# frozen_string_literal: true

if ARGV.length != 3
  warn "Wrong number of argumnets!"
  exit(-1)
end

require 'oauth2'

UID     = 'ed80c9902ad958f45d92b2af4724b63f7112e47b6511bd88d9944fb2998271ec'
SECRET  = 'f3034c9dfdf751ca8b5345b04fda75fb664003a57ea738eac282f2c4113babea'
MIN     = ARGV[2]

flags   = ['', 'OK', 'Empty work', 'Incomplete work', 'No author file', 'Invalid compilation', \
         'Norme', 'Cheat', 'Crash', 'Outstanding']
FLAG    = flags.index((ARGV[1]).to_s)

begin
  client  = OAuth2::Client.new(UID, SECRET, site: 'https://api.intra.42.fr')
  token   = client.client_credentials.get_token
  PROJECT = token.get("v2/projects?filter[name]=#{ARGV[0]}").parsed[0]['id']

  arr_teams = []
  i = 0
  loop do # идем по страницам реквестов
    page       = token.get("/v2/projects/#{PROJECT}/teams?page[number]=#{i}&page[size]=100&range[final_mark]=#{MIN},125").parsed
    break if page.empty?
    j = 0
    until page[j].nil? # идем по тимам сдавшим проект на одной странице
      scale_teams = token.get("/v2/projects/#{PROJECT}/scale_teams?filter[flag_id]=#{FLAG}&filter[team_id]=#{page[j]['id']}").parsed
      outs_flags  = token.get("/v2/projects/#{PROJECT}/scale_teams?filter[flag_id]=9&filter[team_id]=#{page[j]['id']}").parsed.size
      arr_teams << [page[j]['final_mark'], page[j]['repo_url'], page[j]['users'], outs_flags] unless scale_teams.empty?
      sleep 1
      j += 1
    end
    sleep 0.5
    i += 1
  end

  arr_teams.uniq!
  file    = File.open('ex05.out', 'w')
  File.chmod(0777,'ex05.out')

  arr_teams.sort_by! { |i| [i[0].to_i, i[1]]}.reverse!
  arr_teams.each do |team|
    team[2].sort_by! { |i| [i['login']]}
  end

  arr_teams.each do |team|
      file.puts "#{team[0]} #{team[1]}"
      team[2].each do |users|
        file.puts (users['login']).to_s
      end
      file.puts "#{team[3]}\n\n"
  end

rescue OAuth2::Error => e
  if e.response.status == 500
    retry
  else
    warn e.response.status
  end

rescue NoMethodError
  warn "ERROR!\nWrite args in right way: Project - Flag - Mark\ne.g. minishell OK 115\n"
end
