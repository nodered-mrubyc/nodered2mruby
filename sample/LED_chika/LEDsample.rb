#
# by nodered2mruby code generator
#
injects = [{:id=>:n_934017e3524b2bdd,
  :delay=>0.1,
  :repeat=>1.0,
  :payload=>"",
  :wires=>[:n_4ae12f0c5c520655]}]
nodes = [{:id=>:n_4ae12f0c5c520655,
  :type=>:gpio,
  :targetPort=>0,
  :targetPort_mode=>"0",
  :wires=>[]}]

# global variable
$gpioNum = {}       #number of pin
$gpioValue = 0      #value for gpio
$payLoad = 0        #value of payload in inject-node

#
# calss GPIO
#
=begin
class GPIO
  attr_accessor :pinNum

  def initialize(pinNum)
    @pinNum = pinNum
  end

  def write(value)
    puts "Writing #{value} to GPIO #{@pinNum}, Out by #{$gpioValue}"
    puts "$payLoad = #{$payLoad}, $gpioValue = #{$gpioValue}"
  end
end
=end

#
# node dependent implementation
#

#gpio-node
def process_node_gpio(node, msg)
  puts "node=#{node}"
  targetPort = node[:targetPort]
  $payLoad = msg[:payload]

# GPIO ###############################################################################
#=begin
  if $gpioNum[targetPort].nil?                    # creating instance for pin
    gpio = GPIO.new(targetPort)
    $gpioNum[targetPort] = gpio
    puts "Setting up pinMode for pin #{targetPort}"
  else
    gpio = $gpioNum[targetPort]
    puts "Reusing pinMode for pin #{targetPort}"
  end

  if $payLoad.nil?                                # payload=nil
    if $gpioValue == 0
      #digitalWrite($gpioNum[targetPort], 1)
      gpio.write 1
      $gpioValue = 1
    elsif $gpioValue == 1
      #digitalWrite($gpioNum[targetPort], 0)
      gpio.write 0
      $gpioValue = 0
    end
  else                                            # payload!=nil
    if $gpioValue == 0
      #digitalWrite($gpioNum[targetPort], 1)
      gpio.write $payLoad
      $gpioValue = $payLoad
    else
      #digitalWrite($gpioNum[targetPort], 0)
      gpio.write 0
      $gpioValue = 0
    end
  end
end
#=end
#####################################################################################

# test GPIO #########################################################################
=begin
  if $gpioNum[targetPort].nil?     #pin番号のインスタンス作成
    gpio = GPIO.new(targetPort)
    $gpioNum[targetPort] = gpio
    puts "Setting up pinMode for pin #{targetPort}"
    puts "$payLoad = #{$payLoad}, $gpioValue = #{$gpioValue}"
  else
    gpio = $gpioNum[targetPort]
    puts "Reusing pinMode for pin #{targetPort}"
    #puts "$payLoad = #{$payLoad}, $gpioValue = #{$gpioValue}"
  end

  if $payLoad.nil?                #payloadが空だった場合
    if $gpioValue == 0
      gpio.write 1
      $gpioValue = 1
    elsif $gpioValue == 1
      gpio.write 0
      $gpioValue = 0
    end
  else                             #payloadに数値が入っていた場合
    if $gpioValue == 0
      gpio.write $payLoad
      $gpioValue = $payLoad
    else
      gpio.write 0
      $gpioValue = 0
    end
  end
end
=end
#####################################################################################

def process_node_gpioread(node, msg)
  gpioread[:wires].each { |node|
  msg = {:id => node,
         :GPIOType => gpioread[:GPIOType],
         :digital => gpioread[:targetPort_digital],
         :ADC => gpioread[:targetPort_ADC]

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
