

class Thread
  extend Attic
  attic :timeline
  attic :track_name
  attic :rotated_timelines
  def rotate_timeline
    self.rotated_timelines << self.timeline
    self.timeline = Benelux::Timeline.new
    self.timeline
  end
end
