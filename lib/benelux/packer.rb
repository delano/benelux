

module Benelux
  class MethodPacker
    include Selectable::Object
    
    attr_accessor :aliaz
    attr_reader   :klass
    attr_reader   :meth
    attr_reader   :blk
    
    # * +k+ is a class
    # * +m+ is the name of an instance method in +k+
    # 
    # This method makes the following changes to class +k+. 
    #
    # * Add a timeline attic to and include +Benelux+ 
    # * Rename the method to something like:
    #   __benelux_execute_2151884308_2165479316
    # * Install a new method with the name +m+.
    #
    def initialize(k,m,&blk)
      Benelux.ld "%20s: %s#%s" % [self.class, k, m]
      @klass, @meth, @blk = k, m, blk
      @klass.extend Attic  unless @klass.kind_of?(Attic)
      unless @klass.kind_of?(Benelux)
        @klass.attic :timeline
        @klass.send :include, Benelux
      end
      ## NOTE: This is commented out so we can include  
      ## Benelux definitions before all classes are loaded. 
      ##unless obj.respond_to? meth
      ##  raise NoMethodError, "undefined method `#{meth}' for #{obj}:Class"
      ##end
      thread_id, call_id = Thread.current.object_id.abs, @klass.object_id.abs
      @aliaz = a = :"__benelux_#{@meth}_#{thread_id}_#{call_id}"
      Benelux.ld "%20s: %s" % ['Alias', @aliaz] 
      @klass.module_eval do
        alias_method a, m  # Can't use the instance variables
      end
      install_method  # see generate_packed_method
      Benelux.packed_methods << self
    end
  end
  
  class MethodTimer < MethodPacker
    # This method executes the method definition created by
    # generate_method. It calls <tt>@klass.module_eval</tt> 
    # with the modified line number (helpful for exceptions)
    def install_method
      @klass.module_eval generate_packed_method, __FILE__, 56
    end
    
    # Creates a method definition (for an eval). The 
    # method is named +@meth+ and it calls +@aliaz+.
    #
    # The new method adds a Mark to the thread timeline
    # before and after +@alias+ is called. It also adds
    # a Range to the timeline based on the two marks. 
    def generate_packed_method
      %Q{
      def #{@meth}(*args, &block)
        call_id = "" << self.object_id.abs.to_s << args.object_id.abs.to_s
        # We only need to do these things once.
        if self.timeline.nil?
          self.timeline = Benelux::Timeline.new
          Benelux.store_thread_reference
        end
        mark_a = self.timeline.add_mark :'#{@meth}_a'
        mark_a.add_tag :call_id => call_id
        tags = mark_a.tags
        ret = #{@aliaz}(*args, &block)
      rescue => ex
        raise ex
      ensure
        mark_z = self.timeline.add_mark :'#{@meth}_z'
        mark_z.tags = tags # In case tags were added between these marks
        range = self.timeline.add_range :'#{@meth}', mark_a, mark_z
        range.exception = ex if defined?(ex) && !ex.nil?
      end
      }
    end
  end
  
  class MethodCounter < MethodPacker
    def install_method
      @klass.module_eval generate_packed_method, __FILE__, 88
    end
    
    
    def Benelux.generate_packed_method(callblock=false)
      %Q{
      def #{@meth}(*args, &block)
        p :#{@meth}
      end
      }
    end
  end
end