require "redis"
class Analyse
  @type
  @known
  @analysis


  #redis = Redis.new

  @array = ['do you know' ,'you know', "who's", 'who is', 'who are','who was']

  attr_accessor :type,:known,:analysis
  @@types = ["stem","root word of","rootword of","tell me who is",'tell me',"tell me about",'do you know',"you know","who's","what's","what's up",
             'wazzup',"wassup","are you from","are you","where is","where are","when did","whose",'what is','who is','what are','who was','who are','how are',
             'how is','can you','can i','Do you','Have you','Had you','I want to','I really want to','how can it','calculate','define',"tell me about weather",
             "how is the weather today","forecast for today","how is the weather in","weather of","evalute"]

  @@refer_person = @array
  @@refer_mood = ["what's up",'wazzup',"wassup",'how are','how is']
  @@refer_place = ["are you from","where is","where are"]
  @@refer_defination = ["what are","what is","what's",'define',"tell me about","tell me who is"]
  @@ask_for_weather = ["tell me about weather","how is the weather today","forecast for today","how is the weather in","weather of"]
  @@history_related = ["when did","when is"]
  @@math = ["calculate","evalute"]
  @@root_word = ["stem","root word of","rootword of"]

  def initialize question
    question = question.downcase.strip
    @@types.each do |known_question|
      if question.match(/#{known_question}/i)
        @type = known_question
        @known = true
      end

      if @type.nil?
        @type = question
        @known = false
      end
    end
    @analysis = prepare_response question,@type

    if @known
      @analysis
    else

    end
  end

  def known?
    @known
  end

  def search_dbpedia question,type
    results = Dbpedia.search("#{question.gsub(type,"").strip}",{:max_hits => 15})
    labels = results.collect(&:label)
    description = results.collect(&:description)
    classes = results.collect(&:categories).map{|a| a.collect(&:label)}
    all_items = labels.collect {|l| [l,description[labels.index(l)]]}
    all_items = Hash[*all_items.flatten]
    return all_items
  end

  def current_ip_address
    %x(curl ifconfig.me)
  end

  def current_city ip_address
    city = Geocoder.search(ip_address)
    city.first.data["city"]
  end


  def prepare_response question,type
    if @@refer_person.include?(type.strip) || @@history_related.include?(type.strip) || @@refer_place.include?(type.strip) || @@refer_defination.include?(type.strip)
      search_dbpedia question,type
      #in_mem = redis.gets(question)
    elsif @@root_word.include?(type.strip)
      return {stem:"#{question} is #{question.gsub(type,"").strip}".stem}
    elsif @@ask_for_weather.include?(type.strip)
      if type == "how is the weather in" || type == "weather of"
        city = question.gsub(type,"").strip
      end
      ip_address = current_ip_address if city.nil?
      city = current_city ip_address.strip if city.nil?

      uri = URI("http://api.openweathermap.org/data/2.5/weather?q=#{URI::encode(city)}")
      res = JSON.parse(Net::HTTP.get(uri))
      weather_desc = res["weather"].first["description"]
      max_temp = res["main"]["temp_max"].to_i - 273
      min_temp = res["main"]["temp_min"].to_i - 273
      humidity = res["main"]["humidity"]
      return {weather: "The current Weather of #{city}  #{weather_desc} with maximum #{max_temp} degree Celsius and minimum #{min_temp} degree Celsius, Humidity is measured #{humidity} percent"}
    elsif @@math.include?(type.strip)
      if question.match(/power/i)
        number1 = question.strip.split("power").first[/\d+/].to_i
        number2 = question.strip.split("power").last[/\d+/].to_i
        answer = number1**number2
        return {answer:answer }
      else
        return {answer:"#{eval(question.gsub(type,"").strip)}"}
      end
    else
      return {response:"No response added for such questions"}
    end
  end

  def register_unkown_question question
    @@types.push(question)
  end
end

#elsif @@volume_control.include?(type.strip)
#volume = %x(osascript -e 'get volume settings')
#current_level = volume.split(",").first[/\d+/].to_i
#if type == "decrease volume" || type == "decrease the volume" || type == "reduce volume" || type == "lower the volume" || type == "reduce the volume" || type == "quieter"
#  if current_level < 10
#    volume = %x(osascript -e 'set volume output muted true')
#  else
#    volume = %x(osascript -e 'set volume output volume #{current_level - 10}')
#  end
#elsif type == "increase the volume" || type == "increase volume" || type == "louder" || type == "raise the volume"
#  if current_level > 90
#    volume = %x(osascript -e 'set volume output volume 100')
#  else
#    volume = %x(osascript -e 'set volume output volume #{current_level + 10}')
#  end
#elsif type == "mute"
#  volume = %x(osascript -e 'set volume output muted true')
#elsif type == "unmute"
#  volume = %x(osascript -e 'set volume output muted false')
#elsif type == ("max volume")
#  volume = %x(osascript -e 'set volume output volume 100')
#elsif type == "set volume to" || type == "set volume at" || type == "increase volume to" || type == "decrease volume to"
#  set_level = question.gsub(type,"").strip[/\d+/].to_i
#  volume = %x(osascript -e 'set volume output volume #{set_level}')
#end
#elsif @@music_control.include?(type.strip)
#if type == 'play' || type == 'play me some music' || type == 'play some music' || type == 'play me music' || type == "play me" || type == "i want to listen" || type == "play my fav track" || type == "play my track" || type == "lets play some music"
#  track_name = question.gsub(type,"").strip
#  play_music track_name
#elsif type == 'no music' || type == 'stop the music' || type == 'stop music'
#  %x(killall afplay)
#end
#elsif @@play_next.include?(type.strip)
#if !@@current_playlist.nil?
#  if type == "play next"
#    if @@current_playlist[@@current_track_id+1]
#      %x(killall afplay)
#      system "afplay '#{@@current_playlist[@@current_track_id+1]}' &"
#      @@current_track_id = @@current_track_id + 1
#    else
#      %x(killall afplay)
#      system "afplay '#{@@current_playlist.first}' &"
#      @@current_track_id = 0
#    end
#  elsif type == "play last"
#    %x(killall afplay)
#    system "afplay '#{@@current_playlist.last}' &"
#    @@current_track_id = @@current_playlist.count - 1
#  elsif type == "play previous"
#    if @@current_playlist[@@current_track_id - 1]
#      %x(killall afplay)
#      system "afplay '#{@@current_playlist[@@current_track_id - 1]}' &"
#      @@current_track_id = @@current_track_id - 1
#    else
#      %x(killall afplay)
#      system "afplay '#{@@current_playlist.first}' &"
#      @@current_track_id = 0
#    end
#  end
#else
#  ps "No songs in the play list"
#end


#def know_more labels,results,descriptions
#  ps "#{labels.join(" Or ")}"
#  ps "Which one would you like to know ? or say exit to cancel ?"
#  selection = gets.chomp
#  if selection == "exit" || selection == "bye"
#    ps "Thank you!, would you like to ask more questions"
#  else
#    labels.each do |l|
#      if l.match(/#{selection}/i)
#        ps "#{results[labels.find_index(l)+1].description}"
#        know_more labels,results,descriptions
#      else
#        p "no match found"
#      end
#    end
#  end
#end


#if results.count == 1
#  ps "#{description.join(" ")}"
#elsif results.count > 1
#  results_with_index = labels.each_with_index.select { |i, idx| i =~ /#{question.gsub(type,"").strip}/i}
#  results_with_index.map! { |i| i[1] } # [0,3]
#  ps "#{results[results_with_index.first].description}"
#  ps " I have found some more results by the same term , Would you like to know them as well"
#  yes = gets.chomp
#  if yes.strip == "yes" || yes.strip == "affirmative" || yes.strip == "sure" || yes.strip == "yeah" || yes.strip == "why not"
#    labels.delete_at(results_with_index.first)
#    know_more labels,results,description
#  end
#end

#def play_music track_name
#  unless track_name.empty?
#    tracks_found= %x(find ~/Music -type f -iname '*#{track_name}*.mp3')
#    tracks = tracks_found.split("\n")
#    if tracks.count > 1
#      ps "#{tracks.count} tracks found"
#      ps "#{tracks.map{|x| ps x.gsub("_"," ").gsub(".mp3","").split("/").last}}"
#      @@current_playlist = tracks
#      @@current_track_id = 0
#      system "afplay '#{tracks.first}' &"
#    elsif tracks.count < 1
#      ps "Could not find #{track_name} in Music"
#    else
#      system "afplay '#{tracks.first}' &"
#    end
#  else
#
#  end
#end

