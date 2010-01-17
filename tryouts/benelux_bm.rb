# $ ruby -Ilib tryouts/benelux_bm.rb

require 'benelux'

a = Benelux.bm(1000000, 5) do
  rand
end

p a 