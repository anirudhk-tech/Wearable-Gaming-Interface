import processing.serial.*;

Serial port;
float value = 0;

void setup() {
  size(800, 600);
  println(Serial.list());
  // port = new Serial(this, Serial.list()[0], 115200);
  // port.bufferUntil('\n');
}

void draw() {
  background(255);
  fill(0);
  text("value: " + value, 20, 30);
}

void serialEvent(Serial p) {
  String line = p.readStringUntil('\n');
  if (line != null) value = float(trim(line));
}
