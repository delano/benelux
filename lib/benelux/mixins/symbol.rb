
#if RUBY_VERSION =~ /1.8/
  class Symbol
    def <=>(other)
      self.to_s <=> other.to_s
    end
  end
#end
