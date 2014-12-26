require 'cinch'
require 'yaml'
require 'tzinfo'

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
  		m.message.match(/#{@prefix}#{info['triggers'].join('|')}(?: ([\@\w\d\_]*))?$/) do |match| # Match any of the triggers, capture a target name if provided.
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

  match /now|pst|PST$/, method: :pstTime
  def pstTime(m)
    currentTime = TZInfo::Timezone.get('US/Pacific').now
    timeFormat = "%r"
    m.twitch "The current time is #{currentTime.strftime(timeFormat)}" 
  end

  match /time(?: ([\w\\\/]+))/, method: :time
  def time(m, zone)
    if @tzMappings.nil?
      @tzMappings = {'PST' => 'US/Pacific',
                     'CST' => 'US/Central',
                     'MST' => 'US/Mountain'}
    end
    timezone = zone || 'US/Pacific'
    timezone = @tzMappings[timezone] unless @tzMappings[timezone].nil?
    currentTime = TZInfo::Timezone.get(timezone).now rescue m.twitch("Invalid timezone")
    timeFormat = "%I:%M %p"
    m.twitch "The current time is #{currentTime.strftime(timeFormat)} #{timezone}"
  end
end

class StreamSchedule
  include Cinch::Plugin

  def isCurrentlyStreaming(m)
  end

  def nextStreamIn(m)
  end

  def nextStreamAt(m)
  end

  def ScheduleStreams(m, schedule)
  end
end

