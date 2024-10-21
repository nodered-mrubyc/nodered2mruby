#
# calss GPIO
#


led = GPIO.new(0)
puts "led = #{led}"

while true do
  led.write 1
  sleep 0.5
  led.write 0
  sleep 0.5
end
