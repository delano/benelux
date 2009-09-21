@spec = Gem::Specification.new do |s|
  s.name = "benelux"
  s.rubyforge_project = 'benelux'
  s.version = "0.2.0.001"
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
  lib/benelux/timeline.rb
  tryouts/basic_tryouts.rb
  )

  
end
