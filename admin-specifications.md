This is a comprehensive UI/UX specification for the Admin Panel. It is designed to be **Mobile-First** (responsive) using a clean, modern aesthetic

### Responsive Navigation Structure

#### **A. Desktop Layout (> 1024px)**

- **Sidebar (Left, Fixed, 280px):**
  - **Header:** App Logo + "Utpanna Admin".
  - **Nav Items:**
    1.  Dashboard (Icon: Grid/Home)
    2.  Group Deals (Icon: Percent/Tag)
    3.  Products & Alternatives (Icon: Box/Inventory)
    4.  Crops Combo (Icon: Sprout/Leaf)
    5.  Users (Icon: People)
  - **Footer:** Admin Profile + Logout.
- **Main Content:** Scrollable area to the right.

#### **B. Mobile Layout (< 1024px)**

- **App Bar (Top, Sticky):**
  - **Left:** Hamburger Menu Icon (`Menu`).
  - **Center:** Current Page Title.
  - **Right:** Notification Bell / Profile Avatar.
- **Navigation Drawer:** Slides in from the left when Hamburger is clicked (contains same items as Desktop Sidebar).
- **Main Content:** Full width, scrollable.

---

## 2. Screen-by-Screen UI Specifications

### Screen 1: Dashboard

**Route:** `/admin/dashboard`
**Goal:** High-level overview of system health.

- **Top Section (Stats Cards - Grid Layout):**
  - **Card 1:** Total Crops (Count) | Icon: Leaf
  - **Card 2:** Total Products (Count) | Icon: Box
  - **Card 3:** Active Deals (Count) | Icon: Tag | _Color: Green bg_
  - **Card 4:** Registered Farmers (Count) | Icon: Users
- **Middle Section (Quick Actions):**
  - Button: "Create New Deal" (Shortcuts to Recommendations)
  - Button: "Add Product"

---

### Screen 2: Products & Alternatives

**Route:** `/admin/products`
**Goal:** Manage the `products` collection.

#### **Layout:**

- **Header:** Title "Products" + Search Bar ("Search by name, category...") + Filter Icon (Filter by Category).
- **Action:** Floating Action Button (FAB) `+` on Mobile; "Add Product" Button (Top Right) on Desktop.

#### **View Mode:**

- **Desktop:** Data Table.
  - Columns: Image (Thumbnail), Name, Category, Price, MRP, Deal Active?, Actions (Edit/Delete).
- **Mobile:** Product Cards (Vertical List).
  - **Card Layout:**
    - Left: Image Thumbnail (60x60).
    - Middle: Name (Bold), Category (Small grey), Price (`₹500` - `MRP ₹600`).
    - Right: Kebab Menu (`MoreVert`) for Edit/Delete.
    - _Visual Indicator:_ If `activeDealId` exists, show a small "🔥 Deal" badge on the card.

#### **Add/Edit Product (Modal/Drawer):**

- **Section 1: Basic Info**
  - Input: Product Name.
  - Dropdown: Category (Fertilizer, Insecticide, etc.).
  - Input: Unit (e.g., "1 L").
- **Section 2: Pricing**
  - Input: MRP (Number).
  - Input: Selling Price (Number). _Validation: Price <= MRP._
- **Section 3: Media**
  - Upload Box: "Click to upload image" (Preview shown).
- **Section 4: Deal Configuration**
  - Toggle Switch: "Active Individual Deal?"
  - If ON: Show generated `activeDealId` (Read-only) + optional "Deal Text" input.

---

### Screen 3: Crops Combo (Master Management)

**Route:** `/admin/crops-combo`
**Goal:** Manage `crops`, `objectives`, and link them via `recommendations`.

#### **UX Strategy:**

Use a **Tabbed Interface** at the top.

#### **Tab 1: Crops Master**

- **List:** Grid of Cards. Each card shows Crop Image + Name (Marathi/English).
- **Action:** Add Crop.
- **Form:** Name Input + Image Upload.

#### **Tab 2: Objectives Master**

- **List:** Simple List view. Name of Objective.
- **Action:** Add Objective.

#### **Tab 3: Recommendations (The Builder)**

- **Layout:**

  - **Step 1 (Filters):** Two Dropdowns at the top.
    1.  Select Crop (e.g., Cotton)
    2.  Select Objective (e.g., Growth)
  - **Result Area:**
    - **Empty State:** "No recommendation exists. [Create Recommendation Button]"
    - **Active State:** Display the "Combo Card".

- **The Recommendation Editor (Form):**
  - **Header:** Crop & Objective (Read-only).
  - **Field:** Combo Title (e.g., "Cotton Growth Booster").
  - **Field:** Deal ID (Auto-generated `deal_x`, Read-only).
  - **Items List (Dynamic):**
    - _Row:_ Product Dropdown (Searchable) | Qty/Acre | Qty/Pump | Remove (X) Icon.
    - _Button:_ "+ Add Another Product".
  - **Footer:** "Save Recommendation".

---

### Screen 4: Group Deals

**Route:** `/admin/deals`
**Goal:** A centralized view of all "Active Deals" (derived from Recommendations).

- **Layout:**
- **List View (Cards):**
  - Deal related screns are Already creatad

---

### Screen 5: Users

**Route:** `/admin/users`
**Goal:** View registered farmers.

- **Desktop:** Data Table (Name, Phone, Village, Registered Date).
- **Mobile:** List Tiles (Avatar + Name + Phone).
- **Search:** Search by Phone Number.

---

## 3. User Flows (End-to-End Operations)

### Flow A: Adding a New Product to the Catalogue

1.  Admin opens sidebar -> Clicks **Products & Alternatives**.
2.  Clicks **+ Add Product**.
3.  Fills form:
    - Name: "Humic Acid 98%"
    - Category: "Growth Promoter"
    - MRP: 600, Price: 450
    - Uploads Image.
4.  Clicks **Save**.
5.  System generates ID `p_105`, saves to Firestore `products` collection.
6.  User is returned to list; Toast message: "Product Added".

### Flow B: Creating a "Chana Growth" Recommendation (The 'Combo')

1.  Admin opens sidebar -> Clicks **Crops Combo**.
2.  Selects **Tab 3: Recommendations**.
3.  **Dropdown 1:** Selects "Chana" (If missing, goes to Tab 1 to create it).
4.  **Dropdown 2:** Selects "Vegetative Growth".
5.  System shows Empty State. Admin clicks **Create Recommendation**.
6.  **Inputs:**
    - Combo Title: "Super Chana Branching Kit".
    - **Item 1:** Selects "Humic Acid" (created in Flow A). Sets Qty Acre: 1L.
    - **Item 2:** Selects "19:19:19". Sets Qty Acre: 2kg.
7.  Clicks **Save**.
8.  System creates doc in `recommendations` collection with auto-generated `dealId`.

---

Here is the refined specification for the **Products & Alternatives** module. This design allows the Admin to manage the main product and its lower-cost alternatives within a single context.

---

# Module: Products & Alternatives Management

## 1. Data Model Structure

We will use two collections (or a root collection and a sub-collection) to maintain the relationship.

### A. Main Product (`products` collection)

**Document Structure:**

```json
{
  "id": "p_101", // Auto-generated
  "title": "Azospirillum Bio-Fertilizer",
  "activeIngredient": "Azospirillum lipoferum",
  "chemicalComposition": "Count: 1x10^8 CFU/ml",
  "modeOfAction": "Nitrogen fixation",
  "usedFor": "Root development, Nitrogen supply",
  "usageDirection": "Mix 250ml with seeds",
  "price": 620, // Number
  "savings": 90, // Number (Discount or saved amount)
  "imageUrls": ["url1.jpg", "url2.jpg"],
  "createdAt": "2025-11-27T17:24:54Z" // Timestamp
}
```

### B. Alternatives (`alternatives` collection)

_Note: These act as the "Foreign Key" linked items. They share the same schema but include a reference to the parent._

**Document Structure:**

```json
{
  "id": "alt_505", // Auto-generated
  "parentProductId": "p_101", // FOREIGN KEY link to Main Product
  "title": "Generic Azos (Local)",
  "activeIngredient": "Azospirillum lipoferum",
  "chemicalComposition": "Count: 1x10^8 CFU/ml",
  "modeOfAction": "Nitrogen fixation",
  "usedFor": "Root development",
  "usageDirection": "Mix 250ml with seeds",
  "price": 450, // Lower price
  "savings": 260, // Higher savings
  "imageUrls": ["alt_url1.jpg"],
  "createdAt": "Timestamp"
}
```

---

## 2. Admin UI Specifications

### Screen: Product List (Dashboard View)

**Goal:** View main products and quickly identify which have alternatives configured.

- **View:** Table (Desktop) / Card List (Mobile).
- **Columns/Fields:**
  - Thumbnail Image.
  - **Title** (e.g., "Azospirillum Bio-Fertilizer").
  - **Price** (e.g., ₹620).
  - **Alternatives Count:** Badge showing number of linked alternatives (e.g., `2 Alts`).
  - **Actions:** Edit (Pencil Icon), Delete.

---

### Screen: Add / Edit Product (The Master Form)

**Goal:** A single screen to create the Main Product AND add its Alternatives immediately.

#### **Layout Structure**

This screen is divided into two main tabs or vertical sections.

#### **Section 1: Main Product Details**

- **Images:** Horizontal scrollable list with "+ Add Image" box.
- **Basic Info:**
  - `Title` (Text Input)
  - `Active Ingredient` (Text Input)
  - `Chemical Composition` (Text Input)
- **Technical Info:**
  - `Mode of Action` (Text Area)
  - `Used For` (Text Area)
  - `Usage Direction` (Text Area)
- **Pricing:**
  - `Price` (Number Input) - e.g., 620
  - `Savings` (Number Input) - e.g., 90

#### **Section 2: Alternatives Configuration**

- **Header:** "Cheaper Alternatives / Substitutes"
- **List Area:** Shows currently added alternatives for this product (Title + Price).
- **Action:** Button **[+ Add Alternative]**.

---

### Modal / Drawer: "Add Alternative"

_Triggered when clicking [+ Add Alternative] in Section 2._

**Behavior:**

1.  Opens an overlay (Desktop) or full-screen bottom sheet (Mobile).
2.  **Form Fields:** (Same schema as Main Product).
    - _Auto-Fill Button:_ "Copy details from Main Product?" (Useful since Chemical Composition/Usage often remains the same).
    - `Title` (e.g., "Generic Brand X").
    - `Price` (Validation: Should ideally be lower than Main Product Price).
    - `Savings` (Calculation suggestion: Main Price - Alt Price? Or manual input).
    - `Image Upload`.
3.  **Footer Actions:** "Save Alternative".

**Backend Logic on Save:**

- Creates a document in `alternatives` collection.
- Sets `parentProductId` to the ID of the Main Product currently being edited.

---

## 3. User Flow (Admin Operation)

1.  **Start:** Admin clicks "Products" in Sidebar.
2.  **Create:** Clicks "Add Product".
3.  **Fill Main:** Admin enters details for "Azospirillum Bio-Fertilizer" (Price: 620).
4.  **Add Alt:** Admin scrolls down and clicks **[+ Add Alternative]**.
5.  **Fill Alt:**
    - Modal opens.
    - Admin clicks "Copy from Main" (fills chem composition, etc.).
    - Admin changes Title to "Local Azos".
    - Admin changes Price to 450.
    - Admin uploads image of Local Azos.
    - Clicks "Save Alternative".
6.  **Review:** The Main Product form now lists "Local Azos - ₹450" in the Alternatives section.
7.  **Final Commit:** Admin clicks "Save Product".
    - _System Action:_ Saves Main Product to `products`.
    - _System Action:_ If the product is new, it updates the `parentProductId` of the created alternative with the new Main Product ID.

## 4. Mobile Responsiveness Details

- **Mobile View:**
  - The "Alternatives" section acts as an accordion (Collapsible).
  - The "Add Alternative" form opens as a full-screen page to avoid keyboard overlay issues.
- **Visual Cues:**
  - Use a different background color (e.g., faint green) for the Main Product section and a faint grey for the Alternatives section to visually distinguish hierarchy.

## 4. Technical Nuances for Developer

- **Validation Logic:** Ensure the "Save" button in the Recommendation builder is disabled if the `items` array is empty.
- **Dropdowns:** Product dropdowns in the Recommendation builder must be "Searchable Dropdowns" (Autocomplete) because the product list might grow large.
- **Image Handling:** Use a standard Placeholder image if the asset/URL fails to load.
- **Delete Protections:**
  - If Admin tries to delete "Humic Acid" from Products page:
  - _Check:_ Query `recommendations` where `items.productId` == `p_105`.
  - _If Result > 0:_ Show Alert "Cannot delete. This product is used in 'Super Chana Branching Kit'. Remove it from the combo first."
  - _If Result == 0:_ Allow Delete.

## 5. Mobile Responsiveness Checklist

1.  **Tables:** Convert to "Card Lists" on screens < 768px.
2.  **Modals:** Use full-screen dialogs on mobile; Centered popups on desktop.
3.  **Touch Targets:** Ensure all buttons and icons are at least 44x44px.
4.  **Sidebar:** Hidden by default on mobile, triggered by Hamburger menu.
