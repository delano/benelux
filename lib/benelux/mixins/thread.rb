

class Thread
  extend Attic
  attic :timeline
  attic :track_name
  attic :rotated_timelines
  def rotate_timeline
    prev = self.timeline
    self.timeline = Benelux::Timeline.new
    self.rotated_timelines << prev
    self.timeline
  end
end
