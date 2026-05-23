

# 🍽️ BitePaya – Multi Vendor Food Ordering System

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

## 🔔 Real-Time System (Socket.IO)

BitePaya uses **Socket.IO** to sync data instantly:

- New order → instantly sent to vendor
- Order status update → instantly sent to user
- Vendor actions → live reflected on admin panel
- No page refresh required

---

## 💳 Payment System
- Secure payment flow
- Order confirmation after successful payment
- Transaction tracking
- Optional wallet system

---

## 🧠 Tech Stack

### 📱 Frontend
- Flutter (User + Vendor Mobile App)
- React.js (Admin Panel)

### 🖥 Backend
- Node.js (Express API Server)
- Socket.IO (Real-time communication)
- Python (Optional microservices / AI processing)

### 🗄 Database
- MongoDB / PostgreSQL

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
<img src="https://github.com/user-attachments/assets/cc6c77dd-342b-4de0-a96c-a908a50cb459" width="180"/>
<img src="https://github.com/user-attachments/assets/daeaa72e-da97-409a-b508-806a815971e8" width="180"/>
<img src="https://github.com/user-attachments/assets/25099ae8-40fc-4d67-bd33-095c9d0bb3a1" width="180"/>
<img src="https://github.com/user-attachments/assets/cc301f2a-2839-4036-9359-9d7abae8cabd" width="180"/>
<img src="https://github.com/user-attachments/assets/e567b652-c656-48c6-b29d-0967a805f4ec" width="180"/>
<img src="https://github.com/user-attachments/assets/4580c7f6-4bc0-4a68-bbb3-4317526de40f" width="180"/>
<img src="https://github.com/user-attachments/assets/1401dd15-b00a-4f27-95b9-cf748f6c448a" width="180"/>
<img src="https://github.com/user-attachments/assets/8754b7d7-4734-4f4e-b3b9-a5796f1fcbce" width="180"/>
<img src="https://github.com/user-attachments/assets/ffff946f-5419-4f9b-b500-72f6d150b242" width="180"/>
<img src="https://github.com/user-attachments/assets/59bdadd4-b8db-44b5-b384-247aef820e70" width="180"/>

</div>

### Vendor Flow

<div align="center">
<img src="https://github.com/user-attachments/assets/5d797587-6bb8-4647-a90c-d571cb31cc39" width="180"/>
<img src="https://github.com/user-attachments/assets/06c18ddf-fa54-4b34-b3dd-d5a35fee7fee" width="180"/>
<img src="https://github.com/user-attachments/assets/7d4393f6-e94f-4f1b-9e29-dca05c374f05" width="180"/>
<img src="https://github.com/user-attachments/assets/389b0d2a-21db-4891-98e4-85ec903c46eb" width="180"/>
<img src="https://github.com/user-attachments/assets/ec90568b-475b-4a94-817e-9ed124c946b8" width="180"/>
<img src="https://github.com/user-attachments/assets/41b04ef2-83b6-4567-b7ae-757c3e121a11" width="180"/>
<img src="https://github.com/user-attachments/assets/daa6e4f5-8491-4b8f-8fa0-cff3feffbbba" width="180"/>
<img src="https://github.com/user-attachments/assets/ff905ea1-b59a-4e27-b98a-9b3aa7eba315" width="180"/>
</div>


