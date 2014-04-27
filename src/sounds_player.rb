require 'rubygems'
require 'rubygame'
require 'singleton'

class SoundsPlayer
  include Singleton

  def preload_sounds(sounds)
    @sounds ||= {}
    sounds.each{|sound|
      @sounds[sound] = Rubygame::Sound.load(sound)
    }
  end

  def play(key) 
    @sounds[key].play
  end

  def stop(key)
    @sounds[key].stop unless @sounds[key].nil?
  end

  def play_background(key)
    Rubygame::Music.load(key).play(:repeats => -1)    
  end
end
