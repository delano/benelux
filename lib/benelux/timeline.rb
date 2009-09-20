
module Benelux
  # 
  # |------+----+--+----+----|
  #        |
  #       0.02  
  class Timeline < Array
    
    def at(*names)
      name = Benelux.name *names
      self.benelux.select do |mark| 
        mark.name.to_s == name.to_s
      end
    end

    def between(*names)
      name_s, name_e = *names.collect { |n| Benelux.name n }
      time_s, time_e = at(name_s), at(name_e)
      time_e.first.to_f - time_s.first.to_f
    end

    def duration(*names)
      name = Benelux.name *names
      name_s, name_e = "#{name}_a", "#{name}_z"
      between(name_s, name_e)
    end

    def mark(call_id, *names)
      name = Benelux.name *names
      thread_id = Thread.current.object_id.abs
      mark = Benelux::Mark.now(name, thread_id, call_id)
      Benelux.update_timeline mark
      self << mark
    end

    def mark_open(ref, *names)
      name = Benelux.name *names
      mark ref, name, :'a'
    end

    def mark_close(ref, *names)
      name = Benelux.name *names
      mark ref, name, :'z'
    end



    def to_line
      marks = self.sort
      dur = marks.last.to_f - marks.first.to_f
      str, prev = [], marks.first
      marks.each do |mark|
        rel = (mark.to_f - prev.to_f)
        dur = (mark.to_f - marks.first.to_f)
        str << "%s:%7.4f" % [mark.name, dur]
        prev = mark
      end
      str
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