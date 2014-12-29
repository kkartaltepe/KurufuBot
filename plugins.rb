require 'cinch'
require 'yaml'
require 'active_support/core_ext/time'
require 'active_support/time_with_zone'
require 'active_support/core_ext/numeric/time'
require 'mongo'

# Hack to get messages to go to twitch without 
# any processing (WHOIS will fail on twitch servers)
class Cinch::Message
    def twitch(string)
        string = string.to_s.gsub('<','&lt;').gsub('>','&gt;')
        bot.irc.send ":#{bot.config.user}!#{bot.config.user}@#{bot.config.user}.tmi.twitch.tv PRIVMSG #{channel} :#{string}"
    end
end

class SimpleInfo
  include Cinch::Plugin
  @infolist = nil
  @whitelist = nil

  hook :pre, :for => [:listen_to], :method => :streamTime?
  hook :pre, :for => [:listen_to], :method => :whitelisted?

  listen_to :channel
  def listen(m)
  	if @infolist.nil?
  		fileName = config[:infoFile] || "info.yml"
		  @infolist = YAML.load_file(fileName)
  	end

  	@infolist.each do |info|
  		m.message.match(/(?:#{@prefix}#{info['triggers'].join('|')})(?: ([\@\w\d\_]*))?$/) do |match| # Match any of the triggers, capture a target name if provided.
  			target = match[1] || m.user.nick
  			m.twitch "#{target}: #{info['message']}"
  		end
    end
  end

  def streamTime?(m) 
    return Time.now.hour < 24 
  end

  def whitelisted?(m)
    if @whitelist.nil?
      fileName = config[:whitelistFile] || "whitelist.yml"
      @whitelist = YAML.load_file(fileName)
    end
    return @whitelist.include? m.user.nick.downcase
  end
end

class CurrentTime
  include Cinch::Plugin
  DateFormat = "%H:%M %Z on %b %d, %Y"

  match /now|pst|PST|time$/, method: :pstTime
  def pstTime(m)
    Time.zone = 'US/Pacific'
    m.twitch "The current time is #{Time.zone.now.strftime(CurrentTime::DateFormat)}" 
  end

  match /time(?: ([\w\\\/]+))/, method: :time
  def time(m, zone)
    if @extraMappings.nil?
      @extraMappings = {'PST' => 'US/Pacific',
                     'CST' => 'US/Central',
                     'MST' => 'US/Mountain'}
    end
    zone = @extraMappings[zone] unless @extraMappings[zone].nil?
    begin
      Time.zone = zone
      m.twitch "The current time is #{Time.zone.now.strftime(CurrentTime::DateFormat)}"
     rescue 
      m.twitch("Invalid Timezone")
    end
  end
end

class StreamSchedule
  include Cinch::Plugin
  DateFormat = "%H:%M %Z on %b %d, %Y"


  hook :pre, :method => :database?
  def database?(m)
    if @db.nil?
      @db = Mongo::MongoClient.new("localhost").db('cinchbot')
    end
    return (not @db.nil?)
  end

  # def isStreaming?
  #   rightNow = Time.current.utc
  #   streamTimes = @db.collection("streamtime").find({'date' => {'$gt' => rightNow - 2.hours,'$lt' => rightNow }}).to_a
  #   return streamTimes > 0
  # end

  match /isStreaming$/, method: :isCurrentlyStreaming
  def isCurrentlyStreaming(m)
    rightNow = Time.current.utc
    streamTimes = @db.collection("streamtime").find({'date' => {'$gt' => rightNow - 2.hours,'$lt' => rightNow }}).to_a
    
    streamTimes.map! {|stream| stream['date']} # just extract dates.
    hoursSince = streamTimes.map {|time| ((Time.current.utc - time)/3600).round(2)} # get differences from now

    if(streamTimes.length == 0)
      m.twitch "No streams currently"
    else
      toPrint = "Stream started #{hoursSince.first} hours ago"
      m.twitch(toPrint)
    end
  end

  match /nextStream$/, method: :nextStreamIn
  def nextStreamIn(m)
    rightNow = Time.current.utc
    streams = @db.collection("streamtime").find({'date' => {'$gt' => rightNow}}).to_a

    streamTimes = streams.map{|stream| stream['date']}.sort
    m.twitch "Next stream in #{((streamTimes.first - Time.current )/3600).round(2)} hours."
  end

  match /nextStreamAt$/, method: :nextStreamAt
  def nextStreamAt(m)
    rightNow = Time.current.utc
    streams = @db.collection("streamtime").find({'date' => {'$gt' => rightNow}}).to_a

    streamTimes = streams.map{|stream| stream['date']}.sort
    Time.zone = 'US/Pacific'
    if(streamTimes.length > 0)
      m.twitch "Next stream at #{Time.zone.at(streamTimes.first).strftime(StreamSchedule::DateFormat)}"
    else
      m.twitch "No more streams currently scheduled, check back later."
    end
  end

  match /schedule (.*)$/, method: :ScheduleStreams
  def ScheduleStreams(m, date)
    Time.zone = 'US/Pacific'
    streamTime = {'date' => Time.zone.parse(date)}
    @db.collection("streamtime").insert(streamTime)
  end
end

