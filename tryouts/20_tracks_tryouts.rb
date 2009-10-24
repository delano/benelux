group "Benelux"

library :benelux, 'lib'
tryouts "Tracks" do
  
  dream [:track1, :track1]
  drill "Can specify current track" do
    Benelux.current_track :track1
    [Thread.current.track_name, Benelux.current_track.name]
  end
  
  dream :class, Benelux::Timeline
  drill "Track has a timeline" do
    Benelux.current_track.timeline
  end
  
  dream :exception, Benelux::UnknownTrack
  drill "raises exception when unknown track specified" do
    Benelux.track :name
  end
  
end
