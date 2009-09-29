
module Benelux
  # 
  # |------+----+--+----+----|
  #        |
  #       0.02  
  class Timeline < Array
    attr_accessor :ranges
    attr_accessor :default_tags
    def initialize(*args)
      @ranges, @default_tags = [], Benelux::Tags.new
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
      tags = [tags].flatten unless tags.is_a?(Hash)
      ret = self.select do |mark|
        mark.tags >= tags
      end
      Benelux::Timeline.new ret
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
      self.ranges(name, tags).collect do |range|
        ret = self.sort.select do |mark|
          mark >= range.from && 
          mark <= range.to &&
          mark.tags >= range.tags
        end
        Benelux::Timeline.new(ret)
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
      @ranges << range
      Benelux.thread_timeline.ranges << range
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
      self.flatten
    end
    # Needs to compare thread id and call id. 
    #def <=>(other)
    #end
  end
end