

class Thread
  extend Attic
  attic :timeline
  attic :track_name
  attic :rotated_timelines
  def rotate_timeline
    self.rotated_timelines << self.timeline
    tags = self.timeline.default_tags.clone
    self.timeline = Benelux::Timeline.new
    self.timeline.default_tags = tags
    self.timeline
  end
end
