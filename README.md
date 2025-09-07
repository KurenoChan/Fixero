# 🚗 Fixero

**Fixero** is a mobile application prototype built for automotive workshop managers to efficiently manage jobs, vehicles, mechanics, inventory, and customer interactions — all in one place. Designed for Greenstem Business Software Sdn Bhd, this solution bridges the gap between traditional Workshop Management Systems (WMS) and modern mobile accessibility.

---

## 📱 Key Features

- 🔧 **Job Management**

  - View, create, schedule, and assign repair jobs
  - Track job status: Scheduled, Ongoing, Completed
  - Job filters, mechanic allocation, and service insights
- 🚙 **Vehicle Management**

  - Browse vehicles by type (car, bike, van, truck)
  - View detailed vehicle records (plate no, model, color, year)
  - Access full service history linked to customer jobs
- 🧑‍🔧 **Mechanic Oversight**

  - Assign jobs based on workload and specialties
  - Track mechanic status and history
- 🛠️ **Inventory Control**

  - Browse categorized spare parts and tools
  - Real-time stock alerts (low, out-of-stock)
  - Manage restocks and procurement requests
  - View supplier history and stock usage trends
- 📄 **Invoice Management**

  - Generate and track invoices linked to jobs
  - Monitor payment status and totals
- 💬 **Customer CRM**

  - View customer profiles and vehicle ownership
  - Access communication and interaction history
  - Optional customer portal for job updates or chat

---

## 🧭 Navigation Structure

```
Home
├── Dashboard (Stats + Overview)
│ ├── Active Jobs
│ ├── Low Stock Parts
│ ├── Pending Invoices
│ └── Weekly Insights (Charts)
├── Jobs
│ ├── Job List (All / Ongoing / Completed)
│ ├── Job Details → Assign Mechanic, View Invoice
│ └── Create Job
├── Vehicles
│ ├── Browse by Type → Model List
│ └── Vehicle Details → Service History
├── Inventory
│ ├── Browse Inventory → Category → Subcategory → Item
│ ├── Stock Alerts
│ ├── Issue History
│ └── Procurement Requests
├── Settings
├── Profile
└── App Preferences
```

---

## 🛠️ Tech Stack

- **Framework**: Flutter
- **Backend**: Firebase (Authentication, Firestore, Storage)
- **State Management**: Provider (or Riverpod / GetX if used)
- **Database**: Firestore (NoSQL)
- **Design**: Figma (Prototypes), Dribbble inspirations

---

## 🚀 Getting Started

1. Clone the repo:
   ```bash
   git clone https://github.com/yourusername/fixero.git
   cd fixero
   ```
