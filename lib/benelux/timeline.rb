
module Benelux
  # 
  #     |------+----+--+----+----|
  #            |
  #           0.02  
  #
  # Usage examples::
  #
  #    Benelux.timeline['9dbd521de4dfd6257135649d78a9c0aa2dd58cfe'].each do |mark|
  #      p [mark.track, mark.name, mark.tags[:usecase], mark.tags[:call_id]]
  #    end
  #
  #    Benelux.timeline.ranges(:do_request).each do |range|
  #      puts "Client%s: %s: %s: %f" % [range.track, range.thread_id, range.name, range.duration]
  #    end
  #
  #    regions = Benelux.timeline(track_id).regions(:execute)
  #
  class Timeline < Array
    attr_accessor :ranges
    attr_accessor :stats
    attr_accessor :default_tags
    attr_reader :caller
    def initialize(*args)
      @caller = Kernel.caller
      @ranges, @default_tags = [], Benelux::Tags.new
      @stats = Benelux::Stats.new
      add_default_tag :thread_id => Thread.current.object_id.abs
      super
    end
    def add_default_tags(tags=Benelux::Tags.new)
      @default_tags.merge! tags
    end
    alias_method :add_default_tag, :add_default_tags
    def remove_default_tags(*tags)
      @default_tags.delete_if { |n,v| tags.member?(n) }
    end
    alias_method :add_default_tag, :add_default_tags
    def track 
      @default_tags[:track]
    end
    
    def duration
      self.last - self.first
    end
    
    def each(*args, &blk)
      if args.empty? 
        super(&blk) 
      else 
        self.marks(*args).each(&blk)
      end
    end
    
    #
    #      obj.marks(:execute_a, :execute_z, :do_request_a) => 
    #          [:execute_a, :do_request_a, :do_request_a, :execute_z]
    #
    def marks(*names)
      return self if names.empty?
      names = names.flatten.collect { |n| n.to_s }
      self.select do |mark| 
        names.member? mark.name.to_s
      end
    end
    
    def [](tags={})
      tags = Benelux::TagHelpers.normalize tags
      marks = self.select do |mark|
        mark.tags >= tags
      end
      tl = Benelux::Timeline.new marks
      tl.regions = @ranges.select do |region|
        region.tags >= tags
      end
      #stats = @stats.select do |stat|
      #  stat.tags >= tags
      #end
      tl
    end
    
    #
    #     obj.ranges(:do_request) =>
    #         [[:do_request_a, :do_request_z], [:do_request_a, ...]]
    #    
    def ranges(name=nil, tags=Benelux::Tags.new)
      return @ranges if name.nil?
      @ranges.select do |range| 
        ret = name.to_s == range.name.to_s &&
        (tags.nil? || range.tags >= tags)
        ret
      end
    end
    
    #
    #     obj.ranges(:do_request) =>
    #         [[:do_request_a, :get_body, :do_request_z], [:do_request_a, ...]]
    #
    def regions(name=nil, tags=Benelux::Tags.new)
      return self if name.nil?
      self.ranges(name, tags).collect do |base_range|
        marks = self.sort.select do |mark|
          mark >= base_range.from && 
          mark <= base_range.to &&
          mark.tags >= base_range.tags
        end
        ranges = self.ranges.select do |range|
          range.from >= base_range.from &&
          range.to <= base_range.to &&
          range.tags >= base_range.tags
        end
        tl = Benelux::Timeline.new(marks)
        tl.ranges = ranges.sort
        tl
      end
    end
    
    def clear
      @ranges.clear
      super
    end
    
    def add_mark(name)
      mark = Benelux::Mark.now(name)
      mark.add_tags Benelux.thread_timeline.default_tags
      mark.add_tags self.default_tags
      Benelux.thread_timeline << mark
      self << mark
      mark
    end
    
    def add_range(name, from, to)
      range = Benelux::Range.new(name, from, to)
      range.add_tags Benelux.thread_timeline.default_tags
      range.add_tags self.default_tags
      @stats.add_keeper(name)
      @stats.send(name).sample(range.duration, range.tags)
      @ranges << range
      Benelux.thread_timeline.ranges << range
      Benelux.thread_timeline.stats.add_keeper(name)
      Benelux.thread_timeline.stats.send(name).sample(range.duration, range.tags)
      range
    end
    
    def to_line
      marks = self.sort
    end
    
    def to_line2
      marks = self.sort
      str, prev = [], marks.first
      marks.each do |mark|
        str << "%s(%s):%.4f" % [mark.name, mark.thread_id, mark.to_s(prev)]
        prev = mark
      end
      str.join('; ')
    end
    def +(other)
      self << other
      self.ranges += other.ranges
      self.stats += other.stats
      self.flatten!
      self
    end
    # Needs to compare thread id and call id. 
    #def <=>(other)
    #end
  end
end