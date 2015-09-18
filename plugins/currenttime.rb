require 'cinch'
require 'active_support/core_ext/time'
require 'active_support/core_ext/date'
require 'active_support/time_with_zone'
require 'active_support/core_ext/numeric/time'

require './extensions/auth'

class CurrentTime
  include Cinch::Plugin
  include Cinch::Extensions::Authentication

  DateFormat = "%H:%M %Z on %b %d, %Y"
  ExtraMappings = {'PST' => 'US/Pacific',
                   'CST' => 'US/Central',
                   'MST' => 'US/Mountain'}

  match /(now|pst|PST|time)$/, method: :pstTime
  def pstTime(m)
    #return unless isWhitelistedUserDuringStream?(m)

    Time.zone = 'US/Pacific'
    m.twitch "The current time is #{Time.zone.now.strftime(CurrentTime::DateFormat)}" 
  end

  match /time(?: ([\w\\\/]+))$/, method: :time
  def time(m, zone)
    #return unless isWhitelistedUserDuringStream?(m)

    zone = CurrentTime::ExtraMappings[zone] unless CurrentTime::ExtraMappings[zone].nil?
    begin
      Time.zone = zone
      m.twitch "The current time is #{Time.zone.now.strftime(CurrentTime::DateFormat)}"
     rescue 
      m.twitch("Invalid Timezone")
    end
  end
end
