# global variable
$gpioArray = {}
$adcArray = {}
$pwmArray = {}
$pinstatus = {}
$i2cArray = {}

# Myindex class
# $queue内のノードIDと合致するindex番号を調べる
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

# GPIO Class
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

# ADC Class
=begin
class ADC
  attr_accessor :pinNum

  def initialize(pinNum)
    @pinNum = pinNum
  end

  def read(value)
    puts "Reading #{value} to GPIO #{@pinNum}"
    adcValue = value
  end
end
=end


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
    puts "Setting up pinMode for pin #{gpio}"
  else
    gpio = $gpioArray[targetPort]
    gpioValue = $pinstatus[targetPort]
    puts "Reusing pinMode for pin #{gpio}, #{gpioValue}"
  end

  if payLoad != ""
    if payLoad == 0
      gpio.write(0)
    elsif payLoad == 1
      gpio.write(1)
    end
  else
    if gpioValue == 0
      gpio.write(1)
      $pinstatus[targetPort] = 1
    elsif gpioValue == 1
      gpio.write(0)
      $pinstatus[targetPort] = 0
    end
  end
end

# GPIO-Read
def process_node_gpioread(node, msg)
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
    gpioReadValue = gpio.read()
    puts "gpioReadVale = #{gpioReadValue}"

    node[:wires].each do |nextNodeId|
      msg = { id: nextNodeId, payload: gpioReadValue }
      $queue << msg
    end
  end
end

# ADC
def process_node_ADC(node, msg)
  targetPortADC = node[:targetPort_ADC]

  if $adcArray[targetPortADC].nil?
    adc = ADC.new(targetPortADC)
    $adcArray[targetPortADC] = adc
    puts "Setting up pinMode for pin #{targetPortADC}"
  else
    adc = $adcArray[targetPortADC]
    puts "Reusing pinMode for pin #{targetPortADC}"
  end

  adc.start
  adcValue_v = adc.read_v

  msg[:payload] = adcValue

  node[:wires].each do |nextNodeId|
    msg = { id: nextNodeId, payload: adcValue }
    $queue << msg
  end
end

# GPIO-Write
def process_node_gpiowrite(node, msg)
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

# PWM
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

# I2C
def process_node_I2C(node, msg)

  slaveAddress = node[:ad].to_s
  rules = node[:rules]
  payLoad = msg[:payload]

  if $i2cArray[slaveAddress].nil?
    i2c = I2C.new(slaveAddress)
    $i2cArray[slaveAddress] = i2c
    puts "Setting up pinMode for pin #{i2c}"
  else
    i2c = $i2cArray[slaveAddress]
    puts "Reusing pinMode for pin #{i2c}"
  end

  rules.each do |rule|
    if rule[:t] == "W"
      puts "type W"
      i2c.write(slaveAddress, rule[:v], payLoad)
      puts "write 1"
    elsif rule[:t] == "R"
      puts "R"
      i2c.read(slaveAddress, rule[:b], rule[:v])
      puts "Read I2C(#{i2c})"
    end
  end
end

# Button
def process_node_Button(node, msg)

  targetPort = node[:targetPort]
  selectPull = node[:selectPull]

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

  if selectPull == "0"
    gpio.pull(0)
  elsif selectPull == "1"
    gpio.pull(1)
  elsif selectPull == "2"
    gpio.pull(-1)
  end
end

# Constant
def process_node_Constant(node, msg)
  constantValue = node[:C]

  node[:wires].each do |nextNodeId|
    msg = { id: nextNodeId, payload: constantValue }
    $queue << msg
  end
end

# Switch
def process_node_switch(node, msg)

  rules = node[:rules]
  payLoad = msg[:payload].to_f

  rules.each_with_index do |rule, index|
    value = rule[:v].to_f
    value2 = rule[:v2].to_f
    switchCase = rule[:case]

    case rule[:t]
    when  "eq"           # ==
      if payLoad == value
        msg = { id: node[:wires][index], payload: payLoad }
      end
    when "neq"           # !=
      if payLoad != value
        msg = { id: node[:wires][index], payload: payLoad }
      end
    when "lt"            # <
      if payLoad > value
        msg = { id: node[:wires][index], payload: payLoad }
      end
    when "lte"           # <=
      if payLoad >= value
        msg = { id: node[:wires][index], payload: payLoad }
      end
    when "gt"            # >
      if payLoad < value
        msg = { id: node[:wires][index], payload: payLoad }
      end
    when "gte"           # >=
      if payLoad <= value
        msg = { id: node[:wires][index], payload: payLoad }
      end
    when "hask"          # キーを含む
      if payLoad.key?(value)
        msg = { id: node[:wires][index], payload: payLoad }
      end
    when "btwn"          # 範囲内である
      if payLoad >= value && payLoad <= value2
        msg = { id: node[:wires][index], payload: payLoad }
      end
    when "cont"          # 要素に含む
      if payLoad == trueである
        msg = { id: node[:wires][index], payload: payLoad }
      end
    when "regex"         # 正規表現にマッチ
      if payLoad =~ value
        msg = { id: node[:wires][index], payload: payLoad }
      end
    when "true"          # trueである
      if payLoad == true
        msg = { id: node[:wires][index], payload: payLoad }
      end
    when "false"         # falseである
      if payLoad == false
        msg = { id: node[:wires][index], payload: payLoad }
      end
    when "null"          # nullである
      if payLoad.nil?
        msg = { id: node[:wires][index], payload: payLoad }
      end
    when "nnull"         # nullでない
      if !payLoad.nil?
        msg = { id: node[:wires][index], payload: payLoad }
      end
    when "istype"        # 指定型
      if payLoad.class == value
        msg = { id: node[:wires][index], payload: payLoad }
      end
    when "empty"         # 空である
      if payLoad.empty
        msg = { id: node[:wires][index], payload: payLoad }
      end
    when "nempty"        # 空でない
      if !payLoad.empty
        msg = { id: node[:wires][index], payload: payLoad }
      end
    when "head"          # 先頭要素である
      msg = { id: node[:wires][index], payload: payLoad.first }
    when "index"         # indexの範囲内である
      if payLoad.size >= value.to_i && payLoad.size <= value2.to_i
      msg = { id: node[:wires][index], payload: payLoad, :repeat => msg[:repeat] }
      end
    when "tail"          # 末尾要素である
      msg = { id: node[:wires][index], payload: payLoad.last }
    when "jsonata_exp"   # JSONata式
      if payLoad.class == value
        msg = { id: node[:wires][index], payload: payLoad }
      end
    else                 # 条件不一致
      msg = { id: node[:wires][index], payload: payLoad }
    end
  end

  $queue << msg

end

# function-ruby
# sendメソッドでは実行できない
def process_node_function_code(node, msg)
  function_name = "func_#{node[:id]}".to_sym

  function_code = node[:func]
  data = msg[:payload].to_f

  result = send("func_n_d4daf5fbe8b2ab52", data)
  puts "result = #{result}"

  # コードを直接記述
  #result = (data * 1000 - 600)/10.0

  node[:wires].each do |next_node_id|
    next_msg = { id: next_node_id, payload: result }
    $queue << next_msg
  end
end

#
# inject
#
def process_inject(inject)
  inject[:wires].each { |node|
    msg = { :id => node, :payload => inject[:payload] }
    puts "msg = #{msg}"
    $queue << msg
  }
end

#
# node
#
def process_node(node,msg)
  case node[:type]
  when :debug
    puts "msg[:payload] = #{msg[:payload]}"
  when :switch
    process_node_switch node, msg
  when :function_code
    process_node_function_code node, msg
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
  when :i2c
    process_node_I2C node, msg
  when :button
    process_node_Button node, msg
  when :constant
    process_node_Constant node, msg
  else
    puts "#{node[:type]} is not supported"
  end
end

injects = injects.map { |inject|
  inject[:cnt] = inject[:repeat]
  inject
}

puts "injects #{injects}"

LoopInterval = 0.05
DelayInterval = 0.05

$queue = []

#process node
while true do
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
    $queue.delete_at 0
    #idx = nodes.myindex { |v| v[:id] == msg[:id] }
    idx = indexer.myindex(nodes, msg)
    if idx then
      process_node nodes[idx], msg
    else
      puts "node not found: #{msg[:id]}"
    end
  end

  # next
  # puts "q=#{$queue}"
  sleep LoopInterval
end
