# Amazon Brazil E‑Commerce SQL Analytics for the Indian Market

This project analyzes Amazon Brazil’s e‑commerce data to uncover patterns in customer behavior, product performance, logistics, and payment preferences that can inform strategy for Amazon India. It uses **advanced SQL** on a transactional dataset (customers, orders, order items, products, sellers, payments, geolocation) to answer real business questions around revenue, loyalty, and seasonal trends. [web:37][web:41]

---


## 📌 Business Goal

Leverage insights from Amazon Brazil’s marketplace to identify:

- Customer segments and purchasing behavior that are most valuable or fast‑growing.
- Product categories and price bands that drive revenue and repeat purchases.
- Regional and geolocation patterns that highlight customer density and delivery challenges.
- Payment preferences and ticket sizes that can guide payment partnerships and promotions.

These findings can help Amazon India enhance customer experience, tailor offers, and seize new growth opportunities. [web:37][web:41]

---
## Import CSV data into tables using pgAdmin 4

Follow these steps for each table (`customers`, `orders`, `order_items`, `products`, `payments`):

1. In the left tree of **pgAdmin 4**, navigate to:

   `Databases → amazon_analysis → Schemas → amazon_brazil → Tables`

2. Right‑click the target table (for example, `customers`) and select **Import/Export Data**.

3. In the **Import/Export Data** dialog:

   - **Import/Export**: `Import`
   - **Format**: `CSV`
   - **File name**: browse and select the matching CSV file  
     (for example, `customers.csv`)
   - **Encoding**: leave the default (usually `UTF8`)
   - **Header**: check this if the first row of the CSV contains column names
   - **Delimiter**: `,` (comma)

4. Click **OK** to start the import.

5. Repeat the same process for the remaining tables:

   - `amazon_brazil.orders`        ← `orders.csv`
   - `amazon_brazil.order_items`   ← `order_items.csv`
   - `amazon_brazil.products`      ← `products.csv`
   - `amazon_brazil.payments`      ← `payments.csv`


## 🗂 Dataset & Schema Overview

The schema consists of seven interconnected tables representing the Amazon Brazil marketplace:

- **Customers**  
  Holds customer identifiers and location attributes (state, city, zip code prefix). Used to study customer demographics, density, and behavioral cohorts.

- **Orders**  
  Captures the full order lifecycle: timestamps (purchase, approval, shipping, delivery), order status, and customer linkage. Key for lead times, delays, and churn risk.

- **Order Items**  
  Line‑item detail for each order: product, seller, price, freight value, shipping limits. Core for revenue, basket size, and unit economics.

- **Products**  
  Product metadata such as category, name, dimensions, and weight. Enables category‑level performance, pricing ranges, and assortment decisions.

- **Sellers**  
  Seller identifiers and locations. Used to measure seller performance, regional seller coverage, and fulfillment efficiency.

- **Payments**  
  Transaction‑level data: payment type, number of installments, payment value. Foundation for understanding payment preferences, ticket sizes, and credit exposure.

- **Geolocation**  
  Maps zip code prefixes to latitude/longitude, city, state. Supports regional demand analysis, customer density mapping, and logistics planning. [web:37]

---

## 🔍 Analysis Dimensions

### 1️⃣ Customer Demographics & Behavior (Customers + Orders)

Using the **Customers** table joined to **Orders**, the analysis focuses on:

- Customer location patterns (state, city) to identify high‑value and high‑density regions.
- Order frequency per customer to build loyalty segments (New, Returning, Loyal).
- Average order value and order count per customer to prioritize high‑value cohorts for Amazon India’s loyalty strategies. [web:37][web:41]

### 2️⃣ Regional Trends & Density (Geolocation)

With the **Geolocation** table:

- Aggregate customers, orders, and revenue by state/city to find demand hotspots.
- Identify under‑served but growing regions where logistics and seller acquisition could be prioritized.
- Use location granularity (zip code prefixes) to map micro‑markets, similar to pin‑code level planning in India. [web:37]

### 3️⃣ Order Lifecycle & Delivery Performance (Orders)

From the **Orders** table:

- Measure time between purchase, approval, shipping, and delivery to compute:
  - Average delivery time.
  - Late delivery rate vs. promised date.
  - Cancellations and “unavailable” status by region and season.
- Derive insights on operational bottlenecks that would matter for Amazon India’s SLA design. [web:37]

### 4️⃣ Product Performance & Basket Structure (Order Items + Products)

Joining **Order Items** with **Products** enables:

- Revenue, order count, and quantity sold by product category.
- Price and freight ranges by category (min, max, median) to identify:
  - Premium vs. mass‑market categories.
  - Categories with high shipping cost sensitivity.
- Basket composition: number of items per order and typical price bands. [web:37][web:41]

### 5️⃣ Seller Performance & Coverage (Order Items + Sellers)

Using **Sellers** plus **Order Items**:

- Seller‑level metrics: total revenue, order count, average rating proxies (if available), and return/cancellation rates.
- Regional seller coverage: number of active sellers per state/city vs. customer demand.
- Identification of “key” sellers that dominate certain categories or regions, informing potential partnerships in India. [web:37]

### 6️⃣ Payment Preferences & Ticket Size (Payments)

With the **Payments** table (joined to **Orders**):

- Distribution of payment types (credit card, debit card, boleto, vouchers, etc.).
- Average order value and installments per payment type to see:
  - Which methods dominate high‑value vs. low‑value transactions.
  - How installment behavior affects overall payment mix.
- Time‑based analysis of payment mix shifts, useful to anticipate similar trends in the Indian context (UPI, cards, BNPL). [web:37][web:41]

---

## 🧠 SQL Skills Practiced

### 1. Core SQL & Aggregations

The project reinforces core SQL on a realistic e‑commerce schema:

- Filtering using `WHERE`, `BETWEEN`, `LIKE`, `IN`, `IS NULL` on large transactional tables.
- Aggregations using `GROUP BY` and `ORDER BY` to compute:
  - Total revenue, total orders, total customers.
  - Average payment values, price ranges, freight costs.
- `HAVING` to filter groups, e.g.:
  - Product categories where `MAX(price) - MIN(price)` exceeds a threshold.
  - Products with quantity sold above the overall average.
- Numeric transforms like `ROUND`, `CAST`, and percentage calculations for:
  - Payment mix.
  - Order share by state or payment method. [web:41]

### 2. Joins & Multi‑Table Business Questions

You combine multiple tables to answer end‑to‑end questions:

- Inner joins across **orders**, **order_items**, **payments**, **products**, **customers** to analyze:
  - Revenue and margin by customer segment, category, and region.
  - Shipping cost structure and its impact on profitability.
- Category‑level insights by joining product metadata with order line items:
  - Top‑performing categories by revenue and units.
  - High‑return or high‑cancellation categories.
- Data quality checks: spotting missing or suspicious `product_category_name` via joins and filters. [web:37][web:41]

### 3. Segmentation & CASE Logic

Using `CASE` you transform raw metrics into business‑friendly segments:

- **Order value bands**  
  Categorize orders as Low / Medium / High value and study which payment types dominate each band.

- **Customer segmentation**  
  Group customers by order count:
  - New (1 order), Returning (2–4 orders), Loyal (5+ orders), or any similar segmentation.
  - Useful for designing loyalty programs and targeted campaigns.

- **Seasonality mapping**  
  Map months to seasons (Spring, Summer, Autumn, Winter) to:
  - Compare seasonal sales patterns.
  - Identify high‑demand seasons for specific categories or payment methods. [web:37][web:41]

### 4. Subqueries, Temp Tables & CTEs

To keep the analysis modular and readable:

- **Scalar subqueries & derived tables**  
  Compute global benchmarks, e.g.:
  - Overall average quantity per product.
  - Overall order count, then compare each segment against these baselines.

- **Temporary tables**  
  Persist intermediate results:
  - `customer_categories` or `customer_segments` for reporting and reuse.
  - Pre‑aggregated category‑level revenue tables.

- **Common Table Expressions (CTEs)**  
  Break complex logic into steps, such as:
  - `customer_orders` → `customer_segments` for frequency‑based segmentation.
  - `monthly_sales` CTEs for seasonal charts and time‑series analysis. [web:41]

### 5. Window Functions, Ranking & Time‑Series

The project also uses analytical SQL patterns:

- **Ranking**  
  `RANK() OVER (ORDER BY avg_order_value DESC)` to find top N high‑value customers or sellers.

- **LAG & MOM change**  
  `LAG()` to compute month‑over‑month change in:
  - Sales per payment type.
  - Orders per category or region.

- **Recursive CTEs**  
  Build cumulative metrics, e.g.:
  - Monthly cumulative sales per product from its first sale.
  - Lifecycle curves to identify rising vs. saturated products.

- **Time‑series grouping**  
  Using functions like `EXTRACT`, `DATE_TRUNC`, `TO_CHAR` (or SQLite/PostgreSQL equivalents) to:
  - Analyze revenue by year, month, season.
  - Export aggregated data for Excel/Power BI/Tableau dashboards.
