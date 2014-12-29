require 'cinch'
require './plugins/simplefaq'
require './plugins/currenttime'
require './plugins/streamschedule'
require './plugins/quotedb'

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.twitch.tv"
    c.channels = ["#kurufu2"]
    c.nick = "Kurufu2"
    c.password = "oauth:b3dfy82v3sqzi4kdn2mbck77pmwn0e"
    c.plugins.plugins = [SimpleFaq, CurrentTime, StreamSchedule]
  end
end

# Hack to get messages to go to twitch without 
# any processing (WHOIS will fail on twitch servers)
class Cinch::Message
    def twitch(string)
        string = string.to_s.gsub('<','&lt;').gsub('>','&gt;')
        bot.irc.send ":#{bot.config.user}!#{bot.config.user}@#{bot.config.user}.tmi.twitch.tv PRIVMSG #{channel} :#{string}"
    end
end

bot.start