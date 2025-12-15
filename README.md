# Point of Sale (POS) Demo Application

This application is an offline-capable Point of Sale (POS) system designed to streamline retail operations. It demonstrates a complete checkout flow—from browsing a menu to processing payments and reviewing order history—built with modern mobile application standards.

## 📱 Technology Stack

The application is built using **Flutter**, leveraging **clean architecture** principles to ensure scalability, testability, and separation of concerns.

-   **Frontend**: Flutter (Dart)
-   **State Management**: BLoC Pattern (Business Logic Component)
-   **Local Database**: SQLite
-   **Architecture**: Modular Clean Architecture (Presentation, Domain, and Data layers)

---

## 💾 Database Design

The application uses a relational SQLite database to ensure data integrity and persistence. The schema is designed to handle orders and payments atomically.

### **Tables & Relationships**

1.  **`menu`**
    *   **Purpose**: The highest level of organization (e.g., Food, Drinks).
    *   **Fields**: `id`, `name`.
    *   **Relations**: Parent to `category` and `item`.

2.  **`category`**
    *   **Purpose**: Sub-groups within a menu (e.g., Starters, Mains).
    *   **Fields**: `id`, `name`, `menu_id`.
    *   **Relations**: Linked to `menu` and parent to `item`.

3.  **`item`**
    *   **Purpose**: The registry of sellable goods, containing pricing and classification data.
    *   **Fields**: `id`, `name`, `price`, `cat_id`, `menu_id`.
    *   **Relations**: belongs to a `category` and `menu`.

4.  **`order_headers`**
    *   **Purpose**: Represents the high-level summary of a transaction.
    *   **Fields**: `id`, `order_date`, `order_status` (e.g., Pending, Completed), `total_amount`.
    *   **Relations**: Parent table for `order_items` and `payments`.

5.  **`order_items`**
    *   **Purpose**: A junction table linking specific products to an order.
    *   **Fields**: `order_id` (Foreign Key), `item_id` (Foreign Key), `price` (snapshot at time of purchase), `qty`, `total`.
    *   **Relations**:
        *   Many-to-One with `order_headers` (An order has many items).
        *   Many-to-One with `item` (Links to the product definition).

6.  **`payments`**
    *   **Purpose**: Records the financial transaction details.
    *   **Fields**: `id`, `order_id` (Foreign Key), `payment_date`, `amount_due`, `total_paid`, `payment_type` (Cash/Card), `payment_status`.
    *   **Relations**: One-to-One with `order_headers`.

---

## 📖 Feature Walkthrough: A Single Order - Start to Finish

**Scenario**: A customer approaches the counter to order some items.

1.  **Taking the Order (Menu)**:
    *   The cashier sees the **Menu** page.
    *   They tap the "Food" tab, select "Mains", and tap "Item 7" to add it to the cart.
    *   Switching to "Drinks", they tap "Item 3" under "Soft Drinks".

2.  **Review & Checkout (Cart)**:
    *   The cashier taps the Cart icon.
    *   The cashier informs the customer: "Total is **£5.00**."
    *   The customer hands over a £20 note.
    *   The cashier taps **"Cash"**.

3.  **Processing Payment**:
    *   A dialog appears asking for "Amount Tendered".
    *   The cashier types `20`.
    *   The system instantly calculates and displays "Change: £15.00".
    *   The cashier hands back the change and taps "Confirm".

4.  **Verification (Orders)**:
    *   The screen clears and shows "Order Placed Successfully".
    *   Later, the manager checks the **Orders** tab.
    *   They see the recent order at the top, marked with a **Green "Cash" Chip**, confirming the payment method and status.

---

## 🚀 Key Features

### 1. **Menu Module**
The landing page of the application providing an intuitive interface for staff to browse products.
*   **Dynamic Loading**: Items are fetched efficiently from the local database.
*   **Quick Add**: Staff can instantly add items to the active cart with a single tap.
*   **Categorization**: Items are organized logically (e.g., Food, Drinks) for fast access.

### 2. **Cart & Checkout Module**
The core transaction engine handling calculations and payment processing.
*   **Real-time Totals**: Automatically calculates subtotal, Tax (12.5%), and the final payable Total.
*   **Flexible Payment Options**:
    *   **💳 Card Payment**: A mock "One-Step" checkout for card payment flow.
    *   **💵 Cash Payment**: A dedicated dialog to input "Amount Tendered". The system automatically validates sufficiency and calculates the exact "Change Due" before confirming the order.
*   **Atomic Transactions**: The system ensures data integrity using database transactions. An order and its payment are saved together—if one fails, the entire transaction rolls back, preventing orders without payments.

### 3. **Orders History Module**
A comprehensive log of all past transactions.
*   **Detailed Records**: View every order placed, including date, time, and status.
*   **Payment Insight**: Displays a visual "Badge" indicating whether the order was paid via **Cash** or **Card**.
*   **Item Breakdown**: Expand any order to see exactly which items were purchased, their individual prices, and quantities at the time of sale.
*   **Smart Querying**: Uses advanced SQL joins to fetch item names and payment types efficiently in a single query.

---

## 💡 Potential Enhancements

Beyond the core functionality, these features would add significant value to the daily operations:

### **1. Partial Payments (Split Tender)**
*   **Use Case**: A group of friends wants to split the bill, or a customer wants to pay £10 in Cash and the rest by Card.
*   **Implementation**: Update the Checkout Dialog to accept multiple payment entries for a single `order_id` until the `total_paid` equals the `total_amount`.

### **2. Tips & Gratuity**
*   **Use Case**: Rewarding staff for good service.
*   **Implementation**: Add a "Add Tip" step before payment finalization.
    *   **Fixed Amount**: User types a fixed amount, e.g., `£2.00`.
    *   **Percentage**: User types a percentage, e.g., `10%`, `15%`, `20%`.

### **3. Discounts & Coupons**
*   **Use Case**: Promotional campaigns or staff meals.
*   **Implementation**:
    *   **Fixed Discount**: User enters a fixed amount, e.g., `£5.00`.
    *   **Percentage Discount**: User enters a percentage, e.g., `10%`, `15%`, `20%`.
    *   **Logic**: Calculate tax, taking discounts into account, as per local laws.

### **4. Table Management (Dine-In)**
*   **Use Case**: Sit-down restaurants.
*   **Implementation**: Assign orders to specific Tables (e.g., "Table 5"). Allow "Save Order" to put it on hold while guests dine, then "Retrieve" to pay later.

### **5. Customer CRM & Loyalty**
*   **Use Case**: Building repeat business.
*   **Implementation**: Link orders to a specific Customer Profile to track purchase history and award Loyalty Points (e.g., "Buy 10 Coffees, Get 1 Free").

---

## 🔮 Roadmap to Production

To transform this demo into a real-world enterprise POS solution, the following steps are recommended:

### **1. Cloud Synchronization**
*   **Objective**: Enable multi-device support.
*   **Plan**: Implement a background sync service to push local SQLite data to a central cloud server (e.g., PostgreSQL/Firebase).

### **2. User Authentication & Roles**
*   **Objective**: Security and Audit.
*   **Plan**: Add Login screens for Cashiers.

### **3. Receipt Printing**
*   **Objective**: Compliance and Customer Service.
*   **Plan**: Integrate with thermal printers to auto-print receipts upon successful checkout.

### **4. Inventory Management**
*   **Objective**: Stock control.
*   **Plan**: To update latest `items` stock counts. Prevent item sales if stock is zero.