require 'benelux'


## Can specify current track" do
Benelux.current_track :track1
[Thread.current.track_name, Benelux.current_track.name]
#=> [:track1, :track1]

## Track has a timeline" do
tl = Benelux.current_track.timeline
tl.class
#=> Benelux::Timeline


## raises exception when unknown track specified" do
begin
  Benelux.track :name
rescue Benelux::UnknownTrack
  :success
end
#=> :success
