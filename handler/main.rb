
MessageQueue = []

#
# inject
#
def process_inject(inject)
  inject[:wires].each { |node|
    msg = { :id => node, :payload => inject[:payload] }
    # puts "msg = #{msg}"
    MessageQueue << msg
  }
end

def process_node(node,msg)
  case node[:type]
  when :debug
    process_node_debug node, msg
  when :switch
    process_node_switch node, msg
  when :function_code
    process_node_function_code node, msg
  when :gpio
    process_node_gpio node, msg
  when :gpioread
    process_node_gpioread node, msg
  when :ADC
    process_node_ADC node, msg
  when :gpiowrite
    process_node_gpiowrite node, msg
  when :pwm
    process_node_PWM node, msg
  when :i2c
    process_node_I2C node, msg
  when :button
    process_node_Button node, msg
  when :constant
    process_node_Constant node, msg
  else
    puts "#{node[:type]} is not supported"
  end
end

injects = injects.map { |inject|
  inject[:cnt] = inject[:repeat]
  inject
}

LoopInterval = 0.1

#process node
while true do
  injects.each_index { |idx|
    injects[idx][:cnt] -= LoopInterval
    if injects[idx][:cnt] <= 0 then
      injects[idx][:cnt] = injects[idx][:repeat]
      process_inject injects[idx]
    end
  }

  # process queue
  msg = MessageQueue.first
  if msg then
    MessageQueue.delete_at 0
    idx = nodes.find_index { |v| v[:id] == msg[:id] }
    if idx then
      process_node nodes[idx], msg
    else
      puts "node not found: #{msg[:id]}"
    end
  end

  # next
  # puts "q=#{MessageQueue}"
  sleep LoopInterval
end
