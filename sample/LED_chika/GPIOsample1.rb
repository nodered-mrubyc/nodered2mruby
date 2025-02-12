#
# by nodered2mruby code generator
#
injects = [{:id=>:n_934017e3524b2bdd, # :idの：を除けば動いた
  :delay=>1.0,
  :repeat=>1.0,
  :payload=>"",
  :wires=>[:n_4ae12f0c5c520655]}]   # :idの：を除けば動いた
nodes = [{:id=>n_4ae12f0c5c520655, # :idの：を除けば動いた
  :type=>:gpio,
  :targetPort=>1,
  :wires=>[]}]

# global variable
$gpioArray = {}       #number of pin
$gpioValue = 0        #value for gpio
$payLoad = 0          #value of payload in inject-node

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
    #puts $gpioArray[targetPort][:value]
  end

  def read(value)
    puts "Reading #{value} from GPIO #{@pinNum}"
    puts "$payLoad = #{$payLoad}, $gpioValue = #{$gpioValue}"
    puts $gpioValue
  end
end
=end

#
# node dependent implementation
#

#gpio-node
def process_node_gpio(node, msg)
  #puts "node=#{node}"
  targetPort = node[:targetPort]
  $payLoad = msg[:payload]

# GPIO ###############################################################################
#=begin
  if $gpioArray[targetPort].nil?                    # creating instance for pin
    gpio = GPIO.new(targetPort)
    $gpioArray[targetPort] = gpio
    puts "Setting up pinMode for pin #{targetPort}"
    $gpioValue = digitalRead(gpio)
  else
    gpio = $gpioArray[targetPort]
    puts "Reusing pinMode for pin #{targetPort}"
    $gpioValue = digitalRead(gpio)
  end

  if $payLoad == ""                              # payload=nil
    if $gpioValue == 0
      gpio.write 1
    elsif $gpioValue == 1
      gpio.write 0
    end
  else                                            # payload!=nil
    if $gpioValue == 0
      gpio.write 1
    elsif $gpioValue == $payLoad
      gpio.write 0
    end
  end

#=end
######################################################################################

# test GPIO 1 ########################################################################
=begin
  if $gpioArray[targetPort].nil?
    gpio = GPIO.new(targetPort)
    $gpioArray[targetPort] = gpio
    puts "Setting up pinMode for pin #{gpio}"
    puts "gpioArray = #{$gpioArray.to_s}"
    puts "gpioArray[targetPort] = #{$gpioArray[targetPort].to_s}"
    #puts "$payLoad = #{$payLoad}, $gpioValue = #{$gpioValue}"
  else
    gpio = $gpioArray[targetPort]
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

=end
######################################################################################

# GPIO 2 #############################################################################
=begin
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


  if $payLoad == ""
    if $gpioArray[targetPort][:value] == 0
      $gpioArray[targetPort][:value] = 1
      puts "$gpioArray[targetPort][:gpio] = #{$gpioArray[targetPort][:gpio]}"
      puts "$gpioArray[targetPort][:value] = #{$gpioArray[targetPort][:value]}"
      gpio.write 1
    else
      $gpioArray[targetPort][:value] = 0
      puts "$gpioArray[targetPort][:gpio] = #{$gpioArray[targetPort][:gpio]}"
      puts "$gpioArray[targetPort][:value] = #{$gpioArray[targetPort][:value]}"
      gpio.write 0
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

=end
######################################################################################

# test GPIO 2 ########################################################################
=begin
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

  if $payLoad == ""
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
      $gpioArray[targetPort][:value] = $payLoad
    elsif $gpioArray[targetPort][:value] == $payLoad
      gpio.write 0
      $gpioArray[targetPort][:value] = 0
    end
  end

=end
######################################################################################
end

def process_node_gpioread(node, msg)
  puts "node=#{node}"
  gpioReadType = node[:ReadType]
  targetPortDigital = node[:targetPort_digital]
  targetPortDigitalValue = 0
  targetPortADC = node[:targetPort_ADC]
# GPIO ###############################################################################

######################################################################################

# test GPIO ##########################################################################
#=begin
  if gpioReadType = "digital_read"
    if $gpioArray.key?(targetPortDigital)
      targetPortDigital = $gpioArray[targetPort][:gpio]
      targetPortDigitalValue = $gpioArray[targetPort][:value]
      puts "----------------------------------------------------------------------------"
      puts "$gpioArray[targetPort][:gpio] = #{$gpioArray[targetPort][:gpio]}"
      puts "$gpioArray[targetPort][:value] = #{$gpioArray[targetPort][:value]}"
    end




=begin
    elsif gpioReadType = "ADC"

    end
=end
  end


#=end
######################################################################################
=begin
  gpioread[:wires].each { |node|
  msg = {:id => node,

        }
  $queue << msg
}
=end
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
    idx = nodes.index { |v| v[:id] == msg[:id].to_sym }  #msg[:id]symbolに変換する処理を追加
    puts "gpio :id is #{msg[:id]}"
    if idx then
      process_node nodes[idx], msg
      puts "nodes[idx] is #{nodes[idx]}"
      #puts "Do #{nodes[idx][:id]}"
      puts "Do #{nodes[idx]}"
    else
      puts "node not found: #{msg[:id]}"
    end
  end

  # next
  # puts "q=#{$queue}"
  sleep LoopInterval
end
