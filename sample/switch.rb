#
# by nodered2mruby code generator
#
injects = [{:id=>:n_a864c0746306469e,
  :delay=>0.1,
  :repeat=>1.0,
  :payload=>"1",
  :wires=>[:n_32db3ea118f21cd4]}]
nodes = [{:id=>:n_b64c51f26c86ff89, :type=>:debug, :wires=>[]},
 {:id=>:n_32db3ea118f21cd4,
  :type=>:switch,
  :property=>"payload",
  :propertyType=>"msg",
  :rules=>[{:t=>"eq", :v=>"1", :vt=>"num"}],
  :checkall=>"true",
  :repair=>false,
  :wires=>[[:n_b64c51f26c86ff89]]}]

# global variable
$gpioArray = {}       #number of pin
$pwmArray = {}
$pinstatus = {}

#
# class myindex
#
class Myindex
  def myindex(nodes, msg)
    i = 0

    while i < nodes.length
      if nodes[i][:id] == msg[:id]
        return i
      else
        i += 1
      end
    end
    return nil
  end
end

#
# class GPIO
#
class GPIO
  attr_accessor :pinNum

  def initialize(pinNum)
    @pinNum = pinNum
  end

  def write(value)
    puts "Writing #{value} to GPIO #{@pinNum}"
  end
end


#
# node dependent implementation
#

# GPIO
def process_node_gpio(node, msg)
  targetPort = node[:targetPort]
  payLoad = msg[:payload]

  if $gpioArray[targetPort].nil?
    gpio = GPIO.new(targetPort)
    $gpioArray[targetPort] = gpio
    gpioValue = 0
    $pinstatus[targetPort] = 0
    puts "Setting up pinMode for pin #{targetPort}"
  else
    gpio = $gpioArray[targetPort]
    gpioValue = $pinstatus[targetPort]
    puts "Reusing pinMode for pin #{targetPort}"
  end

  if payLoad.nil?
    if gpioValue == 0
      gpio.write 1
      $pinstatus[targetPort] = 1
    elsif gpioValue == 1
      gpio.write 0
      $pinstatus[targetPort] = 0
    end
  else
    if gpioValue == 0
      gpio.write 1
      gpioValue = payLoad
    elsif gpioValue == payLoad
      gpio.write 0
      gpioValue = 0
    end
  end
end

# GPIO-Read
def process_node_gpioread(node, msg)
  puts "Processing GPIO read for node: #{node[:id]}"
  targetPort = node[:targetPortDigital]

  if $gpioArray[targetPort].nil?
    gpio = GPIO.new(targetPort)
    $gpioArray[targetPort] = gpio
    puts "Setting up pinMode for pin #{targetPort}"
  else
    gpio = $gpioArray[targetPort]
    puts "Reusing pinMode for pin #{targetPort}"
  end

  if gpio.nil?
    puts "No GPIO configured for pin #{gpio}"
  else
    gpioReadValue = gpio.read()
    puts "gpioReadVale = #{gpioReadValue}"

    msg[:payload] = gpioReadValue
    node[:wires].each do |nextNodeId|
    $queue << { id: nextNodeId, payload: gpioReadValue }
    end
    puts "gpioReadValue = #{gpioReadValue}"
  end
end

# ADC
def process_node_ADC(node, msg)
  pinNum = node[:targetPort_ADC]

  targetPort = case pinNum
               when "0" then 0
               when "1" then 1
               when "2" then 5
               when "3" then 6
               when "4" then 7
               when "5" then 8
               when "6" then 19
               when "7" then 20
               else
                nil
               end

  if targetPort.nil?
    puts "No GPIO configured for pin"
  end

  if $gpioArray[targetPort].nil?
    gpio = GPIO.new(targetPort)
    $gpioArray[targetPort] = gpio
    puts "Setting up pinMode for pin #{targetPort}"
  else
    gpio = $gpioArray[targetPort]
    puts "Reusing pinMode for pin #{targetPort}"
  end

  gpio.start
  adcValue = gpio.read_v
  gpio.stop

  if !adcValue.nil?
    msg[:payload] = adcValue
    node[:wires].each do |nextNodeId|
      $queue << { id: nextNodeId, payload: adcValue }
    end
  else
    puts "No GPIO configured for pin #{targetPort}"
  end
end

# GPIO-Write
def process_node_gpiowrite(node, msg)
  puts "Processing GPIO read for node: #{node[:id]}"
  targetPort = node[:targetPortDigital]
  payLoad = msg[:payload]
  gpioValue = 0

  if $gpioArray[targetPort].nil?
    gpio = GPIO.new(targetPort)
    $gpioArray[targetPort] = gpio
    puts "Setting up pinMode for pin #{targetPort}"
  else
    gpio = $gpioArray[targetPort]
    puts "Reusing pinMode for pin #{targetPort}"
  end

  if !payLoad.nil?
    if gpioValue == 0
      gpio.write 1
      gpioValue = payLoad
    elsif gpioValue == payLoad
      gpio.write 0
      gpioValue = 0
    end
  else
    puts "The value of payload is not set."
  end
end

# PWM
def process_node_PWM(node, msg)
  pwmNum = node[:PWM_num]
  cycle = node[:cycle].to_i      #蜻ｨ豕｢謨ｰ
  rate = msg[:payload].to_i      #duty豈・
  pinstatus = {}

  targetPort =  case pwmNum
                when "1" then 12
                when "2" then 16
                when "3" then nil
                when "4" then 18
                when "5" then 2
                else
                 nil
                end

  pwmChannel = pwmNum.to_i

  if $pwmArray[targetPort].nil?
    pwm = PWM.new(targetPort)
    $pwmArray[targetPort] = pwm
    puts "pwm start"
  else
    pwm = $pwmArray[targetPort]
    puts "pwm continue"
  end

  pwm.frequency(cycle)
  puts "cycle = #{cycle}"
  pwm.duty(rate)
  puts "rate = #{rate}"
end

# I2C


# Switch
def process_node_switch(node, msg)
  puts "node[:rules] = #{node[:rules]}"







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
  when :gpioread
    process_node_gpioread node, msg
  when :ADC
    process_node_ADC node, msg
  when :gpiowrite
    process_node_gpiowrite node, msg
  when :pwm
    process_node_PWM node, msg
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
    indexer = Myindex.new()
    msg = $queue.first
    if msg then
      puts "$queue = #{$queue}"
      $queue.delete_at 0
      #idx = nodes.myindex { |v| v[:id] == msg[:id] }
      idx = indexer.myindex(nodes, msg)
      puts "node is #{nodes[idx]}"
      if idx then
        puts "Do #{nodes[idx]}"
        process_node nodes[idx], msg
        puts "-----------------------------------------------------------------------------------------"
      else
        puts "node not found: #{msg[:id]}"
      end
    end

  # next
  # puts "q=#{$queue}"
  sleep LoopInterval
end
