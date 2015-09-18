require 'cinch'
require 'mongo'
require 'active_support/core_ext/time'
require 'active_support/core_ext/date'
require 'active_support/time_with_zone'
require 'active_support/core_ext/numeric/time'

require './extensions/auth'
require './extensions/database'

class StreamSchedule
  include Cinch::Plugin
  include Cinch::Extensions::Authentication
  include Cinch::Extensions::Database

  DateFormat = "%H:%M %Z on %b %d, %Y"
  WeekDays = ["Mon", "Tue", "Wed", "Thr", "Fri", "Sat", "Sun"]

  # Extension to add @db, and connect.
  requireDb


  match /isStreaming$/, method: :isCurrentlyStreaming
  def isCurrentlyStreaming(m)
    return unless isWhitelistedUserDuringStream?(m)

    rightNow = Time.current.utc
    streamTimes = @db.collection("streamtime").find({'date' => {'$gt' => rightNow - 2.hours,'$lt' => rightNow }}).to_a
    
    streamTimes.map! {|stream| stream['date']} # just extract dates.
    hoursSince = streamTimes.map {|time| ((Time.current.utc - time)/3600).round(2)} # get differences from now

    if(streamTimes.length == 0)
      m.twitch "No streams currently"
    else
      m.twitch "Stream started #{hoursSince.first} hours ago"
    end
  end

  match /nextStream$/, method: :nextStreamIn
  def nextStreamIn(m)
    return unless isWhitelistedUserDuringStream?(m)

    rightNow = Time.current.utc
    streams = @db.collection("streamtime").find({'date' => {'$gt' => rightNow}}).to_a

    streamTimes = streams.map{|stream| stream['date']}.sort
    m.twitch "Next stream in #{((streamTimes.first - Time.current )/3600).round(2)} hours."
  end

  match /nextStreamAt$/, method: :nextStreamAt
  def nextStreamAt(m)
    return unless isWhitelistedUserDuringStream?(m)

    rightNow = Time.current.utc
    streams = @db.collection("streamtime").find({'date' => {'$gt' => rightNow}}).to_a

    streamTimes = streams.map{|stream| stream['date']}.sort
    if(streamTimes.length > 0)
      Time.zone = 'US/Pacific'
      m.twitch "Next stream at #{Time.zone.at(streamTimes.first).strftime(StreamSchedule::DateFormat)}"
    else
      m.twitch "No more streams currently scheduled, check back later."
    end
  end

  match /(week|schedule)$/, method: :scheduleForWeek
  def scheduleForWeek(m)
    return unless isWhitelistedUserDuringStream?(m)

    Time.zone = 'US/Pacific'
    beginningOfWeek = Time.zone.now.beginning_of_week
    streams = @db.collection("streamtime").find({'date' => {'$gt' => beginningOfWeek.utc, '$lt' => beginningOfWeek + 1.week}}).to_a

    streamTimes = streams.map{|stream| stream['date'].in_time_zone}.sort
    if(streamTimes.length > 0)
      dayAndTimes = streamTimes.map{|time| "#{StreamSchedule::WeekDays[time.wday]} at #{time.strftime("%H:%M %Z")}"}
      m.twitch "Streams this week are #{dayAndTimes.join(" :: ")}"
    else
      m.twitch "No streams scheduled for this week"
    end
  end

  match /schedule (.*)$/, method: :ScheduleStreams
  def ScheduleStreams(m, date)
    return unless isAdminUser?(m)

    Time.zone = 'US/Pacific'
    streamTime = {'date' => Time.zone.parse(date)}
    @db.collection("streamtime").insert(streamTime)
    m.twitch "Added stream at #{Time.zone.parse(date)}"
  end
end