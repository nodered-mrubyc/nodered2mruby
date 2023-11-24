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
  when :gpio
    process_node_gpio node, msg
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

#ƒm[ƒh‚Ìˆ—
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

