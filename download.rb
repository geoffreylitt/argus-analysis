require 'csv'

# Convert Azumio timestamp to Ruby datetime object.
# Azumio timestamp is Unix epoch in milliseconds.
def az_time(timestamp)
  Time.at(timestamp/1000).to_datetime
end

def download_checkins
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

  File.open "checkins.json", "w" do |file|
    file.print checkins.to_s
  end

  return load_checkins
end

def load_checkins
  checkins = JSON.parse(File.read("checkins.json"))

  # Convert checkins from hashes to OpenStructs for Ruby niceness
  checkins = checkins.map {|c| OpenStruct.new(c)}

  checkins
end

def inspect(checkins)
  checkins.each do |c|
    print az_time(c.timestamp).strftime('%D')
    ((c.steps / 500).to_i).times do
      print "."
    end
    print "\n"
  end;0
end

def aggregate_hours(checkins)
  entries = []

  checkins.each do |checkin|
    date = az_time(checkin.timestamp).to_date
    hours_hash = Hash.new(0)
    checkin.steps_profile.each do |profile|
      hour = Time.at(profile[0] / 1000).hour
      hours_hash[hour] += profile[1]
    end

    (0..23).each do |n|
      entries << OpenStruct.new(
        date: date,
        hour: n,
        steps: hours_hash[n]
      )
    end
  end

  CSV.open("entries.csv", "w") do |csv|
    entries.each do |entry|
      csv << [entry.date, entry.hour, entry.steps]
    end
  end

  entries
end

checkins = download_checkins
inspect(checkins)
entries = aggregate_hours(checkins)

