# Mechanize script to download all steps data from Azumio API

# Convert Azumio timestamp to Ruby datetime object.
# Azumio timestamp is Unix epoch in milliseconds.
def az_time(timestamp)
  Time.at(timestamp/1000).to_datetime
end

# initial setup. user/pass come from env vars
require 'mechanize'
agent = Mechanize.new
page = agent.get("http://www.azumio.com/login")
login_form = page.forms.first
login_form.email = ENV["AZUMIO_USERNAME"]
login_form.password = ENV["AZUMIO_PASSWORD"]
login_form.submit

checkins = []
modified = 0

# Loop through paged data and accumulate list of daily check-ins
while(true)
  puts "Getting files after #{az_time(modified).strftime('%D')}"
  file = agent.get("https://www.azumio.com/v2/checkins?type=steps&modifiedAfter=#{modified}")
  data = JSON.parse(file.body)
  if(!data["hasMore"])
    break
  else
    checkins += data["checkins"]
    modified = checkins.map{|c| c["modified"]}.max
  end
end

# Convert checkins from hashes to OpenStructs for Ruby niceness
checkins = checkins.map {|c| OpenStruct.new(c)}

# Print out a rough
checkins.each do |c|
  print az_time(c.timestamp).strftime('%D')
  ((c.steps / 500).to_i).times do
    print "."
  end
  print "\n"
end;0
