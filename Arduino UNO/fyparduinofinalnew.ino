void setup() {
  Serial.begin(9600); // Hardware serial for ESP32 communication

  // Initialize pins
  pinMode(2, OUTPUT); // Bedroom RGB Green
  pinMode(3, OUTPUT); // Bedroom RGB Blue
  pinMode(4, OUTPUT); // Bedroom RGB Red
  pinMode(5, OUTPUT); // Living Room RGB Green
  pinMode(6, OUTPUT); // Living Room RGB Blue
  pinMode(7, OUTPUT); // Living Room RGB Red
  pinMode(8, OUTPUT); // Bedroom Light
  pinMode(9, OUTPUT); // Kitchen Light
  pinMode(10, OUTPUT); // Living Room Light
  pinMode(11, OUTPUT); // Bedroom Fan
  pinMode(12, OUTPUT); // Living Room Fan

  // Set initial states
  digitalWrite(2, LOW);
  digitalWrite(3, LOW);
  digitalWrite(4, LOW);
  digitalWrite(5, LOW);
  digitalWrite(6, LOW);
  digitalWrite(7, LOW);
  digitalWrite(8, LOW);
  digitalWrite(9, LOW);
  digitalWrite(10, LOW);
  digitalWrite(11, LOW);
  digitalWrite(12, LOW);

  Serial.println("Arduino Started");
}

void loop() {
  if (Serial.available()) {
    String command = Serial.readStringUntil('\n');
    command.trim();
    command.toLowerCase(); // Case-insensitive
    Serial.println("Received: " + command);

    // Parse command
    if (command.startsWith("bedroom_rgb_on_")) {
      String color = command.substring(15); // Extract color (e.g., "4294198070")
      setRGB(2, 3, 4, color); // Bedroom RGB
    } else if (command == "bedroom_rgb_off") {
      digitalWrite(2, LOW);
      digitalWrite(3, LOW);
      digitalWrite(4, LOW);
      Serial.println("Bedroom RGB OFF");
    } else if (command.startsWith("living_room_rgb_on_")) {
      String color = command.substring(19);
      setRGB(5, 6, 7, color); // Living Room RGB
    } else if (command == "living_room_rgb_off") {
      digitalWrite(5, LOW);
      digitalWrite(6, LOW);
      digitalWrite(7, LOW);
      Serial.println("Living Room RGB OFF");
    } else if (command == "bedroom_light_on") {
      digitalWrite(8, HIGH);
      Serial.println("Bedroom Light ON");
    } else if (command == "bedroom_light_off") {
      digitalWrite(8, LOW);
      Serial.println("Bedroom Light OFF");
    } else if (command == "kitchen_light_on") {
      digitalWrite(9, HIGH);
      Serial.println("Kitchen Light ON");
    } else if (command == "kitchen_light_off") {
      digitalWrite(9, LOW);
      Serial.println("Kitchen Light OFF");
    } else if (command == "living_room_light_on") {
      digitalWrite(10, HIGH);
      Serial.println("Living Room Light ON");
    } else if (command == "living_room_light_off") {
      digitalWrite(10, LOW);
      Serial.println("Living Room Light OFF");
    } else if (command.startsWith("bedroom_fan_on_")) {
      String speed = command.substring(15);
      setFanSpeed(11, speed); // Bedroom Fan
      Serial.println("Bedroom Fan ON: " + speed);
    } else if (command == "bedroom_fan_off") {
      digitalWrite(11, LOW);
      Serial.println("Bedroom Fan OFF");
    } else if (command.startsWith("living_room_fan_on_")) {
      String speed = command.substring(19);
      setFanSpeed(12, speed); // Living Room Fan
      Serial.println("Living Room Fan ON: " + speed);
    } else if (command == "living_room_fan_off") {
      digitalWrite(12, LOW);
      Serial.println("Living Room Fan OFF");
    }
  }
}

void setRGB(int greenPin, int bluePin, int redPin, String color) {
  // Set all pins to LOW initially
  digitalWrite(redPin, LOW);
  digitalWrite(greenPin, LOW);
  digitalWrite(bluePin, LOW);

  // Debug received color
  Serial.println("Received color: " + color);

  // Match predefined color strings
  if (color == "4294198070") {
    digitalWrite(redPin, HIGH);
    Serial.println("Set Red ON (pin " + String(redPin) + ")");
  } else if (color == "4283215696") {
    digitalWrite(greenPin, HIGH);
    Serial.println("Set Green ON (pin " + String(greenPin) + ")");
  } else if (color == "4280391411") {
    digitalWrite(bluePin, HIGH);
    Serial.println("Set Blue ON (pin " + String(bluePin) + ")");
  } else {
    Serial.println("Invalid or unmatched color: " + color + " (all pins OFF)");
  }
}

void setFanSpeed(int pin, String speed) {
  if (speed == "low") {
    analogWrite(pin, 160);
  } else if (speed == "medium") {
    analogWrite(pin, 200);
  } else if (speed == "high") {
    analogWrite(pin, 255);
  } else {
    analogWrite(pin, 0);
    Serial.println("Invalid fan speed: " + speed);
  }
}