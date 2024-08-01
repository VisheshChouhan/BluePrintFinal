#include <Adafruit_Fingerprint.h>

#include <Arduino.h>
#include <Wire.h>
#include <stdint.h>

#include <Adafruit_Fingerprint.h>
#include <map>
#include <string>
#include <vector>
#include "SPIFFS.h"
#include "BluetoothSerial.h"
// #include <SoftwareSerial.h>

#if !defined(CONFIG_BT_ENABLED) || !defined(CONFIG_BLUEDROID_ENABLED)
#error Bluetooth is not enabled! Please run `make menuconfig` to and enable it
#endif

#define FINGERPRINT_SERIAL Serial2



#define SCREEN_WIDTH 128  // OLED display width, in pixels
#define SCREEN_HEIGHT 32

#define OLED_RESET -1  // Reset pin # (or -1 if sharing Arduino reset pin)
// Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);

BluetoothSerial SerialBT;

// Define the pins for SoftwareSerial
// SoftwareSerial mySerial(16, 17); // RX, TX

Adafruit_Fingerprint finger = Adafruit_Fingerprint(&Serial2);


std::map<int, std::string> fingerToStudentMap;  // Maps finger IDs to student enrollment numbers
std::vector<std::string> presentStudents;       // List of present students (their enrollment numbers)
// Declare and initialize global variables at the top of your code
int globalFingerID = -1;             // Initialize to an invalid value
String globalEnrollmentNumber = "";  // Initialize to an empty string
String globalTemplateData = "";      // Initialize to an empty string

String globalClassData = "";         // Will store the info of the class whose data is stored in R307


enum State {
  IDLE,
  FINGER_ENROLL,
  FINGER_ENROLL_WITH_TEMPLATE,
  FINGER_VERIFY,
  RESET,
  SHOW_ATTENDANCE,
  SETUP_CLASS,
  EMPTY_DATABASE
};

State currentState = IDLE;

void setup() {

  // Initialize serial communication
  Serial.begin(115200);
  Serial2.begin(57600);

  if (!SPIFFS.begin(true)) {
    customPrintln("An error has occurred while mounting SPIFFS", true);
  }

  finger.begin(57600);

  pinMode(2, INPUT_PULLUP);  // Initialize GPIO 2 as input with pull-up


  // Initialize OLED display
  // if (!display.begin(SSD1306_SWITCHCAPVCC, 0x3C)) {
  //   Serial.println(F("SSD1306 allocation failed"));
  //   for (;;)
  //     ;
  // }
  // delay(2000);
  // display.display();
  // delay(2000);
  // display.clearDisplay();

  // // Initialize Hardware Serial for fingerprint sensor
  // mySerial.begin(57600, SERIAL_8N1, 17, 16);  // RX Pin 17, TX Pin 16

  SerialBT.begin("ESP32Attendance");




  // Has to reqwrite it 
  // Initialize fingerprint sensor
  while(!finger.verifyPassword())
  {
    Serial.println("Did not find fingerprint sensor :(");

  }
  if (finger.verifyPassword()) {
    Serial.println("Found fingerprint sensor!");
  } else {
    Serial.println("Did not find fingerprint sensor :(");
    // while (1) { delay(1); }
  }
  // Load attendance data
  loadAttendanceData();
  loadFingerToStudentMap();

  
}

void loop() {

  // Read button state
   int buttonState = digitalRead(2);

  // If button is pressed, set current state to FINGER_VERIFY
  if (buttonState == LOW) {
    currentState = FINGER_VERIFY;
  }


  // Main loop
  switch (currentState) {
    case IDLE:
      idleState();
      break;

    case FINGER_ENROLL:
      enrollState();
      break;
    

    case FINGER_ENROLL_WITH_TEMPLATE:
      downloadTemplateState();
      break;

    case FINGER_VERIFY:
      verifyState();
      break;

    case RESET:
      resetState();
      break;

    case SHOW_ATTENDANCE:
      showAttendanceState();
      break;
      
    case EMPTY_DATABASE:
      emptyDatabaseState();
      break;

    case SETUP_CLASS:
      setupClass();
      break;

    default:
      customPrintln("IDLE", true);
      break;
  }
}

void idleState() {
  // Check Serial input
  if (Serial.available()) {
    String command = Serial.readStringUntil('\n');
    handleCommand(command);
  }

  // Check Bluetooth Serial input
  if (SerialBT.available()) {
    String command = SerialBT.readStringUntil('\n');
    Serial.print("The command is: ");
    Serial.println(command);
    handleCommand(command);
  }
}


void handleCommand(String command) {
  if (command.startsWith("e-")) {
    int separatorIndex1 = command.indexOf('-');
    int separatorIndex2 = command.indexOf('-', separatorIndex1 + 1);
    if (separatorIndex1 != -1 && separatorIndex2 != -1) {
      String idString = command.substring(separatorIndex1 + 1, separatorIndex2);
      String enrollmentNumber = command.substring(separatorIndex2 + 1);
      int fingerID = idString.toInt();

      // Set the global variables or call the function directly
      globalFingerID = fingerID;
      globalEnrollmentNumber = enrollmentNumber;

      currentState = FINGER_ENROLL;
      return;
    }
  }
  else if (command.startsWith("t-")) {
    int separatorIndex1 = command.indexOf('-');
    int separatorIndex2 = command.indexOf('-', separatorIndex1 + 1);
    int separatorIndex3 = command.indexOf('-', separatorIndex2 + 1);
    if (separatorIndex1 != -1 && separatorIndex2 != -1 && separatorIndex3 != -1) {
      String idString = command.substring(separatorIndex1 + 1, separatorIndex2);
      String enrollmentNumber = command.substring(separatorIndex2 + 1, separatorIndex3);
      String templateData = command.substring(separatorIndex3 + 1);
      int fingerID = idString.toInt();

      // Set the global variables or call the function directly
      globalFingerID = fingerID;
      globalEnrollmentNumber = enrollmentNumber;
      globalTemplateData = templateData;

      Serial.print("Inside handle command");
      Serial.println(command);
      Serial.print("globalFingerId");
      Serial.println(globalFingerID);
      Serial.print("globalEnrollmentNumber");
      Serial.println(globalEnrollmentNumber);
      Serial.print("globalTemplateData");
      Serial.println(globalTemplateData);

      fingerID = -1;
      enrollmentNumber = "";
      templateData = "";

      currentState = FINGER_ENROLL_WITH_TEMPLATE;
      return;
    }
  }
  else if (command.startsWith("c")) {
    int separatorIndex1 = command.indexOf('-');
    
    if (separatorIndex1 != -1) {
      String classCode = command.substring(separatorIndex1 + 1);
      
      // Set the global variables or call the function directly
      globalClassData = classCode;
      
      
    }
    currentState = SETUP_CLASS;
    return;
  }


  // Existing switch-case for other commands
  switch (command.charAt(0)) {
    case 'e':
      currentState = FINGER_ENROLL;
      break;
    case 't':
      currentState = FINGER_ENROLL_WITH_TEMPLATE;
      break;
    case 'v':
      currentState = FINGER_VERIFY;
      break;
    case 'r':
      currentState = RESET;
      break;
    case 's':
      currentState = SHOW_ATTENDANCE;
      break;
    case 'p':
      currentState = EMPTY_DATABASE;
      break;
    
    case 'c':
      currentState = SETUP_CLASS;
      break;
      
    default:
      customPrintln("IDLE", true);
      break;
  }
}


void emptyDatabaseState(){
  finger.emptyDatabase();
  SerialBT.println("The fingerprint Database is cleared");
  currentState = IDLE;
}


String readDataFromBluetooth() {
  String receivedData = "";
  while (SerialBT.available()) {
    char c = SerialBT.read();
    if (c == '\n') {
      break;
    }
    receivedData += c;
  }
  return receivedData;
}





void enrollState() {
  customPrintln("Entering Finger Enroll Mode", true);
  Serial.print("Inside enrollState() function");

  if (globalFingerID != -1 && globalEnrollmentNumber != "") {


  } else {
    // Handle the case where the function was entered without valid global variables
    globalFingerID = -1;
    globalEnrollmentNumber = "";
    
    customPrintln("Invalid data. Returning to IDLE.", true);
    currentState = IDLE;
    return;
  }


  int maxAttempts = 3;
  int attempts = 0;
  int result;

  while (attempts < maxAttempts) {
    std::string stdEnrollmentNumber = globalEnrollmentNumber.c_str();  // Convert to std::string
    result = enrollFingerprint(globalFingerID, stdEnrollmentNumber);
    if (result == FINGERPRINT_OK) {
      customPrintln("Enrollment successful!", true);
      break;
    } else {
      attempts++;
      customPrintln("Enrollment failed! Attempt " + String(attempts) + " of " + String(maxAttempts), true);
      delay(2000);  // Wait for 2 seconds before retrying
    }
  }

  if (attempts == maxAttempts) {
    customPrintln("Failed to enroll after " + String(maxAttempts) + " attempts.", true);
  }

  delay(2000);  // Wait for 2 seconds
  currentState = IDLE;
}


void verifyState() {
  customPrintln("Entering Finger Verify Mode", true);

  int maxAttempts = 3;
  int attempts = 0;
  int result;

  while (attempts < maxAttempts) {
    result = verifyFingerprint();
    if (result == FINGERPRINT_OK) {
      customPrintln("Verification successful!", true);

      for (const std::string& enrollmentNumber : presentStudents) {
        customPrintln("Present student: " + String(enrollmentNumber.c_str()), true);
      }

      // Save attendance data
      saveAttendanceData();
      break;
    } else {
      attempts++;
      customPrintln("Verification failed! Attempt " + String(attempts) + " of " + String(maxAttempts), true);
      delay(2000);  // Wait for 2 seconds before retrying
    }
  }

  if (attempts == maxAttempts) {
    customPrintln("Failed to verify after " + String(maxAttempts) + " attempts.", true);
  }

  delay(2000);  // Wait for 2 seconds
  currentState = IDLE;
  customPrintln("IDLE", true);
}


void resetState() {
  customPrintln("Resetting attendance data", true);

  // Clear the attendance data in SPIFFS
  clearAttendanceDataInSPIFFS();

  // Clear the presentStudents vector
  presentStudents.clear();

  customPrintln("Attendance data reset successfully", true);

  delay(2000);  // Wait for 2 seconds
  currentState = IDLE;
}


void customPrintln(String text, boolean showOnOLED) {
  Serial.println(text);
  if (showOnOLED) {
    // Code to display text on OLED will go here
    // displayOnOLED(text);
  }
}

// void displayOnOLED(String text) {

//   display.clearDisplay();
//   display.setTextSize(1);
//   display.setTextColor(SSD1306_WHITE);
//   display.setCursor(0, 0);
//   display.print(text);
//   display.display();
// }


int enrollFingerprint(int id, std::string enrollmentNumber) {
  int p = -1;

  customPrintln("Waiting for valid finger to enroll as ID #" + String(id), true);

  // SerialBT.println("Waiting for valid Student User Id");

  SerialBT.println("ep: Please Scan your Finger");
  Serial.println("Please scan you finger");

  while (p != FINGERPRINT_OK) {
    p = finger.getImage();
    switch (p) {
      case FINGERPRINT_OK:
        customPrintln("Image taken", true);
        SerialBT.println("ep: Image taken");
        break;
      case FINGERPRINT_NOFINGER:
        // customPrintln(".", false);
        Serial.print(".");
        break;
      case FINGERPRINT_PACKETRECIEVEERR:
        customPrintln("Communication error", true);
        SerialBT.println("ep: Communication error");
        return p;
      case FINGERPRINT_IMAGEFAIL:
        customPrintln("Imaging error", true);
        SerialBT.println("ep: Imaging error");
        return p;
      default:
        customPrintln("Unknown error", true);
        SerialBT.println("ep: unknown error");
        return p;
    }
  }

  p = finger.image2Tz(1);
  if (p != FINGERPRINT_OK) {
    customPrintln("Failed to convert image", true);
    SerialBT.println("ep: Failed to convert image");
    return p;
  }

  customPrintln("Remove finger", true);
  // Serial.println("Remove finger");
  SerialBT.println("ep: Remove finger");
  

  delay(2000);

  while (p != FINGERPRINT_NOFINGER) {
    p = finger.getImage();
  }

  SerialBT.println("ep: Please Scan your Finger again");
  // Serial.println("Please Scan your Finger again");

  customPrintln("Place same finger again", true);

  p = -1;
  while (p != FINGERPRINT_OK) {
    p = finger.getImage();
    switch (p) {
      case FINGERPRINT_OK:
        customPrintln("Image taken", true);
        SerialBT.println("ep: Image taken");
        break;
      case FINGERPRINT_NOFINGER:
        // customPrintln(".", false);
        Serial.print(".");
        break;
      case FINGERPRINT_PACKETRECIEVEERR:
        customPrintln("Communication error", true);
        SerialBT.println("ep: Communication error");
        return p;
      case FINGERPRINT_IMAGEFAIL:
        customPrintln("Imaging error", true);
        SerialBT.println("ep: Imaging error");
        return p;
      default:
        customPrintln("Unknown error", true);
        SerialBT.println("ep: Unknown error");
        return p;
    }
  }

  p = finger.image2Tz(2);
  if (p != FINGERPRINT_OK) {
    customPrintln("Failed to convert image", true);
    SerialBT.println("ep: Failed to convert image");
    return p;
  }

  p = finger.createModel();
  if (p == FINGERPRINT_OK) {
    customPrintln("Prints matched!", true);
    SerialBT.println("ep: Prints matched!");
  } else {
    customPrintln("Failed to match prints", true);
    SerialBT.println("ep: Failed to match prints");
    return p;
  }

  p = finger.storeModel(id);
  if (p == FINGERPRINT_OK) {
    customPrintln("Stored!", true);
    SerialBT.println("ep: Stored!");
    // Map the finger ID to the student enrollment number
    storeFingerToStudent(id, enrollmentNumber);
    saveFingerToStudentMap();
  } else {
    customPrintln("Failed to store model", true);
    SerialBT.println("ep: Failed to store model");
    return p;
  }

  // int load_model = finger.loadModel(id);
  // SerialBT.print("Load Model ");
  // SerialBT.println(load_model);
  // int tem = finger.getModel();
  // SerialBT.println(tem);
  // Serial.print(tem);

  // Testing getFingerprintTemplate function
  downloadFingerprintTemplate(id);


  
  // Serial.println("Enrollment Successfull");

  return FINGERPRINT_OK;  // Success
}

uint8_t downloadFingerprintTemplate(uint16_t id)
{
  Serial.println("------------------------------------");
  Serial.print("Attempting to load #"); Serial.println(id);
  uint8_t p = finger.loadModel(id);
  switch (p) {
    case FINGERPRINT_OK:
      Serial.print("Template "); Serial.print(id); Serial.println(" loaded");
      break;
    case FINGERPRINT_PACKETRECIEVEERR:
      Serial.println("Communication error");
      return p;
    default:
      Serial.print("Unknown error "); Serial.println(p);
      return p;
  }

  // OK success!

  Serial.print("Attempting to get #"); Serial.println(id);
  p = finger.getModel();
  switch (p) {
    case FINGERPRINT_OK:
      Serial.print("Template "); Serial.print(id); Serial.println(" transferring:");
      break;
    default:
      Serial.print("Unknown error "); Serial.println(p);
      return p;
  }

  // one data packet is 267 bytes. in one data packet, 11 bytes are 'usesless' :D
  // uint8_t bytesReceived[534]; // 2 data packets
  // memset(bytesReceived, 0xff, 534);

  // uint32_t starttime = millis();
  // int i = 0;
  // while (i < 534 && (millis() - starttime) < 20000) {
  //   if (FINGERPRINT_SERIAL.available()) {
  //     bytesReceived[i++] = FINGERPRINT_SERIAL.read();
      
  //   }
  // }
  // Serial.print(i); Serial.println(" bytes read.");
  // Serial.println("Decoding packet...");

  // uint8_t fingerTemplate[512]; // the real template
  // memset(fingerTemplate, 0xff, 512);

  // // filtering only the data packets
  // int uindx = 9, index = 0;
  // memcpy(fingerTemplate + index, bytesReceived + uindx, 256);   // first 256 bytes
  // uindx += 256;       // skip data
  // uindx += 2;         // skip checksum
  // uindx += 9;         // skip next header
  // index += 256;       // advance pointer
  // memcpy(fingerTemplate + index, bytesReceived + uindx, 256);   // second 256 bytes

  uint8_t fingerTemplate[512];
  finger.get_template_buffer(512, fingerTemplate);

  SerialBT.print("tb");
  for (int i = 0; i < 512; ++i) {
    //Serial.print("0x");
    printHex(fingerTemplate[i], 2, i);
    // Serial.print(fingerTemplate[i]);
    // SerialBT.print(fingerTemplate[i]);
    //Serial.print(", ");
    if(i%50==0) 
    {
      delay(2000);
      SerialBT.println();
      }

  }




  // SerialBT.println("done");
  SerialBT.println("te");

  SerialBT.println("ep: Enrollment Successfull");
  Serial.println("\ndone.");

  return p;

  
}
void printHex(int num, int precision, int i) {
  char tmp[16];
  char format[128];

  // sprintf(format, "template: %d: %%.%dX", i,  precision);


  // Should be decommented other wise it fingerprint will not be downloaded in the flutter application
  sprintf(format, "tp: %%.%dX", precision);

  //To remove just for debuggingg
  // sprintf(format, "%%.%dX", precision);

  sprintf(tmp, format, num);
  Serial.print(tmp);
  // SerialBT.print(i);
  // SerialBT.print(": ");
  SerialBT.println(tmp);
}



int downloadTemplateState(){
  customPrintln("Entering Finger Enroll with Template Mode", true);
  Serial.print("Inside downloadTemplateState() function");

  if (globalFingerID != -1 && globalEnrollmentNumber != "" && globalTemplateData != "") {
    Serial.print("globalFingerId");
    Serial.println(globalFingerID);
    Serial.print("globalEnrollmentNumber");
    Serial.println(globalEnrollmentNumber);
    Serial.print("globalTemplateData");
    Serial.println(globalTemplateData);



  } else {
    // Handle the case where the function was entered without valid global variables
    Serial.print("globalFingerId");
    Serial.println(globalFingerID);
    Serial.print("globalEnrollmentNumber");
    Serial.println(globalEnrollmentNumber);
    Serial.print("globalTemplateData");
    Serial.println(globalTemplateData);

    globalFingerID = -1;
    globalEnrollmentNumber = "";
    
    customPrintln("Invalid data. Returning to IDLE.", true);
    currentState = IDLE;
    return -1;
  }


  int maxAttempts = 3;
  int attempts = 0;
  int result;

  while (attempts < maxAttempts) {
    std::string stdEnrollmentNumber = globalEnrollmentNumber.c_str(); 
    std::string stdTemplateData = globalTemplateData.c_str(); // Convert to std::string


    //For debbuging 
    Serial.println("The template before is ");
    // downloadFingerprintTemplate(globalFingerID);


    result = write_template_data_to_sensor(globalFingerID, stdEnrollmentNumber, stdTemplateData);
    if (result == FINGERPRINT_OK) {
      customPrintln("Enrollment successful!", true);
      Serial.println("The template after is ");
      // downloadFingerprintTemplate(globalFingerID);
      // delay(5000);
      
      break;
    } else {
      attempts++;
      customPrintln("Enrollment failed! Attempt " + String(attempts) + " of " + String(maxAttempts), true);
      delay(2000);  // Wait for 2 seconds before retrying
    }
  }

  if (attempts == maxAttempts) {
    customPrintln("Failed to enroll after " + String(maxAttempts) + " attempts.", true);
  }
  currentState = IDLE;

  delay(2000);  // Wait for 2 seconds

  return FINGERPRINT_OK;
  
}

// To write template to fingerprint sensor
int write_template_data_to_sensor(int id, std::string enrollmentNumber, std::string inputString) {
  int template_buf_size=512; //usually hobby grade sensors have 512 byte template data, watch datasheet to know the info
  

  uint8_t fingerTemplate[512]; //this is where you need to store your template data 

  convertStringToByteArray(inputString, fingerTemplate);

  for (int i = 0; i < 512; i++) {
    // Combine two characters into one uint8_t value
    char highNibble = inputString[i * 2];
    char lowNibble = inputString[i * 2 + 1];
    
    uint8_t highValue = charToHexValue(highNibble);
    uint8_t lowValue = charToHexValue(lowNibble);
    
    fingerTemplate[i] = (highValue << 4) | lowValue;
  }

  Serial.print("Fingerprint TEmplate");
  Serial.println(fingerTemplate[0]);
  inputString = "";
  
  // you can manually save the data got from "get_template.ino" example like this

  // uint8_t fingerTemplate[512]={0x03,0x0E,....your template data.....};

  // uint8_t fingerTemplate[512]={0x03,0x03,0x5B,0x29,0x10,0x01,0x4F,0x01,0x7B,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x13,0x00,0x05,0x00,0x81,0x00,0x0F,0xF0,0x33,0x3F,0xFC,0xCF,0xFF,0x3F,0xBF,0xFF,0xFF,0xEE,0xAA,0xAA,0xAA,0xAA,0x9A,0xAA,0x99,0x56,0x55,0x55,0x55,0x55,0x55,0x55,0x44,0x04,0x00,0x01,0x00,0x04,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x11,0xF8,0xEF,0x01,0xFF,0xFF,0xFF,0xFF,0x02,0x00,0x82,0x25,0x15,0x0E,0x7E,0x60,0x1C,0x0D,0xBE,0x1F,0x1B,0xE4,0xFE,0x34,0x9C,0x4E,0xDE,0x28,0x20,0xA5,0x9E,0x11,0xA4,0x8F,0x7E,0x2B,0x27,0x8F,0xFE,0x59,0x28,0xA3,0xDE,0x27,0x30,0x0F,0x9E,0x55,0x35,0x8D,0x9E,0x58,0xBB,0xE4,0x3E,0x61,0x44,0xA5,0x9E,0x22,0x45,0x52,0xDE,0x55,0xC7,0xE4,0xDE,0x27,0xC9,0x91,0xDE,0x2B,0x98,0xA1,0xFF,0x3F,0x1F,0xCD,0xFF,0x57,0x22,0x0C,0xBF,0x11,0xAB,0x92,0xBF,0x50,0x31,0xA3,0x9F,0x1E,0xB3,0x10,0xDF,0x3F,0xB6,0x24,0x3F,0x29,0xB6,0xE5,0xFF,0x24,0xBA,0x50,0xFF,0x4C,0x42,0x4E,0xFF,0x1E,0x2A,0xCF,0x3C,0x41,0xAC,0x4D,0xFC,0x67,0xB7,0xA3,0x5C,0x37,0xC7,0xCF,0xBC,0x64,0x3B,0xF6,0xEF,0x01,0xFF,0xFF,0xFF,0xFF,0x02,0x00,0x82,0x1E,0x2D,0xE6,0x7A,0x12,0xB4,0xE6,0xDB,0x64,0x49,0x8D,0xBB,0x13,0xB9,0xE7,0x38,0x10,0xB8,0x52,0xF9,0x36,0xCB,0xE6,0x99,0x32,0x4D,0xD2,0x76,0x32,0x4C,0x28,0xD7,0x4C,0x0F,0x4F,0x1F,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x11,0x36,0xEF,0x01,0xFF,0xFF,0xFF,0xFF,0x02,0x00,0x82,0x03,0x03,0x63,0x28,0x00,0x01,0x20,0x01,0x81,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x03,0x00,0x03,0x00,0x79,0x00,0x00,0x00,0x30,0x00,0x03,0x0C,0xCF,0xFC,0xCF,0xFF,0x3F,0xBF,0xFF,0xFF,0xEE,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0x65,0x55,0x55,0x55,0x55,0x55,0x55,0x54,0x44,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};

  
  
  // memset(fingerTemplate, 0xff, 512); //comment this line if you've manually put data to the line above
  
  Serial.println("Ready to write template to sensor...");
  Serial.println("Enter the id to enroll against, i.e id (1 to 127)");
  // int id = readnumber();
  // if (id == 0) {// ID #0 not allowed, try again!
  //   return;
  // }
  Serial.print("Writing template against ID #"); Serial.println(id);

  if (finger.write_template_to_sensor(template_buf_size,fingerTemplate,1)) { //telling the sensor to download the template data to it's char buffer from upper computer (this microcontroller's "fingerTemplate" buffer)
    Serial.println("now writing to sensor...");
    // finger.download
  } else {
    Serial.println("writing to sensor failed");
    return -1;
  }

  if (finger.write_template_to_sensor(template_buf_size,fingerTemplate, 2)) { //telling the sensor to download the template data to it's char buffer from upper computer (this microcontroller's "fingerTemplate" buffer)
    Serial.println("now writing to sensor...");
    // finger.download
  } else {
    Serial.println("writing to sensor failed");
    return -1;
  }


  
  // if (finger.createModel() == FINGERPRINT_OK) {
  //   customPrintln("Both templates matched matched!", true);
  // } else {
  //   customPrintln("Failed to match prints", true);
  //   return -1;
  // }

  Serial.print("ID "); Serial.println(id);
  if (finger.storeModel(id) == FINGERPRINT_OK) { //saving the template against the ID you entered or manually set
    Serial.print("Successfully stored against ID#");Serial.println(id);
    storeFingerToStudent(id, enrollmentNumber);
    saveFingerToStudentMap();
    // globalTemplateData = "";
    // globalEnrollmentNumber = "";
    // globalFingerID = -1;
    return FINGERPRINT_OK;
  } else {
    Serial.println("Storing error");
    return -1 ;
  }
}


void convertStringToByteArray(const std::string str, uint8_t *array) {
  for (int i = 0; i < 512; i++) {
    // Combine two characters into one uint8_t value
    char highNibble = str[i * 2];
    char lowNibble = str[i * 2 + 1];
    
    uint8_t highValue = charToHexValue(highNibble);
    uint8_t lowValue = charToHexValue(lowNibble);
    
    array[i] = (highValue << 4) | lowValue;
  }
}

uint8_t charToHexValue(char c) {
  if (c >= '0' && c <= '9') {
    return c - '0';
  } else if (c >= 'A' && c <= 'F') {
    return c - 'A' + 10;
  } else if (c >= 'a' && c <= 'f') {
    return c - 'a' + 10;
  }
  return 0; // Default case, although input should be validated before this
}




void storeFingerToStudent(int fingerId, std::string enrollmentNumber) {
  fingerToStudentMap[fingerId] = enrollmentNumber;
}

int verifyFingerprint() {
  int p = -1;

  customPrintln("Place your finger for verification", true);

  // Wait for a valid finger press
  while (p != FINGERPRINT_OK) {
    p = finger.getImage();
  }

  // Convert the image to a feature template
  p = finger.image2Tz(1);
  if (p != FINGERPRINT_OK) {
    return p;
  }

  // Search for a match in the database
  p = finger.fingerFastSearch();
  if (p != FINGERPRINT_OK) {
    return p;
  }

  int fingerID = finger.fingerID;

  // Check if the student has already been marked present
  std::string enrollmentNumber = fingerToStudentMap[fingerID];
  if (std::find(presentStudents.begin(), presentStudents.end(), enrollmentNumber) != presentStudents.end()) {
    customPrintln("Student already marked present", true);
    return FINGERPRINT_OK;
  }

  // Mark the student as present
  presentStudents.push_back(enrollmentNumber);
  customPrintln("Verification successful! Student marked present.", true);

  return FINGERPRINT_OK;  // Success
}


void saveAttendanceData() {
  File file = SPIFFS.open("/attendance.txt", FILE_WRITE);

  if (!file) {
    customPrintln("Failed to open file for writing", true);
    return;
  }

  for (const std::string& enrollmentNumber : presentStudents) {
    if (file.println(enrollmentNumber.c_str())) {
      customPrintln("Written to file: " + String(enrollmentNumber.c_str()), true);
    } else {
      customPrintln("Write failed", true);
    }
  }

  file.flush();
  file.close();
}


void loadAttendanceData() {
  File file = SPIFFS.open("/attendance.txt", FILE_READ);

  if (!file) {
    customPrintln("Failed to open file for reading", true);
    return;
  }

  customPrintln("Opened File for Reading", true);



  presentStudents.clear();  // Clear any existing data

  while (file.available()) {
    String line = file.readStringUntil('\n');
    presentStudents.push_back(line.c_str());
  }

  file.close();
}


void showAttendanceState() {
  customPrintln("Showing attendance data", true);

  File file = SPIFFS.open("/attendance.txt", FILE_READ);

  if (!file) {
    customPrintln("Failed to open file for reading", true);
    return;
  }


  // customPrintln("Attendance List:", true);
  SerialBT.println("AS:");

  while (file.available()) {
    String line = "ps: " + file.readStringUntil('\n');
    // customPrintln(line, true);
    SerialBT.println(line);
  }

  SerialBT.println("AE:");
  file.close();

  delay(2000);  // Wait for 2 seconds
  currentState = IDLE;
}

void clearAttendanceDataInSPIFFS() {
  // Clear the SPIFFS file
  File file = SPIFFS.open("/attendance.txt", FILE_WRITE);
  if (!file) {
    customPrintln("Failed to open file for writing", true);
    return;
  }
  file.close();  // Truncate the file to zero length
}


void saveFingerToStudentMap() {
  File file = SPIFFS.open("/fingerToStudentMap.txt", FILE_WRITE);

  if (!file) {
    customPrintln("Failed to open file for writing", true);
    return;
  }

  for (const auto& pair : fingerToStudentMap) {
    String line = String(pair.first) + "," + String(pair.second.c_str());
    file.println(line);
  }

  file.flush();
  file.close();
}


void loadFingerToStudentMap() {
  File file = SPIFFS.open("/fingerToStudentMap.txt", FILE_READ);

  if (!file) {
    customPrintln("Failed to open file for reading", true);
    return;
  }

  fingerToStudentMap.clear();

  while (file.available()) {
    String line = file.readStringUntil('\n');
    int separatorIndex = line.indexOf(',');
    if (separatorIndex != -1) {
      int fingerID = line.substring(0, separatorIndex).toInt();
      String enrollmentNumber = line.substring(separatorIndex + 1);
      fingerToStudentMap[fingerID] = enrollmentNumber.c_str();
    }
  }

  file.close();
}



// Functions to Setup the class in fingerprint Scanner;
void setupClass() {
  finger.emptyDatabase();
  SerialBT.println("cd: sended");
  currentState = IDLE;
}
