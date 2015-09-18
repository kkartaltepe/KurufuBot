# modeled after https://github.com/britishtea/cinch-authentication

module Cinch
  module Extensions
    module Authentication
      def isWhitelistedUser?(m)
	    if @config.nil?
	      fileName = config[:WhitelistFile] || "config.yml"
	      @config = YAML.load_file(fileName)
	    end
	    adminsAndWhitelist = @config['whitelist'].concat(@config['admins'])
	    return adminsAndWhitelist.include?(m.user.nick.downcase)
	  end

	  def isAdminUser?(m)
	    if @config.nil?
	      fileName = config[:WhitelistFile] || "config.yml"
	      @config = YAML.load_file(fileName)
	    end
	    return @config['admins'].include? m.user.nick.downcase
	  end

	  #def isStreaming?(m)
		  #if @db.nil?
		  #host = config[:DBHost] || "localhost"
		  #port = config[:DBPort] || 27017
		  #database = config[:Database] || 'cinchbot'
		  #@db = Mongo::MongoClient.new(host, port).db(database)
		#end
		#rightNow = Time.current.utc
		#streamTimes = @db.collection("streamtime").find({'date' => {'$gt' => rightNow - 2.hours,'$lt' => rightNow }}).to_a
		
		#return streamTimes.length != 0
	  #end

      #def isWhitelistedUserDuringStream?(m)
          #if isStreaming?(m)
              #return isWhitelistedUser?(m)
          #else
              #return true
          #end
      #end

	  #def isAdminUserDuringStream?(m)
		  #if isStreaming?(m)
			  #return isAdminUser?(m)
		  #else
			  #return true
		  #end
	  #end
  	end
  end
end
