#include <WiFi.h>
#include <Firebase_ESP_Client.h>
#include <ArduinoJson.h>

// Wi-Fi credentials
#define WIFI_SSID "AK"
#define WIFI_PASSWORD "AK123456"

// Firebase credentials
#define FIREBASE_HOST "newpro-5b127-default-rtdb.firebaseio.com"
#define FIREBASE_AUTH "AIzaSyAaoFfJPbV5VLfgIUNFW-zlLqrwgj1Qx8w"

// Firebase objects
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

void setup() {
  Serial.begin(115200); // Debug serial
  Serial2.begin(9600, SERIAL_8N1, 16, 17); // Serial2 for Arduino (RX=16, TX=17)

  // Connect to Wi-Fi
  Serial.print("Connecting to Wi-Fi...");
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  unsigned long startAttemptTime = millis();
  while (WiFi.status() != WL_CONNECTED && millis() - startAttemptTime < 10000) {
    delay(500);
    Serial.print(".");
  }
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\nWiFi Connected");
    Serial.print("IP Address: ");
    Serial.println(WiFi.localIP());
  } else {
    Serial.println("\nWiFi Connection Failed");
    return;
  }

  // Configure Firebase
  config.api_key = FIREBASE_AUTH;
  config.database_url = FIREBASE_HOST;
  config.timeout.serverResponse = 10 * 1000;
  config.signer.test_mode = true; // Bypass SSL
  Firebase.reconnectWiFi(true);

  // Initialize Firebase
  Firebase.begin(&config, &auth);

  // Test Firebase connection
  if (Firebase.ready()) {
    Serial.println("Firebase Connected");
    if (Firebase.RTDB.setString(&fbdo, "/test", "Hello from ESP32")) {
      Serial.println("Test write successful");
    } else {
      Serial.println("Test write failed: " + fbdo.errorReason());
    }
  } else {
    Serial.println("Firebase Connection Failed: " + fbdo.errorReason());
  }
}

void loop() {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("WiFi disconnected, reconnecting...");
    WiFi.reconnect();
    delay(5000);
    return;
  }

  if (Firebase.ready()) {
    // Bedroom devices
    processDevice("devices/bed_room/fan_1751314620800", "Fan", "bedroom_fan");
    processDevice("devices/bed_room/light_1751211413449", "Light", "bedroom_light");
    processRGB("devices/bed_room/rgb_1751211429880", "RGB Light", "bedroom_rgb");
    processDevice("devices/bed_room/lamp_1751211422707", "Lamp", "bedroom_lamp");

    // Kitchen devices
    processDevice("devices/kitchen/light_1751221982861", "Light", "kitchen_light");

    // Living room devices
    processDevice("devices/living_room/fan_1751209753278", "Fan", "living_room_fan");
    processDevice("devices/living_room/light_1751209786497", "Light", "living_room_light");
    processRGB("devices/living_room/rgb_1751209797059", "RGB Light", "living_room_rgb");
  } else {
    Serial.println("Firebase not ready: " + fbdo.errorReason());
  }

  delay(3000); // Reduce network load
}

void processDevice(String path, String deviceName, String commandPrefix) {
  if (Firebase.RTDB.getBool(&fbdo, path + "/status")) {
    if (fbdo.dataType() == "boolean") {
      bool status = fbdo.boolData();
      Serial.println(commandPrefix + " Status: " + String(status));

      if (deviceName.equalsIgnoreCase("Fan")) {
        String speedPath = path + "/speed";
        if (Firebase.RTDB.getString(&fbdo, speedPath)) {
          String speed = fbdo.stringData();
          speed.toLowerCase();
          Serial.println(commandPrefix + " Speed: " + speed);
          if (status) {
            if (speed == "low" || speed == "medium" || speed == "high") {
              String command = commandPrefix + "_on_" + speed;
              Serial.println("Sending to Arduino: " + command);
              Serial2.println(command);
            } else {
              Serial.println("Invalid speed for " + commandPrefix + ": " + speed);
            }
          } else {
            String command = commandPrefix + "_off";
            Serial.println("Sending to Arduino: " + command);
            Serial2.println(command);
          }
        } else {
          Serial.println("Failed to read " + commandPrefix + " speed: " + fbdo.errorReason());
        }
      } else {
        String command = commandPrefix + (status ? "_on" : "_off");
        Serial.println("Sending to Arduino: " + command);
        Serial2.println(command);
      }
    } else {
      Serial.println("Invalid data type for " + commandPrefix + ": " + fbdo.dataType());
    }
  } else {
    Serial.println("Failed to read " + commandPrefix + ": " + fbdo.errorReason());
  }
}

void processRGB(String path, String deviceName, String commandPrefix) {
  if (Firebase.RTDB.getBool(&fbdo, path + "/status")) {
    if (fbdo.dataType() == "boolean") {
      bool status = fbdo.boolData();
      Serial.println(commandPrefix + " Status: " + String(status));

      if (status) {
        String colorPath = path + "/color";
        if (Firebase.RTDB.getString(&fbdo, colorPath)) {
          String color = fbdo.stringData();
          color.trim();
          Serial.println(commandPrefix + " Raw Firebase color: " + color);

          // Validate color string
          if (color.length() == 0) {
            Serial.println("Empty color value for " + commandPrefix);
            return;
          }

          // Send raw color string to Arduino
          String command = commandPrefix + "_on_" + color;
          Serial.println("Sending to Arduino: " + command);
          Serial2.println(command);
        } else {
          Serial.println("Failed to read " + commandPrefix + " color: " + fbdo.errorReason());
        }
      } else {
        String command = commandPrefix + "_off";
        Serial.println("Sending to Arduino: " + command);
        Serial2.println(command);
      }
    } else {
      Serial.println("Invalid data type for " + commandPrefix + ": " + fbdo.dataType());
    }
  } else {
    Serial.println("Failed to read " + commandPrefix + ": " + fbdo.errorReason());
  }
}