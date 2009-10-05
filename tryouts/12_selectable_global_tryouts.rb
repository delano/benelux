# 
# group "Benelux"
# 
# library :benelux, 'lib'
# tryouts "Selectable::Global" do
#   set :bast, Benelux::Counts.new
#   setup do
#     
#   end
# 
#   dream :class, Benelux::Counts
#   dream :names, [:group1, :group2]
#   drill "Add groups" do
#     bast.add_group :group1, :group2
#     bast
#   end
#     
#   drill "Add objects to groups", true do
#     bast.send(:group1).class
#     bast.class.group_class
#   end
#   
# end