require 'cinch'

class Bonus
  include Cinch::Plugin

  match /makemeadmin$/, method: :admin
  def admin(m)
  	m.twitch "I'm sorry #{m.user.nick}. I'm afraid I can't do that."
  end

  match /test/, method: :test
  def test(m)
    m.twitch "\x80".encode(Encoding::ISO_8859_1)
  end

  match /(beep|boop)$/, method: :beep
  def beep(m)
  	responses = [
	    "Don't speak of my mother that way!",
	    "That command was deprecated as of version 1.3.7, please use 1.3.-4 for a more updated API",
	    ":>",
	    "Pushing random buttons isn't meaningful communication, you know!",
	    "Honk!",
	    "Do it again. I dare you.",
	    "What good is an IRC bot without easter egg commands?" ]
  	m.twitch responses[rand(responses.length - 1)]
  end

  match /(holywar|besteditor)$/, method: :bestEditor
  def bestEditor(m)
  	bestEditors = ['vim', 'ed', 'emacs']
  	m.twitch bestEditors[rand(bestEditor.length)]
  end

  match /(worstlang|throwdown)$/, method: :worstLang
  def worstLang(m)
  	worstLangs = [ "Ruby", "Python", "C++", "PHP", "Rust", "Go", "Perl",
  				   "C#", "Java", "Scala", "Objective-C", "F#", "Haskell",
  				   "Clojure", "BASIC", "Visual Basic", "HTML", "CSS", 
  				   "Javascript", "Actionscript", "D"]
  	m.twitch worstLangs[rand(worstLangs.length)]
  end

  match /flame$/, method: :flame
  def flame(m)
  	if rand > 0.5
  		worstLang(m)
  	else
  		bestEditor(m)
  	end
  end

  match /(nn|night)$/, method: :night
  def night(m)
  	m.twitch "Night night <3"
  end
  match /hug$/, method: :hug
  def hug(m)
  	m.twitch "Were I not a transient being circling through an ether of intangible bits and bytes, I would hug you, with all the human emotional context it implies"
  end

  match /why$/, method: :why?
  def why?(m)
  	m.twitch "Because he can."
  end

  match /random$/, method: :random
  def random(m)
  	m.twitch "Your random number is #{unless rand < 0.0001 then 4 else rand(100) end}"
  end

  match /roll ((?:\d+d\d+ ?)+)$/, method: :roll
  def roll(m, dice)
  	dice = dice.split(' ')
  	if dice.length > 5
  		m.twitch "Too many die!"
  		return
  	end
  	results = "You rolled "
  	totalDice = 0
  	totalRoll = 0
  	dice.each do |dieString|
  		num,sides = dieString.split(/d/, 2).map{|string| string.to_i } rescue return
  		totalDice += num
  		if num > 10 or sides > 100 or totalDice > 20
  			m.twitch "Too many die!"
  			return
  		end
  		rolls = Array.new
  		num.times do
  			roll = rand(sides)+1
  		 	rolls << roll
  		 	totalRoll += roll
  		end
  		results.concat("[#{rolls.join("|")}] ")
  	end
  	results.concat("= #{totalRoll}")
  	m.twitch results
  end
end
