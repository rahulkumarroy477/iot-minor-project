#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include <ESP8266WebServer.h>

WiFiClient client;
ESP8266WebServer server(80);
const int buzz = D2;
const int ta = D3;
const int ra = D4;
String ssid = "tanish";
String password = "tanishbar";
String apiKey = "6PMV480MWV9RFXSA";  // Replace with your ThingSpeak API Key
String channelID = "2360319";        // Replace with your ThingSpeak Channel ID
String thingSpeakAddress = "http://api.thingspeak.com/channels/";
String field_no = "1";

String request;
unsigned long serverStartTime = 0;  // Record the start time of the server
bool serverStarted = false;         // Flag to track if the server is started

void setup() {
  Serial.begin(115200);
  pinMode(buzz,OUTPUT);
  pinMode(ta,OUTPUT);
  pinMode(ra,OUTPUT);
  // Connect to Wi-Fi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi...");
  }
  Serial.println("Connected to WiFi");
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP().toString());
}

void loop() {
  // Check if the server is not started and there's serial input
  if (!serverStarted) {
    startServer();
  }

  // Handle server requests if the server is started
  if (serverStarted) {
    server.handleClient();
    delay(20000);
    // Read value from ThingSpeak
    String val = thingspeakRead();
    Serial.println(val);
    // Process received values
    processReceivedValues(val);
    delay(3000);
    stopServer();
  }
}

String thingspeakRead() {
  if (client.connect("api.thingspeak.com", 80)) {
    request = thingSpeakAddress + channelID + "/fields/" + field_no + "/last?api_key=" + apiKey;
    HTTPClient http;  // Moved declaration outside of the function
    http.begin(client, request);
    http.GET();
    String value = http.getString();
    http.end();
    return value;
  }
  return "";  // Return an empty string if the connection fails
}

void startServer() {
  // Check if the server is not already started
  server.on("/", HTTP_GET, handleRoot);

  // Start server
  server.begin();
  serverStarted = true;
  Serial.println("Server started");
}

void stopServer() {
  server.stop();
  serverStarted = false;
  Serial.println("Server stopped");
  digitalWrite(LED_BUILTIN, LOW);  // Turn off the LED when stopping the server
}

void handleRoot() {
  server.send(200, "text/html", "<h1>Hello from ESP8266!</h1>");
}

void processReceivedValues(String val) {
  // Process the received values based on your requirements
  digitalWrite(buzz,HIGH);
  if (val == "0") {
    Serial.println("Tanish");
    digitalWrite(ta,HIGH);
  } else if (val == "1") {
    Serial.println("Rahul");
    digitalWrite(ra,HIGH);
  } else if (val == "2") {
    Serial.println("Saurav");
  } else if (val == "3") {
    Serial.println("Adarshuc");
  } else {
    Serial.println("Face does not match");
  }
}
