#
# by nodered2mruby code generator
#

injects = [{:id=>:n_d911d0ee4b7a3d4d,
  :delay=>0.1,
  :repeat=>2.0,
  :payload=>"1",
  :wires=>[:n_e8c32ffc8889f978]}]
nodes = [{:id=>:n_97a99168f5aa7444, :type=>:debug, :wires=>[]},
 {:id=>:n_e8c32ffc8889f978,
  :type=>:function_code,
  :func=>"data = msg \n" + "data = data + 1\n" + "return data",
  :wires=>[:n_97a99168f5aa7444]}]

# global variable
@functions = {}
$gpioArray = {}
$pwmArray = {}
$pinstatus = {}
$i2cArray = {}


# Myindex class
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

module Parsefunction
  def self.parse(func_str)
    # サポートする簡単な操作のみを許可
    if func_str.match(/^\s*data\s*=\s*data\s*(\+|\-|\*|\/)\s*\d+\s*$/)
      operator, operand = func_str.match(/(\+|\-|\*|\/)\s*(\d+)/).captures
      operand = operand.to_i

      # 安全な操作をProcで返す
      case operator
      when "+"
        ->(data) { data.to_i + operand }
      when "-"
        ->(data) { data.to_i - operand }
      when "*"
        ->(data) { data.to_i * operand }
      when "/"
        ->(data) { data.to_i / operand }
      end
    else
      raise ArgumentError, "Unsupported function string: #{func_str}"
    end
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

#
# node dependent implementation
#

# GPIO
def process_node_gpio(node, msg)
  puts "Do LED : #{node}"
  puts "msg = #{msg}"
  targetPort = node[:targetPort]
  payLoad = msg[:payload]
  sleepTime = msg[:repeat]
  puts "sleep = #{sleepTime}"

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

  puts "Current pin state before payload check, gpioValue: #{gpioValue}"

  if payLoad != ""
    if payLoad == 0
      gpio.write(0)
      puts "Setting gpioValue to 0"
    elsif payLoad == 1
      gpio.write(1)
      puts "Setting gpioValue to 1"
    end
  else
    if gpioValue == 0
      gpio.write(1)
      $pinstatus[targetPort] = 1
      puts "Setting gpioValue to 1"
    elsif gpioValue == 1
      gpio.write(0)
      $pinstatus[targetPort] = 0
      puts "Setting gpioValue to 0"
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

# GPIO-Write
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
  puts "Processing I2C for node: #{node[:id]}"

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
  puts "Button(Select Pull)"

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

#Switch
def process_node_switch(node, msg)
  puts "node[:rules] = #{node[:rules]}"

  rules = node[:rules]
  payLoad = msg[:payload]
  puts "payLoad = #{payLoad}"


  rules.each_with_index do |rule, index|
    value = rule[:v]
    value2 = rule[:v2]
    switchCase = rule[:case]

    case rule[:vt]
    when "str"
      puts "stirng"
      value = rule[:v].to_s
    when "num"
      puts "num"
      value = if rule[:v].to_s.include?(".")
        rule[:v].to_f
      else
        rule[:v].to_i
      end
    end

    puts "value = #{value}, value.class = #{value.class}"

    case rule[:t]
    when  "eq"           # ==
      if payLoad == value
        puts "nextNode = #{node[:wires][index]}, index = #{index}"
        msg = { id: node[:wires][index], payload: payLoad }
        puts "msg = #{msg}"
      end
    when "neq"           # !=
      if payLoad != value
        puts "nextNode = #{node[:wires][index]}, index = #{index}"
        msg = { id: node[:wires][index], payload: payLoad }
        puts "msg = #{msg}"
      end
    when "lt"            # <
      if payLoad > value
        puts "nextNode = #{node[:wires][index]}, index = #{index}"
        msg = { id: node[:wires][index], payload: payLoad }
        puts "msg = #{msg}"
      end
    when "lte"           # <=
      if payLoad >= value
        puts "nextNode = #{node[:wires][index]}, index = #{index}"
        msg = { id: node[:wires][index], payload: payLoad }
        puts "msg = #{msg}"
      end
    when "gt"            # >
      if payLoad < value
        puts "nextNode = #{node[:wires][index]}, index = #{index}"
        msg = { id: node[:wires][index], payload: payLoad }
        puts "msg = #{msg}"
      end
    when "gte"           # >=
      if payLoad <= value
        puts "nextNode = #{node[:wires][index]}, index = #{index}"
        msg = { id: node[:wires][index], payload: payLoad }
        puts "msg = #{msg}"
      end
    when "hask"          # キーを含む
      if payLoad.key?(value)
        puts "nextNode = #{node[:wires][index]}, index = #{index}"
        msg = { id: node[:wires][index], payload: payLoad }
        puts "msg = #{msg}"
      end
    when "btwn"          # 範囲内である
      if payLoad >= value && payLoad <= value2
        puts "nextNode = #{node[:wires][index]}, index = #{index}"
        msg = { id: node[:wires][index], payload: payLoad }
        puts "msg = #{msg}"
      end
    when "cont"          # 要素に含む
      if payLoad == true
        puts "nextNode = #{node[:wires][index]}, index = #{index}"
        msg = { id: node[:wires][index], payload: payLoad }
        puts "msg = #{msg}"
      end
    when "regex"         # 正規表現にマッチ
      if payLoad =~ value
        puts "nextNode = #{node[:wires][index]}, index = #{index}"
        msg = { id: node[:wires][index], payload: payLoad }
        puts "msg = #{msg}"
      end
    when "true"          # trueである
      if payLoad == true
        puts "nextNode = #{node[:wires][index]}, index = #{index}"
        msg = { id: node[:wires][index], payload: payLoad }
        puts "msg = #{msg}"
      end
    when "false"         # falseである
      if payLoad == false
        puts "nextNode = #{node[:wires][index]}, index = #{index}"
        msg = { id: node[:wires][index], payload: payLoad }
        puts "msg = #{msg}"
      end
    when "null"          # nullである
      if payLoad.nil?
        puts "nextNode = #{node[:wires][index]}, index = #{index}"
        msg = { id: node[:wires][index], payload: payLoad }
        puts "msg = #{msg}"
      end
    when "nnull"         # nullでない
      if !payLoad.nil?
        puts "nextNode = #{node[:wires][index]}, index = #{index}"
        msg = { id: node[:wires][index], payload: payLoad }
        puts "msg = #{msg}"
      end
    when "istype"        # 指定型
      if payLoad.class == value
        puts "nextNode = #{node[:wires][index]}, index = #{index}"
        msg = { id: node[:wires][index], payload: payLoad }
        puts "msg = #{msg}"
      end
    when "empty"         # 空である
      if payLoad.empty
        puts "nextNode = #{node[:wires][index]}, index = #{index}"
        msg = { id: node[:wires][index], payload: payLoad }
        puts "msg = #{msg}"
      end
    when "nempty"        # 空でない
      if !payLoad.empty
        puts "nextNode = #{node[:wires][index]}, index = #{index}"
        msg = { id: node[:wires][index], payload: payLoad }
        puts "msg = #{msg}"
      end
    when "head"          # 先頭要素である
        puts "nextNode = #{node[:wires][index]}, index = #{index}"
        msg = { id: node[:wires][index], payload: payLoad.first }
        puts "msg = #{msg}"
    when "index"         # indexの範囲内である
      if payLoad.size >= value.to_i && payLoad.size <= value2.to_i
        puts "nextNode = #{node[:wires][index]}, index = #{index}"
        msg = { id: node[:wires][index], payload: payLoad, :repeat => msg[:repeat] }
        puts "msg = #{msg}"
      end
    when "tail"          # 末尾要素である
      puts "nextNode = #{node[:wires][index]}, index = #{index}"
      msg = { id: node[:wires][index], payload: payLoad.last }
      puts "msg = #{msg}"
    when "jsonata_exp"   # JSONata式
      if payLoad.class == value
        puts "nextNode = #{node[:wires][index]}, index = #{index}"
        msg = { id: node[:wires][index], payload: payLoad }
        puts "msg = #{msg}"
      end
    when "else"          # その他
      msg = { id: node[:wires][index], payload: payLoad }
      puts "デフォルトmsg = #{msg}"
    else                 # 条件不一致
      puts "The specified condition does not match : #{rule[:t]}"
    end
  end

  $queue << msg

end

#function-ruby
def process_node_function_code(node, msg)
  function_name = node[:id]
  function_code = node[:func]
  result = nil
  data = msg[:payload]

  # 文字列を解析してProcに変換（evalを使わない）
  if function_code.is_a?(String)
    function_code_proc = Parsefunction.parse(function_code)
  elsif function_code.is_a?(Proc)
    function_code_proc = function_code
  else
    raise ArgumentError, "func must be a Proc or a String"
  end

  # メソッドを動的に定義
  unless respond_to?(function_name)
    self.class.define_method(function_name) do |data|
      function_code_proc.call(data)
    end
    puts "メソッド '#{function_name}' を作成しました。"
  else
    puts "メソッド '#{function_name}' は既に存在しています。"
  end

  # メソッドの呼び出し
  if respond_to?(function_name)
    result = send(function_name, data)
    puts "メソッド '#{function_name}' を実行しました。結果: #{result}"
  else
    puts "メソッド '#{function_name}' が見つかりません。"
  end

  # 次のノードへ結果を送信
  node[:wires].each do |next_node_id|
    next_msg = { id: next_node_id, payload: result }
    $queue << next_msg
  end
end


=begin
  # ノード管理クラス
  class NodeManager
    def initialize
      @nodes = {}
    end

    # ノードを登録する
    def define_node(node, msg)
      unless @nodes.key?(node_id)
        @nodes[node_id] = program
        self.class.define_method(node_id) do |data|
          instance_exec(data, &@nodes[node_id])
        end
        puts "関数 '#{node_id}' を作成しました。"
      else
        puts "関数 '#{node_id}' は既に存在しています。"
      end
    end

    # ノード関数を実行する
    def execute_node(node_id, data)
      if respond_to?(node_id)
        result = send(node_id, data)
        puts "ノード '#{node_id}' を実行しました。結果: #{result}"
        result
      else
        puts "ノード '#{node_id}' は定義されていません。"
        nil
      end
    end

    # 後続ノードへデータを送信
    def send_to_next_node(next_node_id, data)
      execute_node(next_node_id, data)
    end
  end

  # サンプルノードプログラムの定義
  node_manager = NodeManager.new

  # ノード1を定義 (例: データを2倍にする)
  node_manager.define_node(:node1, ->(data) { data * 2 })

  # ノード2を定義 (例: データに10を加える)
  node_manager.define_node(:node2, ->(data) { data + 10 })

  # ノード1を実行し、その結果をノード2に送信
  result1 = node_manager.execute_node(:node1, 5)
  node_manager.send_to_next_node(:node2, result1)

  # ノードが未定義の場合の動作確認
  node_manager.execute_node(:node3, 10)
=end

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
  else
    puts "#{node[:type]} is not supported"
  end
end

=begin
injects = injects.map { |inject|
  inject[:cnt] = inject[:repeat]
  inject[:sleep] = inject[:delay]
  inject
}.sort_by { |inject| inject[:delay] }
=end

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
    puts "$queue = #{$queue}"
    $queue.delete_at 0
    puts "$queue = #{$queue}"
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
