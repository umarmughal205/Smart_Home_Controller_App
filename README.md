# Smart Home Controller System (Smart Homie) 

The **Smart Home Controller System (Smart Homie)** is an integrated platform engineered to automate and manage modern living environments. It bridges the gap between user comfort and intelligent home management by providing a centralized, secure mobile interface to monitor and control household appliances in real-time.

---

## Key Features
* **Centralized Control Dashboard:** Manage household appliances (lights, fans, RGB strips, lamps) from a unified mobile interface.
* **Real-Time Synchronization:** Instant state updates and device monitoring powered by Firebase Realtime Database and Cloud Firestore.
* **Remote Accessibility:** Control and check device statuses from anywhere via cloud networking.
* **Secure Authentication & Roles:** Role-based access control supporting Home Members, Guests, and System Administrators with secure login and profile management.
* **Low-Latency Hardware Integration:** Direct communication with ESP32S microcontrollers using MQTT and HTTP/REST protocols.

---

## System Architecture & Tech Stack
The application is structured around a robust **3-tier architecture**:
* **Frontend / Presentation Layer:** Cross-platform mobile app built using **Flutter (Dart)** for Android & iOS.
* **Backend / Business Layer:** Application logic, data routing, and validation handled via Dart and Firebase services.
* **Hardware / Data Layer:** **Arduino UNO and ESP32S microcontrollers** programmed in **C++ using tool Arduino IDE** interfacing with sensors/actuators alongside Firebase database storage.

---

## Project Team & Contributions
Developed as a Bachelor of Science in Software Engineering (BS SE) final year project at the University of the Punjab, Gujranwala Campus (Session 2021–2025).

* **Muhammad Umar Afzal** *(Group Leader & Lead Developer)* – Managed project architecture, engineered the Flutter mobile application, configured Firebase real-time database workflows, and coordinated hardware-software integration.
* **Abubakar** *(Co-Author & Developer)* – Contributed to system requirements, module specifications, and testing.

---

## Future Scope
* **Edge Intelligence & Federated Learning:** Integrating decentralized model training across distributed IoT nodes to ensure user data privacy.
* **Lightweight Cryptography:** Incorporating advanced security protocols for encrypted edge-to-cloud communication.

---

## License
This project is developed for academic and portfolio demonstration purposes.
