
module Benelux
  # 
  # |------+----+--+----+----|
  #        |
  #       0.02  
  class Timeline < Array
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