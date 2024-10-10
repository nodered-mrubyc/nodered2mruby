#
# by nodered2mruby code generator
#
injects = [{:id=>:n_934017e3524b2bdd,
  :delay=>1.0,
  :repeat=>2.0,
  :payload=>"",
  :wires=>[:n_4ae12f0c5c520655]},
 {:id=>:n_8d654ae0b42fab98,
  :delay=>0.0,
  :repeat=>2.0,
  :payload=>"",
  :wires=>[:n_935a89a7869a387a]}]
nodes = [{:id=>:n_4ae12f0c5c520655, :type=>:gpio, :targetPort=>0, :wires=>[]},
 {:id=>:n_935a89a7869a387, :type=>:gpio, :targetPort=>0, :wires=>[]}]

# global variable
$gpioNum = {}       #number of pin
$gpioValue = 0      #value for gpio
$payLoad = 0        #value of payload in inject-node

#
# calss GPIO
#
#=begin
class GPIO
  attr_accessor :pinNum

  def initialize(pinNum)
    @pinNum = pinNum
  end

  def write(value)
    puts "Writing #{value} to GPIO #{@pinNum}, Out by #{$gpioValue}"
    puts "$payLoad = #{$payLoad}, $gpioValue = #{$gpioValue}"
    puts $gpioValue
  end
end
#=end

#
# node dependent implementation
#

#gpio-node
def process_node_gpio(node, msg)
  #puts "node=#{node}"
  targetPort = node[:targetPort]
  $payLoad = msg[:payload]

# GPIO ###############################################################################
=begin
  if $gpioNum[targetPort].nil?                    # creating instance for pin
    gpio = GPIO.new(targetPort)
    $gpioNum[targetPort] = gpio
    puts "Setting up pinMode for pin #{targetPort}"
  else
    gpio = $gpioNum[targetPort]
    puts "Reusing pinMode for pin #{targetPort}"
  end


  if $payLoad == ""                              # payload=nil
    if $gpioValue == 0
      gpio.write 1
      $gpioValue = 1
    elsif $gpioValue == 1
      gpio.write 0
      $gpioValue = 0
    end
  else                                            # payload!=nil
    if $gpioValue == 0
      gpio.write 1
      $gpioValue = $payLoad
    elsif $gpioValue == $payLoad
      gpio.write 0
      $gpioValue = 0
    end
  end
end
=end
#####################################################################################

# test GPIO #########################################################################
#=begin
  if $gpioNum[targetPort].nil?
    gpio = GPIO.new(targetPort)
    $gpioNum[targetPort] = gpio
    puts "Setting up pinMode for pin #{gpio}"
    puts "$payLoad = #{$payLoad}, $gpioValue = #{$gpioValue}"
  else
    gpio = $gpioNum[targetPort]
    puts "Setting up pinMode for pin #{gpio}"
    puts "$payLoad = #{$payLoad}, $gpioValue = #{$gpioValue}"
    puts "msg is #{msg}"
  end

  if $payLoad == ""
    if $gpioValue == 0
      $gpioValue = 1
      gpio.write(1)
    else
      $gpioValue = 0
      gpio.write(0)
    end
  else
    if $gpioValue == 0
      gpio.write 1
      $gpioValue = $payLoad
    elsif $gpioValue == $payLoad
      gpio.write 0
      $gpioValue = 0
    end
  end
end
#=end
#####################################################################################

def process_node_gpioread(node, msg)
  gpioread[:wires].each { |node|
  msg = {:id => node,

        }
  $queue << msg

}
end

def process_node_gpiowrite(node, msg)
  gpiowrite[:wires].each { |node|
  msg = {:WriteType => gpiowrite[:WriteType],
        :GPIOType => gpiowrite[:GPIOType],
        :targetPort_digital => gpiowrite[:targetPort_digital],
        :targetPort_mode => gpiowrite[:targetPort_mode],
        :targetPort_PWM => gpiowrite[:targetPort_PWM],
        :PWM_num => gpiowrite[:PWM_num],
        :cycle => gpiowrite[:cycle],
        :double => gpiowrite[:doube],
        :time => gpiowrite[:time],
        :rate => gpiowrite[:rate]
        }
  $queue << msg
}
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
    if injects[idx][:cnt] <= 0 then
      injects[idx][:cnt] = injects[idx][:repeat]
      process_inject injects[idx]
      puts "Do inject #{idx} "
    end
  }

  # process queue
  msg = $queue.first
  if msg then
    $queue.delete_at 0
    idx = nodes.index { |v| v[:id] == msg[:id] }
    puts "gpio :id is #{msg[:id]}"
    if idx then
      process_node nodes[idx], msg
      puts "nodes[idx] is #{nodes[idx]}"
      puts "Do #{nodes[idx][:id]}"
    else
      puts "node not found: #{msg[:id]}"
    end
  end

  # next
  # puts "q=#{$queue}"
  sleep LoopInterval
end
