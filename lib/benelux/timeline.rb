
module Benelux
  # 
  # |------+----+--+----+----|
  #        |
  #       0.02  
  class Timeline < Array
    
    def each(*args, &blk)
      if args.empty? 
        super(&blk) 
      else 
        self.marks(*args).each(&blk)
      end
    end
    
    ##def between(*names)
    ##  name_s, name_e = *names.collect { |n| Benelux.name n }
    ##  time_s, time_e = at(name_s), at(name_e)
    ##  time_e.first.to_f - time_s.first.to_f
    ##end
    ##def duration(*names)
    ##  name = Benelux.name *names
    ##  name_s, name_e = "#{name}_a", "#{name}_z"
    ##  between(name_s, name_e)
    ##end
    
    #
    #     obj.region(:execute) =>
    #         [[:execute_a, :execute_z], [:execute_a, :execute_z]]
    #
    def regions(*names)
      
    end
    
    #
    #      obj.marks(:execute_a, :execute_z, :do_request_a) => 
    #          [:execute_a, :do_request_a, :do_request_a, :execute_z]
    #
    def marks(*names)
      names = names.flatten.collect { |n| n.to_s }
      self.benelux.select do |mark| 
        names.member? mark.name.to_s
      end
    end
    
    def duration(name)
      name_s = Benelux.name name, SUFFIX_START 
      name_e = Benelux.name name, SUFFIX_END
    end
    
    def add_mark(call_id, name)
      thread_id = Thread.current.object_id.abs
      mark = Benelux::Mark.now(name, call_id, thread_id)
      Benelux.thread_timeline << mark
      self << mark
    end

    def add_mark_open(call_id, name)
      add_mark call_id, Benelux.name(name, SUFFIX_START)
    end

    def add_mark_close(call_id, name)
      add_mark call_id, Benelux.name(name, SUFFIX_END)
    end

    def to_line
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