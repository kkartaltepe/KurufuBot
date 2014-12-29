require 'cinch'
require 'yaml'

require './extensions/auth'

class SimpleFaq
  include Cinch::Plugin
  include Cinch::Extensions::Authentication
  @infolist = nil

  listen_to :channel
  def listen(m)
    return unless isWhitelistedUserDuringStream?(m) # Make more fine grained?

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
end