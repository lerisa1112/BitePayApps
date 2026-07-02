# 
<p align="center">
  <img src="https://github.com/user-attachments/assets/4a2edb0a-c7dd-4060-b9c5-6a10500e9ad8" width="40" align="center"/>
  <span style="font-size:28px; font-weight:bold; vertical-align:middle;">
    BitePay
  </span>
</p>


BitePaya is a full-stack real-time multi-vendor food ordering platform where users can browse vendors, place orders, and track them instantly. Vendors manage menus and orders, while admins control approvals and platform monitoring.

The system uses **Socket.IO for real-time synchronization**, ensuring instant order updates across user, vendor, and admin dashboards.

---

## 🚀 Project Overview

BitePaya connects three main roles:

- 👤 **User (Customer)**
- 🏪 **Vendor (Restaurant/Service Provider)**
- 🛠️ **Admin Panel**

It supports real-time ordering, live status updates, secure authentication, and payment flow.

---

## ⚡ Key Features

### 👤 User Panel
- User registration & login (JWT auth)
- Browse approved vendors only
- View menus and place orders
- Real-time order tracking
- Order history
- Profile management
- Live notifications

---

### 🏪 Vendor Panel
- Vendor registration (admin approval required)
- Add / update / delete menu items
- Receive real-time order notifications (Socket.IO)
- Accept / reject orders
- Update order status (Preparing → Ready → Delivered)
- Earnings tracking

---

### 🛠️ Admin Panel (React.js)
- Vendor approval / rejection system
- Manage users and vendors
- Monitor all orders in real-time
- Block/unblock accounts
- System overview dashboard

---



## 🧠 Tech Stack

### 📱 Frontend
- Flutter (User + Vendor Mobile App)
- React.js (Admin Panel)

### 🖥 Backend
- Node.js (Express API Server)
- Socket.IO (Real-time communication)
- Python (Microservices / AI processing)
- FastAPI

### 🗄 Database
- MongoDB

### 

---

## 🔐 Authentication System
- JWT Authentication
- Role-based access control:
  - User
  - Vendor
  - Admin
- Secure API protection

---

## 📡 Screenshots

### User Flow

<div align="center">
<img src="https://github.com/user-attachments/assets/cd0febe4-8ea9-420b-b5f6-8698e842e5c0" width="180" />
<img src="https://github.com/user-attachments/assets/4e3568bc-618a-4b74-a76e-d595c1955e0a" width="180" />
<img  src="https://github.com/user-attachments/assets/f7f980c5-27a3-4aa1-b32a-04727706046a" width="180" />
<img src="https://github.com/user-attachments/assets/c7632b83-f462-472a-b1f7-896c439811cd" width="180" />
<img src="https://github.com/user-attachments/assets/c890d72a-fb9e-4ef5-bdce-062f81e34cf1" width="180" />
<img  src="https://github.com/user-attachments/assets/70f4d633-3d29-4ed7-80be-cc97dc308971" width="180" />
<img src="https://github.com/user-attachments/assets/84f5c748-b0b3-46db-9e90-fdd39690fb66" width="180" />
<img src="https://github.com/user-attachments/assets/ba947f23-00a4-4cd4-8e81-17b160ee89e1" width="180" />
<img src="https://github.com/user-attachments/assets/e8ebe02c-aecb-44a7-a1c9-f94db3d265cb" width="180" />
<img src="https://github.com/user-attachments/assets/fc0a933d-1e9b-43ee-9dd3-bac7e4f86848" width="180" />
<img src="https://github.com/user-attachments/assets/4b133205-facc-46cd-ab8c-9d26f043f707" width="180"  />
<img src="https://github.com/user-attachments/assets/0261b0b2-6d26-4180-ad4e-19b9555dfd5f" width="180"  />

</div>

### Vendor Flow

<div align="center">
<img src="https://github.com/user-attachments/assets/5d797587-6bb8-4647-a90c-d571cb31cc39" width="180"/>
<img src="https://github.com/user-attachments/assets/06c18ddf-fa54-4b34-b3dd-d5a35fee7fee" width="180"/>
<img src="https://github.com/user-attachments/assets/7d4393f6-e94f-4f1b-9e29-dca05c374f05" width="180"/>
<img src="https://github.com/user-attachments/assets/53d1ed7a-44c3-4c81-a83d-c030ff588fef" width="180" />
<img src="https://github.com/user-attachments/assets/389b0d2a-21db-4891-98e4-85ec903c46eb" width="180"/>
<img src="https://github.com/user-attachments/assets/ec90568b-475b-4a94-817e-9ed124c946b8" width="180"/>
<img src="https://github.com/user-attachments/assets/ff9e1d92-e65c-4bad-bc42-1ddee63222aa" width="180" />
<img src="https://github.com/user-attachments/assets/41b04ef2-83b6-4567-b7ae-757c3e121a11" width="180"/>
<img src="https://github.com/user-attachments/assets/daa6e4f5-8491-4b8f-8fa0-cff3feffbbba" width="180"/>
<img src="https://github.com/user-attachments/assets/ff905ea1-b59a-4e27-b98a-9b3aa7eba315" width="180"/>
</div>

### Admin Panel
<img width="1902" height="963" alt="image" src="https://github.com/user-attachments/assets/7682f5a5-6cce-45ed-b2ed-ab955bf59b9d" />
<img width="1899" height="969" alt="image" src="https://github.com/user-attachments/assets/fc723256-3d60-4e9c-9a6a-f5b00864c548" />
<img width="1901" height="970" alt="image" src="https://github.com/user-attachments/assets/56303c7e-5862-4eda-adc3-4bf7b03526c7" />
<img width="1908" height="956" alt="image" src="https://github.com/user-attachments/assets/62fe2e13-f668-497c-814d-a06e67369735" />
<img width="1913" height="974" alt="image" src="https://github.com/user-attachments/assets/841f233e-cf0d-4705-90bd-60cecd7beb50" />






