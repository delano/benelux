@spec = Gem::Specification.new do |s|
  s.name = "benelux"
  s.rubyforge_project = 'benelux'
  s.version = "0.5.8"
  s.summary = "Benelux: A mad way to time Ruby codes"
  s.description = s.summary
  s.author = "Delano Mandelbaum"
  s.email = "delano@solutious.com"
  s.homepage = "http://github.com/delano/benelux"
  
  s.extra_rdoc_files = %w[README.rdoc LICENSE.txt CHANGES.txt]
  s.has_rdoc = true
  s.rdoc_options = ["--line-numbers", "--title", s.summary, "--main", "README.rdoc"]
  s.require_paths = %w[lib]
  
  # = MANIFEST =
  # git ls-files
  s.files = %w(
  CHANGES.txt
  LICENSE.txt
  README.rdoc
  Rakefile
  benelux.gemspec
  lib/benelux.rb
  lib/benelux/mark.rb
  lib/benelux/mixins.rb
  lib/benelux/packer.rb
  lib/benelux/range.rb
  lib/benelux/stats.rb
  lib/benelux/timeline.rb
  lib/benelux/track.rb
  lib/selectable.rb
  lib/selectable/global.rb
  lib/selectable/object.rb
  lib/selectable/tags.rb
  tryouts/10_stats_tryouts.rb
  tryouts/11_selectable_tryouts.rb
  tryouts/20_tracks_tryouts.rb
  tryouts/30_reporter_tryouts.rb
  tryouts/30_timeline_tryouts.rb
  tryouts/benelux_bm.rb
  tryouts/proofs/alias_performance.rb
  tryouts/proofs/array_performance.rb
  tryouts/proofs/thread_array.rb
  tryouts/proofs/timer_threading.rb
  )

  
end
