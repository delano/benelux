require 'attic'
require 'hexoid'
require 'thread'
require 'thwait'
require 'selectable'

module Benelux
  VERSION = "0.4.0"
  NOTSUPPORTED = [Class, Object, Kernel]
  
  class BeneluxError < RuntimeError; end
  class NotSupported < BeneluxError; end
  class AlreadyTimed < BeneluxError; end
  class UnknownTrack < BeneluxError; end
  class BadRecursion < BeneluxError; end
  
  require 'benelux/mark'
  require 'benelux/count'
  require 'benelux/track'
  require 'benelux/range'
  require 'benelux/stats'
  require 'benelux/packer'
  require 'benelux/reporter'
  require 'benelux/timeline'
  require 'benelux/mixins/thread'
  require 'benelux/mixins/symbol'
  
  @packed_methods = SelectableArray.new
  @tracks = SelectableHash.new
  @timeline = Timeline.new
  @reporter = Reporter.new
  
  class << self
    attr_reader :packed_methods
    attr_reader :tracks
  end
  
  @@mutex = Mutex.new
  @@debug = false
  @@logger = STDERR
  

  def Benelux.reporting_wait
    @reporter.wait
  end
  
  # If +name+ is specified, this will associate the current
  # thread with that Track +name+ (the Track will be created
  # if necessary).
  #
  # If +track+ is nil, it returns the Track object for the
  # Track associated to the current thread. 
  #
  def Benelux.current_track(name=nil)
    if name.nil?
      name = Thread.current.track_name
    else
      Thread.current.track_name = name
      Thread.current.timeline ||= Benelux::Timeline.new
      @tracks[name] = Track.new(name) unless Benelux.track? name
      @tracks[name].add_thread
    end
    Benelux.track(name)
  end
  
  def Benelux.track(name)
    raise UnknownTrack unless track? name
    @tracks[name]
  end
  
  def Benelux.track?(name)
    @tracks.has_key? name
  end
  
  def Benelux.timeline(track=nil)
  end
  
  # Must be run in single-threaded mode (after all track threads
  # have finished).
  #
  def Benelux.update_all_track_timelines
  end
  
  # Must be run from the master thread in the current track. The master
  # thread is either the first thread in a track or the one which creates
  # additional threads for the track. 
  #
  def Benelux.update_track_timeline(track=nil)
  end
  
  # Combine two or more timelines into a new, single Benelux::Timeline.
  #
  def Benelux.merge_timelines(*timelines)

  end
  
  def Benelux.thread_timeline

  end
  
  # Benelux keeps track of the threads which have timed
  # objects so it can process the timelines after all is
  # said and done. 
  def Benelux.store_thread_reference
  end
  
  # Thread tags become the default for any new Mark or Range. 
  def Benelux.add_thread_tags(args=Selectable::Tags.new)

  end
  def Benelux.add_thread_tag(*args) add_thread_tags *args end
  
  def Benelux.remove_thread_tags(*args)
  end
  def Benelux.remove_thread_tag(*args) remove_thread_tags *args end
  

  def Benelux.inspect
    str = ["Benelux"]
    str << "tracks:" << Benelux.tracks.inspect
    str << "timers:" << Benelux.timed_methods.inspect
    str << "timeline:" << Benelux.timeline.inspect
    str.join $/
  end
  
  def Benelux.supported?(klass)
    !NOTSUPPORTED.member?(klass)
  end
  
  def Benelux.timed_methods
    Benelux.packed_methods[:kind => :'Benelux::MethodTimer']
  end

  def Benelux.counted_methods
    Benelux.packed_methods[:kind => :'Benelux::MethodCounter']
  end
  
  
  def Benelux.packed_method(klass, meth)
    # TODO: replace with static Hash
    Benelux.packed_methods[klass.to_s.to_sym, meth].first
  end
  
  def Benelux.counted_method(klass, meth)
    Benelux.counted_methods[klass.to_s.to_sym, meth].first
  end
  
  def Benelux.timed_method(klass, meth)
    Benelux.timed_methods[klass.to_s.to_sym, meth].first
  end
  
  def Benelux.timelines
  end

  
  def Benelux.timed_method? klass, meth
    Benelux.packed_method? klass, meth, :'Benelux::MethodTimer'
  end
  
  def Benelux.counted_method? klass, meth
    Benelux.packed_method? klass, meth, :'Benelux::MethodCounter'
  end
  
  def Benelux.packed_method? klass, meth, kind=nil
    list = Benelux.packed_methods[klass.to_s.to_sym, meth]
    list.filter! :kind => kind unless kind.nil?
    !list.empty?
  end
  
  
  def Benelux.add_timer klass, meth, &blk
    raise NotSupported, klass unless Benelux.supported? klass
    raise AlreadyTimed, klass if Benelux.timed_method? klass, meth
    Benelux::MethodTimer.new klass, meth, &blk
  end
  
  def Benelux.add_counter klass, meth, &blk
    raise NotSupported, klass unless Benelux.supported? klass
    Benelux::MethodCounter.new klass, meth, &blk
  end
  
  def Benelux.ld(*msg)
    @@logger.puts "D:  " << msg.join("#{$/}D:  ") if debug?
  end
  
  
  # Returns an Array of method names for the current class that
  # are timed by Benelux. 
  #
  # This is an instance method for objects which have Benelux 
  # modified methods. 
  def timed_methods
    Benelux.timed_methods[:class => self.class.to_s.to_sym]
  end
  
  # Returns an Array of method names for the current class that
  # are counted by Benelux. 
  #
  # This is an instance method for objects which have Benelux 
  # modified methods.
  def counted_methods
    Benelux.counted_methods[:class => self.class.to_s.to_sym]
  end

  
  def Benelux.enable_debug; @@debug = true; end
  def Benelux.disable_debug; @@debug = false; end
  def Benelux.debug?; @@debug; end
  
  
end




__END__
 %   cumulative   self              self     total
time   seconds   seconds    calls  ms/call  ms/call  name
33.04    40.39     40.39   832483     0.05     0.10  Selectable::Tags#==
20.65    65.64     25.25   824759     0.03     0.04  Hash#==
15.38    84.44     18.80     8173     2.30    12.16  Array#select
 6.94    92.93      8.49      101    84.06    84.06  Thread#join
 6.42   100.78      7.85   927328     0.01     0.01  String#==
 5.42   107.40      6.62   832912     0.01     0.01  Kernel.is_a?
 2.01   109.86      2.46    23840     0.10     5.13  Array#each
 0.85   110.90      1.04     9577     0.11     0.46  Selectable::Tags#>=
 0.83   111.92      1.02    13295     0.08     0.87  Kernel.send
 0.67   112.74      0.82     6348     0.13     0.18  Benelux::Stats::Calculator#update
 0.46   113.30      0.56      238     2.35    10.50  Kernel.require
 0.41   113.80      0.50    10620     0.05     0.22  Object#metaclass
 0.36   114.24      0.44    10776     0.04     0.15  Object#metaclass?
 0.35   114.67      0.43     9900     0.04     0.08  Gibbler::Digest#==
 0.35   115.10      0.43     6348     0.07     0.26  Benelux::Stats::Calculator#sample

