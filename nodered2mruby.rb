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

#inject node
def gen_inject(node)
  data = {:id => id2sym(node[:id]),
          :delay => node[:onceDelay].to_f,
          :repeat => node[:repeat].to_f,
          :payload => node[:payload],
          :wires => idarray2symarray(node[:wires][0])
         }
  $injects << data
end

#debug node
def gen_debug(node)
  data = {:id => id2sym(node[:id]),
          :type => :debug,
          :wires => idarray2symarray(node[:wires])
         }
  $nodes << data
end

#switch-node
def gen_switch(node)
  data = {:id => id2sym(node[:id]),
          :type => :switch,
          :payload => node[:payload],
          :property => node[:property],
          :propertyType => node[:propertyType],
          :outputs => node[:outputs],
          :wires => idarray2symarray(node[:wires][0])
         }
  $nodes << data
end

#LED-node
def gen_gpio(node)
  data = {:id => id2sym(node[:id]),
          :type => :gpio,
          :targetPort => node[:targetPort].to_i,
          :wires => idarray2symarray(node[:wires])
         }
  $nodes << data
end

#Constant node
def gen_constant(node)
  data = {:id => id2sym(node[:id]),
          :type => :constant,
          :C => node[:C],
          :wires => idarray2symarray(node[:wires][0])
         }
  $nodes << data
end

#GPIO-Read node
def gen_gpioread(node)
  data = {:id => id2sym(node[:id]),
          :type => :gpioread,
          :readtype => node[:readtype],
          :targetPortDigital => node[:targetPort_digital].to_i
          :wires => idarray2symarray(node[:wires][0])
         }
  $nodes << data
end

#GPIO-Write node
def gen_gpiowrite(node)
  data = {:id => id2sym(node[:id]),
          :type => :gpiowrite,
          :WriteType => node[:WriteType],
          :targetPort_digital => node[:targetPort_digital].to_i,
          :wires => idarray2symarray(node[:wires])
         }
  $nodes << data
end

#PWM node
def gen_pwm(node)
  data = {:id => id2sym(node[:id]),
          :type => :pwm,
          :targetPort_PWM => node[:targetPort_PWM].to_i,
          :cycle => node[:cycle],
          :rate => node[:rate],
          :wires => idarray2symarray(node[:wires][0])
          }
  $nodes << data
end

#I2C node
def gen_i2c(node)
  data = {:id => id2sym(node[:id]),
          :type => :i2c,
          :ad => node[:ad],
          :rules => {
                                  :t => node[:t],
                                  :v => node[:v],
                                  :c => node[:c],
                                  :b => node[:b],
                                  :de => node[:de]
                                },
          :wires => idarray2symarray(node[:wires][0])
         }
  $nodes << data
end

#Parameter node
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

#function-Code
def gen_function_code(node)
  data = {:id => id2sym(node[:id]),
          :type => :function_code,
          :func => node[:func],
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
  when "switch"
    gen_switch(node)
  when "Constant"
    gen_constant(node)
  when "GPIO-Read"
    gen_gpioread(node)
  when "GPIO-Write-1"
    gen_gpiowrite(node)
  when "PWM"
    gen_pwm(node)
  when "I2C"
    gen_i2c(node)
  when "LED"
    gen_gpio(node)
  when "Parameter-Set"
    gen_parameter(node)
  when "function-Code"
    gen_function_code(node)
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
