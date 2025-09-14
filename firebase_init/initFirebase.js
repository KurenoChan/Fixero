// import initData.js

// ************************************************************************
// TO RUN THIS, Open the Terminal, type: node firebase_init/initFirebase.js
// ************************************************************************

const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

// Get data from initData.js
const { managers, suppliers, customers, items } = require("./initData");

// Initialize an empty map to store manager UIDs based on their email
const managerUidMap = {}; // key: email, value: UID


// Record the Firebase-generated UID for each manager
const managerUids = [];

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://fixero-9e0a9-default-rtdb.firebaseio.com/"
//  databaseURL: "https://fixero-b9b13-default-rtdb.asia-southeast1.firebasedatabase.app"
});

const auth = admin.auth();
const db = admin.database();

async function resetDatabase() {
  console.log("\n\n🚨 Clearing Realtime Database...");
  await db.ref().set(null);
  console.log("✅ Database cleared");
}

async function clearAuthUsers(nextPageToken) {
  console.log("\n\n🚨 Clearing Auth users...");
  const listUsersResult = await auth.listUsers(1000, nextPageToken);
  for (const user of listUsersResult.users) {
    await auth.deleteUser(user.uid);
    console.log(`Deleted user: ${user.email}`);
  }
  if (listUsersResult.pageToken) {
    await clearAuthUsers(listUsersResult.pageToken);
  }
}

// =========================
// USERS DATA INITIALIZATION
// =========================
// 1. WORKSHOP MANAGERS (AUTH + REALTIME DB)
async function createUsersAndSeedData() {
  console.log("\n\n🚨 Creating users and seeding data...");
  for (const u of managers) {
    try {
      // Create Auth user
      const userRecord = await auth.createUser(u);
      console.log(`✅ Created user: ${userRecord.email} (${userRecord.uid})`);
      
      // Store only required fields under users/managers/{uid}
      await db.ref("users/managers/" + userRecord.uid).set({
        managerName: u.displayName,
        managerPassword: u.password, // ⚠️ Storing password in DB is insecure, maybe hash it?
        managerEmail: u.email
      });
      
      managerUids.push(userRecord.uid); // Store UID for export
      managerUidMap[u.email] = userRecord.uid; // Store UID by email for easy lookup

    } catch (err) {
      if (err.code === "auth/email-already-exists") {
        console.log(`⚠️ User already exists: ${u.email}`);
      } else {
        console.error(`❌ Error creating user ${u.email}:`, err.message);
      }
    }
  }
}

// 2. SUPPLIERS
async function seedSuppliers() {
  console.log("\n\n🚨 Seeding suppliers...");
  for (const supplier of suppliers) {
    try {
      await db.ref("users/suppliers/" + supplier.supplierID).set({
        supplierName: supplier.supplierName,
        supplierEmail: supplier.supplierEmail,
        supplierTel: supplier.supplierTel,
        address1: supplier.address1,
        address2: supplier.address2,
        postalCode: supplier.postalCode,
        street: supplier.street,
        city: supplier.city,
        state: supplier.state,
        country: supplier.country
      });

      console.log(`✅ Added supplier: ${supplier.supplierName} (${supplier.supplierEmail})`);
    } catch (err) {
      console.error(`❌ Error seeding supplier ${supplier.supplierEmail}:`, err.message);
    }
  }
}

// 3. CUSTOMERS
async function seedCustomers() {
  console.log("\n\n🚨 Seeding customers...");
  for (const customer of customers) {
    try {
      await db.ref("users/customers/" + customer.custID).set({
        custName: customer.custName,
        custEmail: customer.custEmail,
        custTel: customer.custTel,
        address1: customer.address1,
        address2: customer.address2,
        postalCode: customer.postalCode,
        street: customer.street,
        city: customer.city,
        state: customer.state,
        country: customer.country
      });

      console.log(`✅ Added customer: ${customer.custName} (${customer.custEmail})`);
    } catch (err) {
      console.error(`❌ Error seeding customer ${customer.custEmail}:`, err.message);
    }
  }
}

// 4. MECHANICS
async function seedMechanics() {

}

// =============================
// INVENTORY DATA INITIALIZATION
// =============================
// 1. ITEMS
async function seedItems() {
  console.log("\n\n🚨 Seeding items...");
  for (const item of items) {
    try {
      await db.ref("inventory/items/" + item.itemID).set({
        itemName: item.itemName,
        itemDescription: item.itemDescription,
        itemCategory: item.itemCategory,
        itemSubCategory: item.itemSubCategory,
        itemPrice: item.itemPrice,
        stockQuantity: item.stockQuantity,
        unit: item.unit,
        lowStockThreshold: item.lowStockThreshold,
        itemImageUrl: item.itemImageUrl
      });

      console.log(`✅ Added item: ${item.itemName}`);
    } catch (err) {
      console.error(`❌ Error seeding item ${item.itemID}:`, err.message);
    }
  }
}

// 2. ITEMUSAGE
async function seedItemUsage() {

}

// 3. PROCUREMENTREQUESTS
async function seedProcurementRequests() {

}

// 4. ITEMREQUESTS
async function seedItemRequests() {

}

// 5. ORDERS
async function seedOrders() {

}

// ===============================
// JOBSERVICES DATA INITIALIZATION
// ===============================
// 1. JOBS
async function seedJobs() {

}

// 2. INVOICES
async function seedInvoices() {

}

// ==================================
// COMMUNICATIONS DATA INITIALIZATION
// ==================================
// 1. CUSTOMERCHATS
async function seedCustomerChats() {
  
}


// **********************************
// **********************************
// **********************************

async function run() {
    await resetDatabase();
    await clearAuthUsers();

    // Real-time DB Initialization + Auth User Creation for WORKSHOP MANAGERS
    await createUsersAndSeedData();

    // Export after all managers created
    module.exports.managerUids = managerUids;

    // Realtime DB Initialization
    await seedSuppliers();
    await seedCustomers();
    await seedItems();

    console.log("✅ Seeding finished");
    console.log("Manager UIDs:", managerUids);
    process.exit(0);
}

run();