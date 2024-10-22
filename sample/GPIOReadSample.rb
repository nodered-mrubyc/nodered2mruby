#
# by nodered2mruby code generator
#
injects = [{:id=>:n_934017e3524b2bdd,
  :delay=>1.0,
  :repeat=>2.0,
  :payload=>"1",
  :wires=>[:n_3e957c385a6dee4a]}]
nodes = [{:id=>:n_3e957c385a6dee4a,
  :type=>:gpiowrite,
  :WriteType=>"digital_write",
  :targetPort_digital=>0,
  :wires=>[]}]
#nodes = [{:id=>:n_4ae12f0c5c520655, :type=>:gpio, :targetPort=>0, :wires=>[]}]
#=end

# global variable
$gpioArray = {}
$pwmArray = {}
$pinstatus = {}


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


#
# class myindex
#
#=begin
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
# node dependent implementation
#

#gpio-node
def process_node_gpio(node, msg)
  puts "Do LED : #{node}"
  targetPort = node[:targetPort]
  payLoad = msg[:payload]

  if $gpioArray[targetPort].nil?
    gpio = GPIO.new(targetPort)
    $gpioArray[targetPort] = gpio
    gpioValue = 0
    $pinstatus[targetPort] = 0
    puts "Setting up pinMode for pin #{gpio}"
  else
    gpio = $gpioArray[targetPort]
    gpioValue = $pinstatus[targetPort]
    puts "Reusing pinMode for pin #{gpio}"
  end

  # 現在のピンの状態をデバッグ出力
  puts "Current pin state before payload check, gpioValue: #{gpioValue}"

  if payLoad == ""
    if gpioValue == 0
      gpio.write(1)
      $pinstatus[targetPort] = 1
      puts "Setting gpioValue to 1"
    else
      gpio.write(0)
      $pinstatus[targetPort] = 0
      puts "Setting gpioValue to 0"
    end
  else
    if gpioValue == 0
      gpio.write(1)
      $pinstatus[targetPort] = payLoad
      puts "Setting gpioValue(payload) to #{payLoad}"
    elsif gpioValue == payLoad
      gpio.write(0)
      $pinstatus[targetPort] = 0
      puts "Setting gpioValue(payload) to 0"
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

  if !gpio.nil?
    gpioValue = digitalRead(gpio)

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
  targetPort = node[:targetPort_digital]
  payLoad = msg[:payload]

  if $gpioArray[targetPort].nil?
    gpio = GPIO.new(targetPort)
    $gpioArray[targetPort] = gpio
    gpioValue = 0
    $pinstatus[targetPort] = nil
    puts "Setting up pinMode for pin #{targetPort}"
  else
    gpio = $gpioArray[targetPort]
    gpioValue = $pinstatus[targetPort]
    puts "Reusing pinMode for pin #{targetPort}"
  end

  if payLoad != ""
    if gpioValue == 0
      gpio.write(1)
      $pinstatus[targetPort] = payLoad
    elsif gpioValue == payLoad
      gpio.write(0)
      $pinstatus[targetPort] = 0
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
    if injects[idx][:cnt] <= 0 then
      injects[idx][:cnt] = injects[idx][:repeat]
      process_inject injects[idx]
      puts "Do inject #{idx}"
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
