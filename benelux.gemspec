@spec = Gem::Specification.new do |s|
  s.name = "benelux"
  s.rubyforge_project = 'benelux'
  s.version = "0.3.0"
  s.summary = "Benelux: Little freakin' timers for your Ruby codes"
  s.description = s.summary
  s.author = "Delano Mandelbaum"
  s.email = "delano@solutious.com"
  s.homepage = "http://github.com/delano/benelux"
  
  s.extra_rdoc_files = %w[README.rdoc LICENSE.txt CHANGES.txt]
  s.has_rdoc = true
  s.rdoc_options = ["--line-numbers", "--title", s.summary, "--main", "README.rdoc"]
  s.require_paths = %w[lib]
  
  s.add_dependency 'hexoid'
  
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
  lib/benelux/mixins/thread.rb
  lib/benelux/range.rb
  lib/benelux/stats.rb
  lib/benelux/tags.rb
  lib/benelux/timeline.rb
  tryouts/10_stats_tryouts.rb
  tryouts/11_tags_tryouts.rb
  tryouts/20_class_methods_tryouts.rb
  tryouts/30_timeline_tryouts.rb
  tryouts/proofs/alias_performance.rb
  tryouts/proofs/timer_threading.rb
  )

  
end
