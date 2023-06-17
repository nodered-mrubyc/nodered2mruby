#
#
require 'json'




def generate_node(node)
  case node[:type] 
  when "inject"
    puts "inject"
  when "debug"
    puts "debug"
  when "info"
  # nothing
  when "comment"
  # nothing
  when "tab"
  # pass
  else
    puts "Not supported #{node[:type]}"
  end
end













#
# main
#

json_filename = ARGV[0]

unless json_filename then
  puts "no json file"
  exit
end

json_data = ""
File.open(json_filename) do |f|
  json_data = JSON.parse(f.read, symbolize_names: true)
end

json_data.each do |node|
  generate_node node
end
