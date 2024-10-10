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

=begin
nodes = [{:id=>n_935a89a7869a387a,
  :type=>:gpioread,
  :readtype=>"digital_read",
  :targetPostDigital=>"0",
  :targetPortADC=>"",
  :wires=>[:n_62c2416d5622c935]},
 {:id=>n_62c2416d5622c935, :type=>:gpio, :targetPort=>0, :wires=>[]}]
=end

# global variable
$gpioArray = {}
$pwmArray = {}


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
    puts "Writing #{value} to GPIO #{@pinNum}"
  end
end
=end

#
# node dependent implementation
#

#gpio-node
def process_node_gpio(node, msg)
  targetPort = node[:targetPort]
  gpioValue = 0
  payLoad = msg[:payload]

  if $gpioArray[targetPort].nil? || !($gpioArray.key?(targetPort))
    gpio = GPIO.new(targetPort)
    $gpioArray[targetPort] = { gpio: gpio, value: 0 }
    puts "Setting up pinMode for pin #{$gpioArray[targetPort][:gpio]}"
  else
    gpio = $gpioArray[targetPort][:gpio]
    puts "------------------------------------------------------------------------"
    puts "Reusing pinMode for pin #{$gpioArray[targetPort][:gpio]}"
  end

  # 現在のピンの状態をデバッグ出力
  puts "Current pin state before payload check, $gpioValue: #{gpioValue}, $gpioArray[$targetPort][:value]: #{$gpioArray[targetPort][:value]}"

  if payLoad == ""
    if $gpioArray[targetPort][:value] == 0
      gpio.write(1)
      $gpioArray[targetPort][:value] = 1
      puts "Setting $gpioValue to 1, $gpioArray[targetPort][:value] = #{$gpioArray[targetPort][:value]}"
    else
      gpio.write(0)
      $gpioArray[targetPort][:value] = 0
      puts "Setting $gpioValue to 0, $gpioArray[targetPort][:value] = #{$gpioArray[targetPort][:value]}"
    end
  else
    if $gpioArray[targetPort][:value] == 0
      gpio.write(1)
      $gpioArray[targetPort][:value] = payLoad
      puts "Setting $gpioValue to #{payLoad}, $gpioArray[targetPort][:value] = #{$gpioArray[targetPort][:value]}"
    elsif $gpioArray[targetPort][:value] == payLoad
      gpio.write(0)
      $gpioArray[targetPort][:value] = 0
      puts "Setting $gpioValue to 0, $gpioArray[targetPort][:value] = #{$gpioArray[targetPort][:value]}"
    end
  end
end

=begin
def process_node_gpioread(node, msg)
  puts "Processing GPIO read for node: #{node[:id]}"
  gpioReadType = node[:readtype]
  targetPortDigital = node[:targetPortDigital]
  targetPortADC = node[:targetPort_ADC]

  if gpioReadType == "digital_read"
    if $gpioArray.nil? || !($gpioArray[targetPort].key?(targetPortDigital))
      gpioReadPin = GPIO.new(targetPortDigital)
      $gpioArray[targetPort][:gpio] = gpioReadPin
    else
      gpioReadPin = $gpioArray[targetPort][:gpio]
    end

    gpioReadValue = digitalRead(targetPortDigital)

    if gpioReadValue.nil?
      msg[:payload] = gpioReadValue
      node[:wires].each do |nextNodeId|
        $queue << { id: nextNodeId, payload: gpioReadValue }
      end
    else
      puts "No GPIO configured for pin #{targetPortDigital}"
    end
  elsif gpioReadType == "ADC"
    if $gpioArray.nil? || !($gpioArray[targetPort].key?(targetPortADC))
      gpioReadPin = GPIO.new(targetPortADC)
      $gpioArray[targetPort][:gpio] = gpioReadPin
    else
      gpioReadPin = $gpioArray[targetPort][:gpio]
    end

    gpioReadPin.start
    gpioReadValue = gpioReadPin.read_v
    gpioreadPin.stop

    if gpioReadValue.nil?
      msg[:payload] = gpioReadValue
      node[:wires].each do |nextNodeId|
        $queue << { id: nextNodeId, payload: gpioReadValue }
      end
    else
      puts "No GPIO configured for pin #{targetPortDigital}"
    end
  end
end
=end

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
  payLoad = msg[:payload]  # 書き込む値はmsgのpayloadから取得（通常は0か1）

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

  # ハッシュに最新の書き込み状態を記録
  $gpioArray[targetPort][:value] = gpioWriteValue

end

def process_node_PWM(node, msg)
  pwmPin = node[:targetPort_PWM]
  cycle = node[:cycle]
  rate = node[:rate]

  targetPort =  case pinNum
                when "1" then 12
                when "2" then 16
                when "3" then nil
                when "4" then 18
                when "5" then 2
                else
                 nil
                end

  pwmChannel = case pinNum
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
#  when :debug
#    puts msg[:payload]
  when :gpio
    process_node_gpio node, msg
  when :gpioread
    process_node_gpioread node, msg
  when :
    process_node_ADC node, msg

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
      puts "-----------------------------------------------------------------------------------------"
    end
  }

  # process queue
  msg = $queue.first
  if msg then
    $queue.delete_at 0
    #idx = nodes.index { |v| v[:id] == msg[:id].to_sym }  #msg[:id]symbolに変換する処理を追加
    idx = nodes.index { |v| v[:id] == msg[:id] }
    puts "node is #{msg[:id]}"
    if idx then
      process_node nodes[idx], msg
      puts "idx.class = #{idx.class}, idx = #{idx}"
      puts "Do #{nodes[idx].class}"
    else
      puts "node not found: #{msg[:id]}"
    end
  end

  # next
  # puts "q=#{$queue}"
  sleep LoopInterval
end
