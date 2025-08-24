def process_node_gpio(node, msg)
  targetPort = node[:targetPort]
  payLoad = msg[:payload]

  if $gpioArray[targetPort].nil?
    gpio = GPIO.new( targetPort, GPIO::OUT )
    $gpioArray[targetPort] = gpio
    gpioValue = 0
    $pinstatus[targetPort] = 0
  else
    gpio = $gpioArray[targetPort]
    gpioValue = $pinstatus[targetPort]
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
