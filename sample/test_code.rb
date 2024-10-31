#
# by nodered2mruby code generator
#
#gpioread,debug
=begin
injects = [{:id=>:n_cc11ec3ebd2a8a9a,
  :delay=>0.1,
  :repeat=>0.0,
  :payload=>"",
  :wires=>[:n_ef93352024ba732a]}]
nodes = [{:id=>:n_ef93352024ba732a,
  :type=>:gpioread,
  :readtype=>nil,
  :targetPortDigital=>0,
  :wires=>[:n_066354c3d4ea9ea7]},
 {:id=>:n_066354c3d4ea9ea7, :type=>:debug, :wires=>[]}]
=end

#gpio,gpioread
=begin
injects = [{:id=>:n_cc11ec3ebd2a8a9a,
  :delay=>0.1,
  :repeat=>1.0,
  :payload=>"",
  :wires=>[:n_ef93352024ba732a]}]
nodes = [{:id=>:n_ef93352024ba732a,
  :type=>:gpioread,
  :readtype=>nil,
  :targetPortDigital=>0,
  :wires=>[:n_8fb0d4f3e09846f1]},
 {:id=>:n_8fb0d4f3e09846f1, :type=>:gpio, :targetPort=>0, :wires=>[]}]
=end

#gpiowrite
=begin
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
=end

#gpio
#nodes = [{:id=>:n_4ae12f0c5c520655, :type=>:gpio, :targetPort=>0, :wires=>[]}]
#=end

#PWM,gpio
=begin
injects = [{:id=>:n_934017e3524b2bdd,
  :delay=>1.0,
  :repeat=>2.0,
  :payload=>"100",
  :wires=>[:n_4ae12f0c5c520655, :n_c591d9e6ba71344e]}]
nodes = [{:id=>:n_4ae12f0c5c520655, :type=>:gpio, :targetPort=>0, :wires=>[]},
 {:id=>:n_c591d9e6ba71344e,
  :type=>:pwm,
  :PWM_num=>"1",
  :cycle=>"",
  :rate=>"",
  :wires=>[]}]
=end

#inject,inject,pwm
#=begin
injects = [{:id=>:n_934017e3524b2bdd,
  :delay=>3.0,
  :repeat=>2.0,
  :payload=>"100",
  :wires=>[:n_c591d9e6ba71344e]}]
=begin
 {:id=>:n_0b25d509b04f9cc0,
  :delay=>1.0,
  :repeat=>2.0,
  :payload=>"100",
  :wires=>[:n_c591d9e6ba71344e]}]
=end
nodes = [{:id=>:n_c591d9e6ba71344e,
  :type=>:pwm,
  :PWM_num=>"1",
  :cycle=>"440",
  :rate=>"",
  :wires=>[]}]
#=end

# global variable
$gpioArray = {}
$pwmArray = {}
$pinstatus = {}

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
    if gpioValue != payLoad
      gpio.write(1)
      $pinstatus[targetPort] = payLoad
      puts "Setting gpioValue(payload) to #{payLoad}"
    elsif gpioValue == payLoad
      gpio.write(0)
      $pinstatus[targetPort] = nil
      puts "Setting gpioValue(payload) to 0"
    end
  end
end

#GPIO-Read
def process_node_gpioread(node, msg)
  puts "Processing GPIO read for node: #{node[:id]}"
  targetPort = node[:targetPortDigital]

  if $gpioArray[targetPort].nil?
    gpio = GPIO.new(targetPort)
    $gpioArray[targetPort] = gpio
    puts "Setting up pinMode for pin #{gpio}"
  else
    gpio = $gpioArray[targetPort]
    puts "Reusing pinMode for pin #{gpio}"
  end

  if gpio.nil?
    puts "No GPIO configured for pin #{gpio}"
  else
    #gpioValue = digitalRead(gpio)
    gpioReadValue = gpio.read()
    puts "gpioReadVale = #{gpioReadValue}"

    #msg[:payload] = gpioReadValue
    node[:wires].each do |nextNodeId|
      msg = { id: nextNodeId, payload: gpioReadValue }
      $queue << msg
    end
    puts "gpioReadValue = #{gpioReadValue}"
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

  if adcValue.nil?
    puts "No GPIO configured for pin #{targetPort}"
  else
    msg[:payload] = adcValue
    node[:wires].each do |nextNodeId|
      msg = { id: nextNodeId, payload: adcValue }
      $queue << msg
    end
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
    gpioValue = nil
    $pinstatus[targetPort] = nil
    puts "Setting up pinMode for pin #{targetPort}"
  else
    gpio = $gpioArray[targetPort]
    gpioValue = $pinstatus[targetPort]
    puts "Reusing pinMode for pin #{targetPort}"
  end

  if payLoad != ""
    if gpioValue != payLoad
      gpio.write(1)
      $pinstatus[targetPort] = payLoad
    elsif gpioValue == payLoad
      gpio.write(0)
      $pinstatus[targetPort] = nil
    end
  else
    puts "The value of payload is not set."
  end
end

#PWM
def process_node_PWM(node, msg)
  pwmNum = node[:PWM_num]
  cycle = node[:cycle].to_i      #周波数
  rate = msg[:payload].to_i      #inject.payloadで設定
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
