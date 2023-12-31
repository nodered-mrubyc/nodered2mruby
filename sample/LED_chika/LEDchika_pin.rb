#
# by nodered2mruby code generator
#
injects = [{:id=>:n_89f6013edd93e829,
  :delay=>0.0,
  :repeat=>1.0,
  :payload=>"",
  :wires=>[:n_e5180ab46280d834]}]
nodes = [{:id=>:n_b4f9df93b0ed0ace,
  :type=>:gpio,
  :onBoardLED=>"6",
  :onBoard_mode=>"0",
  :targetPort=>"0",
  :targetPort_mode=>"1",
  :wires=>[]},
 {:id=>:n_e5180ab46280d834,
  :type=>:constant,
  :C=>"1",
  :wires=>[:n_fb552db01c1edcc0]},
 {:id=>:n_fb552db01c1edcc0,
  :type=>:gpioread,
  :readtype=>"digital_read",
  :GPIOType=>"read",
  :digital=>"1",
  :ADC=>"",
  :wires=>[:n_6b28766a49ef9117]},
 {:id=>:n_6b28766a49ef9117,
  :type=>:switch,
  :payload=>nil,
  :property=>"payload",
  :propertyType=>"msg",
  :outputs=>1,
  :wires=>[:n_b4f9df93b0ed0ace]}]

#
# node dependent implementation
#
def process_node_gpio(node, msg)
  puts "node=#{node}"
end


#
# inject 
#
def process_inject(inject)
  inject[:wires].each { |node|
    msg = {:id => node, :payload => inject[:payload]}
    $queue << msg
  }
end

#
# node
#
def process_node(node,msg)
  case node[:type]
  when :debug
    puts msg[:payload]
  when :switch
    process_node_switch node, msg
  when :gpio
    process_node_gpio node, msg
  when :constant
    process_node_constant node, msg
  when :gpioread
    process_node_gpioread node, msg
  when :gpiowrite
    process_node_gpiowrite node, msg
  when :i2c
    process_node_i2c node, msg  
  when :parameter
    process_node_parameter node, msg
  when :function_code
    process_node_function_code node, msg
  else
    puts "#{node[:type]} is not supported"
  end
end


injects = injects.map { |inject|
  inject[:cnt] = inject[:repeat]
  inject
}

LoopInterval = 0.05

$queue = []

#process node
while true do
  # process inject
  injects.each_index { |idx|
    injects[idx][:cnt] -= LoopInterval
    if injects[idx][:cnt] < 0 then
      injects[idx][:cnt] = injects[idx][:repeat]
      process_inject injects[idx]
    end
  }
  
  # process queue
  msg = $queue.first
  if msg then
    $queue.delete_at 0
    idx = nodes.index { |v| v[:id]==msg[:id] }
    if idx then
      process_node nodes[idx], msg
    end
  end

  # next
  # puts "q=#{$queue}"
  sleep LoopInterval
end

