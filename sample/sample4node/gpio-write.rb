#
# by nodered2mruby code generator
#
injects = [{:id=>:n_e309a2460a16f967,
  :delay=>0.1,
  :repeat=>0.0,
  :payload=>"",
  :wires=>[:n_6020299515a6080f]}]
nodes = [{:id=>:n_6020299515a6080f,
  :type=>:gpiowrite,
  :WriteType=>"digital_write",
  :GPIOType=>"write",
  :targetPort_digital=>"1",
  :targetPort_mode=>"1",
  :targetPort_PWM=>"",
  :PWM_num=>"",
  :cycle=>"0",
  :double=>nil,
  :time=>"",
  :rate=>"",
  :wires=>[]}]

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

