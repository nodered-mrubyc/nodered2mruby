#
# by nodered2mruby code generator
#
injects = [{:id=>:n_286b380cf0f5b7ca,
  :delay=>0.1,
  :repeat=>0.0,
  :payload=>"",
  :wires=>[:n_7a831a0447709976]}]
nodes = [{:id=>:n_7a831a0447709976,
  :type=>:parameter,
  :value_name=>nil,
  :data_type=>"0",
  :para=>"qwe",
  :type4array=>"",
  :value4array=>"",
  :wires=>[:n_983d48865641f4d5]},
 {:id=>:n_983d48865641f4d5, :type=>:debug, :wires=>[]}]

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

