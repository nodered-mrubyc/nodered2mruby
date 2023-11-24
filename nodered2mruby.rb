#
#
require 'json'
require 'pp'

#
# generate info
#

$injects = []
$nodes = []

def id2sym(str)
  ("n_"+str).to_sym
end

def idarray2symarray(ary)
  return ary.map { |id| id2sym(id) }
end

def gen_inject(node)
  data = {:id => id2sym(node[:id]),
          :delay => node[:onceDelay].to_f,
          :repeat => node[:repeat].to_f,
          :payload => node[:payload],
          :wires => idarray2symarray(node[:wires][0])
         }
  $injects << data
end

def gen_debug(node)
  data = {:id => id2sym(node[:id]),
          :type => :debug,
          :wires => idarray2symarray(node[:wires])           
         }
  $nodes << data
end


def gen_led(node)
  data = {:id => id2sym(node[:id]),
          :type => :gpio,
          :targetPort => node[:targetPort],
          :targetPort_mode => node[:targetPort_mode],
          :wires => idarray2symarray(node[:wires])
         }
  $nodes << data
end

def gen_parameter(node)
  data = {:id => id2sym(node[:id]),
          :type => :parameter,
          :value_name => node[:value_name],
          :data_type => node[:data_type],
          :para => node[:para],
          :type4array => node[:type4array],
          :value4array => node[:value4array],
          :wires => idarray2symarray(node[:wires][0])
         }
  $nodes << data
end


def generate_node(node)
  case node[:type] 
  when "inject"
    gen_inject(node)
  when "debug"
    gen_debug(node)
  when "LED"
    gen_led(node)
  when "Parameter-Set"
    gen_parameter(node)
  when "info"
  # nothing
  when "comment"
  # nothing
  when "tab"
  # pass
  else
    puts "# #{node[:type]} is not supported, #{node}"
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

#
# mruby code generation
#

# header
puts "#"
puts "# by nodered2mruby code generator"
puts "#"

# data
puts "injects = #{$injects.pretty_inspect}"
puts "nodes = #{$nodes.pretty_inspect}"
puts

# dispatcher
File.open("dispatcher.rb") do |f|
  puts f.read
end


