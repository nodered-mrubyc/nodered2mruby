injects = [{:id=>:n_799fac6bbb648cfe,
  :delay=>0.1,
  :repeat=>1.0,
  :payload=>"",
  :wires=>[:n_c4a5e76ab307e42e, :n_b89b541f63768b32]}]
nodes = [{:id=>:n_c4a5e76ab307e42e, :type=>:debug, :wires=>[]},
 {:id=>:n_b89b541f63768b32, :type=>:debug, :wires=>[]}]

#
# Initialize Inject
#
def process_inject(inject)
  inject[:wires].each { |node|
    msg = {:id => node, :payload => inject[:payload]}
    $queue << msg
  }
end

def process_node(node,msg)
  case node[:type]
  when :debug
    puts msg[:payload]
  else
    puts "Not supported"
  end
end


injects = injects.map { |inject|
  inject[:cnt] = inject[:repeat]
  inject
}

LoopInterval = 0.05

$queue = []

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

