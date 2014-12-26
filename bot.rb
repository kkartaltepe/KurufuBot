require 'cinch'
require './plugins'

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.twitch.tv"
    c.channels = ["#kurufu2"]
    c.nick = "Kurufu2"
    c.password = "oauth:b3dfy82v3sqzi4kdn2mbck77pmwn0e"
    c.plugins.plugins = [SimpleInfo, CurrentTime]
  end
end

bot.start