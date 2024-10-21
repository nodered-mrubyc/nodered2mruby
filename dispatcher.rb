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

  if $gpioArray[targetPort].nil?                    # creating instance for pin
    gpio = GPIO.new(targetPort)
    $gpioArray[targetPort] = gpio
    puts "Setting up pinMode for pin #{targetPort}"
  else
    gpio = $gpioArray[targetPort]
    puts "Reusing pinMode for pin #{targetPort}"
  end

  if payLoad.nil?                       # payload=nil
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

#GPIO-Read
def process_node_gpioread(node, msg)
  puts "Processing GPIO read for node: #{node[:id]}"
  targetPort = node[:targetPortDigital]

    if $gpioArray.nil? || !($gpioArray[targetPort].key?(targetPort))
      gpio = GPIO.new(targetPort)
      $gpioArray[targetPort] = gpioReadPin
      puts "Setting up pinMode for pin #{targetPort}"
    else
      gpio = $gpioArray[targetPort]
      puts "Reusing pinMode for pin #{targetPort}"
    end

    gpioValue = digitalRead(targetPort)

    msg[:payload] = gpioValue
    node[:wires].each do |nextNodeId|
    $queue << { id: nextNodeId, payload: gpioValue }
    end
  else
    puts "No GPIO configured for pin #{targetPort}"
  end
end

#ADC
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

  if $gpioArray.nil? || !($gpioArray[targetPort].key?(targetPort))
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

#GPIO-Write
def process_node_gpiowrite(node, msg)
  puts "Processing GPIO read for node: #{node[:id]}"
  targetPort = node[:targetPortDigital]
  payLoad = msg[:payload]
  gpioValue = 0

  if $gpioArray.nil? || !($gpioArray[targetPort].key?(targetPort))
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

#PWM
def process_node_PWM(node, msg)
  pwmPin = node[:targetPort_PWM]
  pwmValue = 0
  cycle = node[:cycle]  #周波数
  rate = msg[:payload]  #inject.payloadで設定

  targetPort =  case pinNum
                when "1" then 12
                when "2" then 16
                when "3" then nil
                when "4" then 18
                when "5" then 2
                else
                 nil
                end

  pwmChannel = pinNum.to_i

  if $pwmArray[targetPort].nil? || !($pwmArray[targetPort].key?(targetPort))
    pwm = PWM.new(targetPort)
    $pwmArray[targetPort] = pwm
    pwm.start(pwmChannel)

    if rate == ""
      rate = 100
    end

    pwm.rate(rate, pwmChannel)
    puts "Setting up GPIO for pin #{$pwmArray} as output"
  else
    pwm = $pwmArray[targetPort][:pwm]
    puts "Reusing existing GPIO for pin #{targetPort}"
  end

  if pwmValue == 0
    pwm.frequency(cycle)
    pwmValue = cycle
  else
    pwm.frequency(0)
    pwmValue = 0
  end
end

#I2C


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
  when :gpioread
    process_node_gpioread node, msg
  when :ADC
    process_node_ADC node, msg
  when :gpiowrite
    process_node_gpiowrite node, msg
  when :pwm
    process_node_pwm node, msg
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
