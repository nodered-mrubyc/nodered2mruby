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
  :LEDtype=>"onBoardLED",
  :onBoardLED=>"1",
  :targetPort=>"13",
  #:targetPort_mode=>"0",
  :wires=>[]}]

#
# calss GPIO
#
=begin
class GPIO
  IN = "in"
  OUT = "out"

  def initialize(type = nil, onboardled = nil, pin = nil, direction = nil)
    @type = type
    @onboardled = onboardled
    @pin = pin
    @direction = direction
  end

  def write(value)
    if @type == "onBoardLED"
      puts "Writing #{value} to GPIO #{@onboardled}"
    elsif @type == "GPIO"
      puts "Writing #{value} to GPIO #{@pin} at #{@direction}"
    end
  end
end
=end

#
# node dependent implementation
#
def process_node_gpio(node, msg)
  puts "node=#{node}"
    if node[:LEDtype] == "onBoardLED"
#=begin

      led = GPIO.new(0)
      while true do
      led.write(1)
      sleep(0.5)
      led.write (0)
      sleep(0.5)
      end
=begin
      puts "pin_num =#{node[:onBoardLED].to_i}"
      led.write(node[:onBoardLED].to_i)
      #sleep(1)
      #led.write(0)
      #sleep(1)
      #end
=begin
      puts "#{node[:LEDtype]}"
      puts "pin_num =#{node[:onBoardLED].to_i}"
      pinMode(node[:onBoardLED].to_i, 0)
      digitalWrite(node[:onBoardLED].to_i, 1)
      puts "onBoardLED Write 1"
      sleep(node[:repeat].to_i)
      digitalWrite(node[:onBoardLED].to_i, 0)
      puts "onBoardLED Write 0"
      sleep(node[:repeat].to_i)
#=end
      #while true do
        leds_write(1)
        sleep(1)
        leds_write(0)
        sleep(1)
      #end
=end
=begin
      led = GPIO.new(node[:onBoardLED].to_i)
      puts "onBoardLED Write 1"
=end

=begin class GPIO
      led = GPIO.new("onBoardLED", nil, node[:onBoardLED], nil)
      led.write(1)
      puts "onBoardLED Write 1"


    elsif node[:LEDtype] == "GPIO"
      #pinMode(node[:targetPort], 0)
      #digitalWrite(node[:onBoardLED], 1)
      #puts "Pin-LED Write 1"
      #sleep(node[:repeat])
      #digitalWrite(node[:onBoardLED], 0)
      #puts "Pin-LED Write 0"
      #sleep(node[:repeat])
      #led = GPIO.new(node[:targetPort].to_i, setmode(GPIO::OUT))
      led = GPIO.new("GPIO", node[:targetPort], nil, GPIO::OUT)
      led.write(1)
=end
    end
end

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
