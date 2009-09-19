

tryouts "Alias method speed", :benchmark do
  set :runcount, 1_000
  
  setup do
    module A;
      extend self
      def meth1; end
      def meth2; end
      alias_method :meth2_orig, :meth2
      def meth2; end
      def meth2_with_call; meth2_orig; end
    end
  end
  
  [10, 100].each do |mult|
    count = runcount * mult
    
    drill "Natural method (#{count})", count do
      A.meth1
    end
    
    drill "Aliased method (#{count})", count do
      A.meth2
    end
    
    drill "Aliased method w/ call (#{count})", count do
      A.meth2_with_call
    end
  end  
  
end