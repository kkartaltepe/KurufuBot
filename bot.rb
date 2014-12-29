require 'cinch'
require 'yaml'
require './plugins/simplefaq'
require './plugins/currenttime'
require './plugins/streamschedule'
require './plugins/quotedb'

bot = Cinch::Bot.new do
  configure do |c|
 	config = YAML.load_file('./config.yml')
 	puts config
    c.server = config['settings']['server']
    c.channels = config['settings']['channels']
    c.nick = config['settings']['nick']
    c.password = config['settings']['password']
    c.plugins.plugins = [SimpleFaq, CurrentTime, StreamSchedule, QuoteDB]
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