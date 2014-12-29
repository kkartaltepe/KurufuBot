require 'cinch'
require './auth'


class QuoteDB
  include Cinch::Plugin
  include Cinch::Extensions::Authentication

   hook :pre, :method => :database?
   def database?(m)
    if @db.nil?
      host = config[:host] || "localhost"
      port = config[:port] || 27017
      @db = Mongo::MongoClient.new(host, port).db('cinchbot')
    end
    return (not @db.nil?)
  end

  match /(?:addquote|aq) (.+)$/, method: :addQuote
  def addQuote(m, quote)
  	return unless isAdminUser?(m)

  	@db.collection('quotes').insert({'text' => quote, 'added' => Time.now.utc})
  	debug "Added quote '#{quote}'"
  end

  match /(randomquote|randomq|rq)$/, method: :randomQuote
  def randomQuote(m)
  	return unless isWhitelistedUserDuringStream?(m)

  	allQuotes = @db.collection('quotes').find().to_a; # Probably not viable after a couple thousand
  	if(allQuotes.size < 1)
  		m.twitch("No quotes stored :("); return
  	end
  	quote = rand(allQuotes.size)
  	m.twitch "#{allQuotes[quote]['text']}"
  end
end