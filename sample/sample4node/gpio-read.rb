#
# by nodered2mruby code generator
#
injects = [{:id=>:n_b99b5326944856a5,
  :delay=>0.1,
  :repeat=>0.0,
  :payload=>"",
  :wires=>[:n_422633c7163f4ab9]}]
nodes = [{:id=>:n_79f73ed4f474220d, :type=>:debug, :wires=>[]},
 {:id=>:n_422633c7163f4ab9,
  :type=>:gpioread,
  :readtype=>"digital_read",
  :GPIOType=>"read",
  :digital=>"1",
  :ADC=>"",
  :wires=>[:n_79f73ed4f474220d]}]

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
  when :Constant
    process_node_Constant node, msg
  when :gpioread
    process_node_gpioread node, msg
  when :gpiowrite
    process_node_gpiowrite node, msg  
  when :parameter
    process_node_parameter node, msg
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

