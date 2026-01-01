# Zepto Supply Chain Inventory Analysis

### Project Overview

This project is an educational supply chain analytics initiative designed to demonstrate how advanced SQL analysis identifies inventory inefficiencies, quantifies financial risks, and generates actionable optimization recommendations. The analysis examines 3,732 products from Zepto's publicly available product catalog across multiple retail categories.

- Project Type: Educational Portfolio Project
- Purpose: Learning advanced SQL, supply chain analytics, and business intelligence
- Suitable For: Entry-level data analyst positions, supply chain roles, analytics interviews
Learning Level: Intermediate SQL, business analytics fundamentals

### Data Attribution

Dataset: Zepto Inventory Dataset palvinder2006 (Kaggle)

File Used: zepto_v2.csv

Project Purpose: Educational and Portfolio Development

### Dataset Information
Scale and Content

- Total Products Analyzed: 3,732 product SKUs (Stock Keeping Units)
- Product Categories: 7-15 retail categories including:
- Fruits & Vegetables
- Dairy & Milk Products
- Packaged Foods
- Beverages
- Electronics & Appliances
- Miscellaneous

### Product Attributes
- Product ID (unique identifier)
- Category (product classification)
- Product Name
- MRP (Maximum Retail Price)
- Discount Percentage
- Available Quantity in Stock
- Discounted Selling Price
- Weight in Grams
- Out of Stock Status

### Why This Dataset?
Zepto is a high-growth 10-minute grocery delivery platform. This dataset is:
- Realistic: Real product catalog from operating platform
- Substantial: 3,700+ products provides meaningful scale
- Business Relevant: Supply chain efficiency is critical
- Well-maintained: High usability rating on Kaggle

### Key findings:

Overall inventory health
- A noticeable share of products are out of stock, showing real stockout risk.
- Average stock per product is very low, meaning the system runs with almost no safety buffer.

Category performance
- Cooking Essentials and Munchies show the worst stockout problems among all categories.
- Some other categories are relatively stable, with lower stockout and more balanced stock.

Working capital and overstock
- A large amount of money is tied up in inventory, heavily concentrated in a small set of products and categories.
- Certain products and categories have clear overstock risk, while others are starved of inventory.

Price segment behaviour
- The catalog is dominated by higher‑priced “luxury” items, with almost no budget or mid‑range products.
- Even in this premium segment, stockouts are common, which is risky because premium customers expect high availability.

Weight‑based patterns
- Heavier and bulk products (especially above 500g and 1kg) have higher stockout rates than lighter products.
- This suggests structural supply chain issues for bulk items, like lead times, storage, or logistics constraints.

Discount strategy
- High discounts do not consistently reduce inventory levels compared to low discounts.
- This means price cuts alone are not enough to move stock; demand is driven more by need and availability than by discount.

Risk and opportunity
- There is clear revenue lost because popular products are frequently out of stock.
- At the same time, there is big opportunity to free working capital by acting on overstocked, slow‑moving items.

Recommended actions
- Increase safety stock and improve forecasting for critical categories like Cooking Essentials and Munchies.
- Treat heavy and bulk items with a separate inventory strategy due to their higher risk.
- Shift focus from random discounting to targeted actions on truly overstocked SKUs.
- Build an ongoing monitoring dashboard so leadership can track stockouts, overstock, and category health regularly.

### Project Learning Objectives
Educational Purpose

This project teaches:

SQL Fundamentals:
- Database schema design and optimization
- Creating summary tables with calculated metrics
- Complex query construction
- Conditional logic with CASE statements
- Aggregate functions with filtering

Advanced SQL Techniques:
- Feature engineering (calculated business metrics)
- Conditional aggregation using FILTER clause
- GROUP BY analysis across categories
- Subqueries for percentage calculations
- UNION ALL for combining multiple datasets
- ORDER BY for result prioritization

Business Analytics:
- Translating business questions into SQL queries
- Financial impact quantification
- KPI calculation and reporting
- Prioritization by business importance
- Converting data analysis into actionable recommendations

Supply Chain Concepts:
- Working capital and inventory management
- Stockout costs (revenue loss, customer impact)
- Overstock risk (capital efficiency)
- Category-specific optimization strategies
- Supply chain performance metrics






