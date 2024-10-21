#
# by nodered2mruby code generator
#

injects = [{:id=>:n_934017e3524b2bdd,
  :delay=>1.0,
  :repeat=>2.0,
  :payload=>"",
  :wires=>[:n_4ae12f0c5c520655]}]
nodes = [{:id=>:n_4ae12f0c5c520655, :type=>:gpio, :targetPort=>0, :wires=>[]}]

=begin
class GPIO
  attr_accessor :pinNum

  def initialize(pinNum)
    @pinNum = pinNum
  end

  def write(value)
    puts "Writing #{value} to GPIO #{@pinNum}"
  end
end
=end

# global variable
$gpioArray = {}       #number of pin
$pwmArray = {}

#
# node dependent implementation
#

#GPIO
def process_node_gpio(node, msg)
  targetPort = node[:targetPort]
  payLoad = msg[:payload]
  gpioValue = 0
  puts "#{targetPOrt}, #{payLoad}, #{gpioValue}"

  #if $gpioArray.nil? || !($gpioArray[targetPort].key?(targetPort))    # creating instance for pin
  if $gpioArray[targetPort].nil?
    gpio = GPIO.new(targetPort)
    $gpioArray[targetPort] = gpio
    puts "Setting up pinMode for pin #{gpio}"
  else
    gpio = $gpioArray[targetPort]
    puts "Reusing pinMode for pin #{gpio}"
  end

  if payLoad == ""                 # payload=nil
    if gpioValue == 0
      gpio.write 1
      gpioValue = 1
    elsif gpioValue == 1
      gpio.write 0
      gpioValue = 0
    end
  else                                   # payload!=nil
    if gpioValue == 0
      gpio.write 1
      gpioValue = payLoad
    elsif gpioValue == payLoad
      gpio.write 0
      gpioValue = 0
    end
  end
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
  #when :debug
   # puts msg[:payload]
  when :gpio
    process_node_gpio node, msg
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
