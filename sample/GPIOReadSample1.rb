#
# by nodered2mruby code generator
#
injects = [{:id=>:n_8d654ae0b42fab98,
  :delay=>0.0,
  :repeat=>2.0,
  :payload=>"",
  :wires=>[:n_935a89a7869a387a]}]
#=begin
nodes = [{:id=>:n_935a89a7869a387a,
          :type=>:gpio,
          :targetPort=>0,
          :wires=>[]}]
#=end

# global variable
# global variable
$gpioArray = {}       #number of pin
$gpioValue = 0      #value for gpio
$payLoad = 0        #value of payload in inject-node


#
# calss GPIO
#

#
# node dependent implementation
#

#gpio-node
def process_node_gpio(node, msg)
  targetPort = node[:targetPort]
  payLoad = msg[:payload]

# test GPIO 2 ########################################################################
#=begin
if $gpioArray[targetPort].nil? || !($gpioArray.key?(targetPort))
  gpio = GPIO.new(targetPort)
  $gpioArray[targetPort] = { gpio: gpio, value: 0}
  puts "Setting up pinMode for pin #{$gpioArray[targetPort][:gpio]}"
else
  gpio = $gpioArray[targetPort][:gpio]
  puts "------------------------------------------------------------------------"
  puts "Reusing pinMode for pin #{$gpioArray[targetPort][:gpio]}"
  puts "$payLoad = #{$payLoad}, $gpioValue = #{$gpioArray[targetPort][:value]}"
end

if payLoad == ""
  if $gpioArray[targetPort][:value] == 0
    $gpioArray[targetPort][:value] = 1
    puts "$gpioArray[targetPort] = #{$gpioArray[targetPort]}"
    puts "$gpioArray[targetPort][:gpio] = #{$gpioArray[targetPort][:gpio]}"
    puts "$gpioArray[targetPort][:value] = #{$gpioArray[targetPort][:value]}"
    gpio.write(1)
  else
    $gpioArray[targetPort][:value] = 0
    puts "$gpioArray[targetPort] = #{$gpioArray[targetPort]}"
    puts "$gpioArray[targetPort][:gpio] = #{$gpioArray[targetPort][:gpio]}"
    puts "$gpioArray[targetPort][:value] = #{$gpioArray[targetPort][:value]}"
    gpio.write(0)
  end
else
  if $gpioArray[targetPort][:value] == 0
    gpio.write 1
    $gpioArray[targetPort][:value] = payLoad
  elsif $gpioArray[targetPort][:value] == payLoad
    gpio.write 0
    $gpioArray[targetPort][:value] = 0
  end
end

#=end
######################################################################################
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
#  when :debug
#    puts msg[:payload]
  when :gpio
    process_node_gpio node, msg
  when :gpioread
    process_node_gpioread node, msg
  when :gpiowrite
    process_node_gpiowrite node, msg
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
    if injects[idx][:cnt] == 0 then
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
