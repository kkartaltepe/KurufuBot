# modeled after https://github.com/britishtea/cinch-authentication

module Cinch
	module Extensions
		module Database
			module ClassMethods
				def requireDb
					hook :pre, :method => :dbConnected?
				end
    		end

    		def dbConnected?(m)
				if @db.nil?
					host = config[:DBHost] || 'localhost'
					port = config[:DBPort] || 27017
					database = config[:Database] || 'cinchbot'
					@db = Mongo::MongoClient.new(host, port).db(database)
				end
				return (not @db.nil?)
	        end

		    def self.included(base)
		    	base.extend ClassMethods
		    end
		end
	end
end