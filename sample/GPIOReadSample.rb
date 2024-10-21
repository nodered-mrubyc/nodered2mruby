#
# by nodered2mruby code generator
#
injects = [{:id=>:n_934017e3524b2bdd,
  :delay=>1.0,
  :repeat=>2.0,
  :payload=>"",
  :wires=>[:n_4ae12f0c5c520655]}]
nodes = [{:id=>:n_4ae12f0c5c520655, :type=>:gpio, :targetPort=>0, :wires=>[]}]
#=end

# global variable
$gpioArray = {}
$pwmArray = {}

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
  gpioValue = 0
  payLoad = msg[:payload]

  if $gpioArray[targetPort].nil?
    gpio = GPIO.new(targetPort)
    $gpioArray[targetPort] = gpio
    puts "Setting up pinMode for pin #{gpio}"
  else
    gpio = $gpioArray[targetPort]
    #puts "-----------------------------------------------------------------------------------------"
    puts "Reusing pinMode for pin #{gpio}"
  end

  # 現在のピンの状態をデバッグ出力
  puts "Current pin state before payload check, gpioValue: #{gpioValue}"

  if payLoad == ""
    if gpioValue == 0
      gpio.write(1)
      gpioValue = 1
      puts "Setting gpioValue to 1"
    else
      gpio.write(0)
      gpioValue = 0
      puts "Setting gpioValue to 0"
    end
  else
    if gpioValue == 0
      gpio.write(1)
      gpioValue = payLoad
      puts "Setting gpioValue to #{payLoad}"
    elsif gpioValue == payLoad
      gpio.write(0)
      gpioValue = 0
      puts "Setting gpioValue to 0"
    end
  end
end

def process_node_gpioread(node, msg)
  puts "Processing GPIO-Read for node: #{node[:id]}"
  targetPort = node[:targetPort_digital]

  if gpioReadType == "digital_read"
    if $gpioArray.nil? || !($gpioArray.key?(targetPort))
      gpio = GPIO.new(targetPort)
      $gpioArray[targetPort] = { gpio: gpio, value: 0 }
    else
      gpio = $gpioArray[targetPort][:gpio]
    end

    gpioReadValue = digitalRead($gpioArray[targetPort][:gpio])

    if gpioReadValue.nil?
      msg[:payload] = gpioReadValue
      node[:wires].each do |nextNodeId|
        $queue << { id: nextNodeId, payload: gpioReadValue }
      end
    else
      puts "No GPIO configured for pin #{$gpioArray[targetPort][:gpio]}"
    end
  end
end

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
    $gpioArray[targetPort][:gpio] = gpio
  else
    gpio = $gpioArray[targetPort][:gpio]
  end

  gpio.start
  adcValue = gpio.read_v
  gpio.stop

  if adcValue.nil?
    msg[:payload] = adcValue
    node[:wires].each do |nextNodeId|
      $queue << { id: nextNodeId, payload: adcValue }
    end
  else
    puts "No GPIO configured for pin #{targetPort}"
  end
end

def process_node_gpiowrite(node, msg)
  puts "Processing GPIO write for node: #{node[:id]}"
  targetPort = node[:digital_write]
  gpioWriteValue = node[:targetPort_mode]
  payLoad = msg[:payload]

  if $gpioArray[targetPort].nil? || !($gpioArray[targetPort].key?(targetPort))
    gpio = GPIO.new(targetPort)
    $gpioArray[targetPort] = { gpio: gpio, value: 0 }
    puts "Setting up GPIO for pin #{$gpioArray[targetPort][:gpio]} as output"
  else
    gpioWritePin = $gpioArray[targetPort][:gpio]
    puts "Reusing existing GPIO for pin #{targetPort}"
  end

  # GPIOピンに値を書き込み
  if payLoad == ""
    if gpioWriteValue == 1
      gpioWritePin.write(1)
      puts "Writing HIGH to GPIO pin #{targetPort}"
    elsif gpioWriteValue == 0
      gpio.write(0)
      puts "Writing LOW to GPIO pin #{targetPort}"
    else
      puts "Invalid value for GPIO write: #{gpioWriteValue}. Expected 0 or 1."
    end
  else
    if gpioWriteValue != payLoad
      gpioWriteValue = payLoad
    end
  end

  # ハッシュに最新の書き込み状態を記録
  $gpioArray[targetPort][:value] = gpioWriteValue

end

def process_node_PWM(node, msg)
  pwmPin = node[:targetPort_PWM]
  cycle = node[:cycle]
  rate = node[:rate]

  targetPort =  case pwmNum
                when "1" then 12
                when "2" then 16
                when "3" then nil
                when "4" then 18
                when "5" then 2
                else
                 nil
                end

  pwmChannel = case pwmNum
               when "1" then 1
               when "2" then 2
               when "3" then nil
               when "4" then 4
               when "5" then 5
               else
                nil
              end

  if $gpioArray[targetPort].nil? || !($gpioArray[targetPort].key?(targetPort))
    pwm = PWM.new(targetPort)
    $pwmArray[targetPort] = { pwm: pwm, pwmValue: 0}
    puts "Setting up GPIO for pin #{$pwmArray} as output"
  else
    pwm = $pwmArray[targetPort][:pwm]
    puts "Reusing existing GPIO for pin #{targetPort}"
  end

  pwm.rate(rate, pwmChannel)
  pwm.start(pwmChannel)

  if $pwmArray[targetPort][:pwmValue] == 0
    pwm.frequency(cycle)
    $pwmArray[targetPort][:pwmValue] = cycle
  else
    pwm.frequency(0)
    $pwmArray[targetPort][:pwmValue] = 0
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
