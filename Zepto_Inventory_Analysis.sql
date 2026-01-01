
-- ZEPTO SUPPLY CHAIN INVENTORY ANALYSIS
-- Educational Supply Chain Analytics Project

-- Data Attribution
-- Dataset Source: Zepto Inventory Dataset (Kaggle)
-- Dataset : palvinder2006
-- Project Purpose: Educational and Portfolio Development

-- This project analyzes 3,732 products from Zepto's inventory to identify supply chain inefficiencies, stockout risks, and cash optimization opportunities using advanced SQL analysis techniques.


-- DATABASE SETUP



CREATE DATABASE IF NOT EXISTS zepto_supply_chain;
USE zepto_supply_chain;

CREATE TABLE IF NOT EXISTS zepto_inventory (
    product_id SERIAL PRIMARY KEY,
    category VARCHAR(100),
    product_name VARCHAR(255),
    mrp NUMERIC(10,2),
    discount_percent NUMERIC(5,2),
    available_quantity INTEGER,
    discounted_selling_price NUMERIC(10,2),
    weight_in_grams INTEGER,
    out_of_stock BOOLEAN,
    quantity INTEGER
);


-- Q: How do we transform raw inventory data into business-valuable metrics?

DROP TABLE IF EXISTS zepto_summary;

CREATE TABLE zepto_summary AS
SELECT
    product_id,
    category,
    name AS product_name,
    mrp,
    discount_percent,
    available_quantity,
    discounted_selling_price,
    weight_in_gms AS weight_in_grams,
    out_of_stock,
    quantity,
    ROUND(discounted_selling_price * available_quantity, 2) AS inventory_value_rupees,
    ROUND(discounted_selling_price * available_quantity * 0.65, 2) AS estimated_revenue_rupees,
    CASE
        WHEN out_of_stock = TRUE THEN 'OUT_OF_STOCK'
        WHEN available_quantity < 5 THEN 'CRITICAL_LOW'
        WHEN available_quantity < 20 THEN 'LOW_STOCK'
        WHEN available_quantity <= 100 THEN 'MEDIUM_STOCK'
        WHEN available_quantity <= 500 THEN 'HIGH_STOCK'
        ELSE 'EXCESS_STOCK'
    END AS stock_status,
    CASE
        WHEN available_quantity > 200 THEN 'VERY_HIGH_RISK'
        WHEN available_quantity > 100 THEN 'HIGH_RISK'
        WHEN available_quantity > 50 THEN 'MEDIUM_RISK'
        ELSE 'LOW_RISK'
    END AS overstock_risk,
    CASE
        WHEN weight_in_gms > 0 THEN ROUND(discounted_selling_price * 1000.0 / weight_in_gms, 2)
        ELSE NULL
    END AS price_per_kg
FROM zepto_inventory;

SELECT COUNT(*) AS total_products_loaded FROM zepto_summary;


-- QUESTION 1: WORKING CAPITAL AND STOCKOUT ANALYSIS BY CATEGORY


SELECT
    category,
    COUNT(*) AS total_products,
    COUNT(*) FILTER (WHERE stock_status = 'OUT_OF_STOCK') AS out_of_stock_items,
    COUNT(*) FILTER (WHERE stock_status = 'CRITICAL_LOW') AS critical_low_items,
    COUNT(*) FILTER (WHERE stock_status = 'LOW_STOCK') AS low_stock_items,
    COUNT(*) FILTER (WHERE stock_status IN ('MEDIUM_STOCK','HIGH_STOCK','EXCESS_STOCK')) AS ok_or_high_stock,
    ROUND(SUM(inventory_value_rupees), 2) AS total_inventory_value_rupees,
    ROUND(AVG(inventory_value_rupees), 2) AS avg_product_value_rupees,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE stock_status = 'OUT_OF_STOCK') / COUNT(*),
        2
    ) AS stockout_rate_pct
FROM zepto_summary
GROUP BY category
ORDER BY total_inventory_value_rupees DESC, stockout_rate_pct DESC;

-- QUESTION 2: TOP PRODUCTS BY INVENTORY VALUE AND STOCK STATUS


SELECT
    product_name,
    category,
    available_quantity,
    discounted_selling_price,
    inventory_value_rupees,
    stock_status,
    overstock_risk,
    ROUND(
        100.0 * inventory_value_rupees /
        (SELECT SUM(inventory_value_rupees) FROM zepto_summary),
        3
    ) AS pct_of_total_inventory_value
FROM zepto_summary
ORDER BY inventory_value_rupees DESC
LIMIT 30;

-- QUESTION 3: DISCOUNT STRATEGY EFFECTIVENESS AND INVENTORY DYNAMICS


SELECT
    category,
    ROUND(AVG(discount_percent) FILTER (WHERE available_quantity > 100), 2) AS avg_discount_when_high_qty,
    ROUND(AVG(available_quantity) FILTER (WHERE discount_percent >= 20), 0) AS avg_qty_with_high_discount,
    ROUND(AVG(available_quantity) FILTER (WHERE discount_percent < 10), 0) AS avg_qty_with_low_discount,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE stock_status IN ('OUT_OF_STOCK', 'CRITICAL_LOW')) / COUNT(*),
        2
    ) AS stockout_rate_pct,
    CASE
        WHEN ROUND(AVG(available_quantity) FILTER (WHERE discount_percent >= 20), 0) <
             ROUND(AVG(available_quantity) FILTER (WHERE discount_percent < 10), 0)
        THEN 'DISCOUNTING_WORKS'
        ELSE 'DISCOUNTING_NOT_WORKING'
    END AS effectiveness
FROM zepto_summary
GROUP BY category
ORDER BY category;

-- QUESTION 4: OVERSTOCK RISK AND EXCESS INVENTORY QUANTIFICATION


SELECT
    overstock_risk,
    COUNT(*) AS product_count,
    ROUND(SUM(available_quantity), 0) AS total_units,
    ROUND(SUM(inventory_value_rupees), 2) AS cash_tied_up_rupees,
    ROUND(AVG(inventory_value_rupees), 2) AS avg_per_product,
    ROUND(
        100.0 * SUM(inventory_value_rupees) /
        (SELECT SUM(inventory_value_rupees) FROM zepto_summary),
        2
    ) AS pct_of_total_inventory_value
FROM zepto_summary
GROUP BY overstock_risk
ORDER BY cash_tied_up_rupees DESC;

-- QUESTION 5: CATEGORY HEALTH SCORECARD AND PERFORMANCE ASSESSMENT

SELECT
    category,
    COUNT(*) AS total_products,
    COUNT(*) FILTER (WHERE stock_status = 'OUT_OF_STOCK') AS stockout_count,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE stock_status = 'OUT_OF_STOCK') / COUNT(*),
        2
    ) AS stockout_rate_pct,
    ROUND(SUM(inventory_value_rupees), 2) AS total_inventory_value,
    ROUND(AVG(inventory_value_rupees), 2) AS avg_product_value,
    COUNT(*) FILTER (WHERE overstock_risk IN ('HIGH_RISK', 'VERY_HIGH_RISK')) AS overstock_risk_count,
    CASE
        WHEN COUNT(*) FILTER (WHERE stock_status = 'OUT_OF_STOCK')::float / COUNT(*) > 0.15 THEN 'CRITICAL'
        WHEN SUM(inventory_value_rupees) > 3000000 THEN 'WARNING'
        WHEN COUNT(*) FILTER (WHERE stock_status = 'OUT_OF_STOCK')::float / COUNT(*) > 0.05 THEN 'CAUTION'
        ELSE 'HEALTHY'
    END AS category_status
FROM zepto_summary
GROUP BY category
ORDER BY stockout_rate_pct DESC, total_inventory_value DESC;


-- QUESTION 6: REVENUE IMPACT OF STOCKOUTS AND FINANCIAL OPPORTUNITY


SELECT
    category,
    COUNT(*) FILTER (WHERE stock_status = 'OUT_OF_STOCK') AS out_of_stock_items,
    ROUND(
        AVG(CASE WHEN stock_status = 'OUT_OF_STOCK' THEN estimated_revenue_rupees ELSE 0 END) *
        COUNT(*) FILTER (WHERE stock_status = 'OUT_OF_STOCK'),
        2
    ) AS estimated_daily_revenue_loss_rupees,
    ROUND(
        AVG(CASE WHEN stock_status = 'OUT_OF_STOCK' THEN estimated_revenue_rupees ELSE 0 END) *
        COUNT(*) FILTER (WHERE stock_status = 'OUT_OF_STOCK') * 365,
        2
    ) AS estimated_annual_revenue_loss_rupees,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE stock_status = 'OUT_OF_STOCK') / COUNT(*),
        2
    ) AS stockout_rate_pct
FROM zepto_summary
GROUP BY category
ORDER BY estimated_annual_revenue_loss_rupees DESC;


-- QUESTION 7: EXECUTIVE SUMMARY DASHBOARD - KEY PERFORMANCE INDICATORS


SELECT
    'INVENTORY_HEALTH' AS metric_category,
    COUNT(*) AS total_products,
    ROUND(SUM(inventory_value_rupees), 2) AS total_inventory_value_rupees,
    ROUND(AVG(inventory_value_rupees), 2) AS avg_product_value_rupees,
    SUM(available_quantity) AS total_units_in_stock,
    ROUND(AVG(available_quantity), 1) AS avg_units_per_product,
    COUNT(*) FILTER (WHERE stock_status = 'OUT_OF_STOCK') AS total_out_of_stock_products,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE stock_status = 'OUT_OF_STOCK') / COUNT(*),
        2
    ) AS overall_stockout_rate_pct,
    COUNT(*) FILTER (WHERE overstock_risk IN ('HIGH_RISK', 'VERY_HIGH_RISK')) AS high_risk_overstock_products,
    COUNT(DISTINCT category) AS total_categories
FROM zepto_summary;


-- QUESTION 8: PRIORITIZED ACTION ITEMS BY BUSINESS IMPACT


SELECT 'EMERGENCY_RESTOCK' AS action_type,
    COUNT(*) AS item_count,
    ROUND(SUM(estimated_revenue_rupees), 2) AS business_impact_rupees,
    'RESTOCK IMMEDIATELY - PREVENT REVENUE LOSS' AS reason
FROM zepto_summary
WHERE stock_status IN ('OUT_OF_STOCK', 'CRITICAL_LOW')

UNION ALL

SELECT 'URGENT_DISCOUNT' AS action_type,
    COUNT(*) AS item_count,
    ROUND(SUM(inventory_value_rupees), 2) AS business_impact_rupees,
    'AGGRESSIVE PRICING - FREE WORKING CAPITAL' AS reason
FROM zepto_summary
WHERE available_quantity > 150
  AND discount_percent < 10
  AND overstock_risk IN ('HIGH_RISK', 'VERY_HIGH_RISK')

UNION ALL

SELECT 'MONITOR' AS action_type,
    COUNT(*) AS item_count,
    ROUND(SUM(inventory_value_rupees), 2) AS business_impact_rupees,
    'NORMAL OPERATION - NO IMMEDIATE ACTION' AS reason
FROM zepto_summary
WHERE stock_status = 'MEDIUM_STOCK'
  AND overstock_risk = 'LOW_RISK'
ORDER BY business_impact_rupees DESC;

-- QUESTION 9: INVENTORY PATTERNS BY PRODUCT WEIGHT


SELECT
    CASE
        WHEN weight_in_grams < 250 THEN 'LIGHT (<250g)'
        WHEN weight_in_grams < 500 THEN 'MEDIUM (250-500g)'
        WHEN weight_in_grams < 1000 THEN 'HEAVY (500g-1kg)'
        ELSE 'VERY_HEAVY (>1kg)'
    END AS weight_category,
    COUNT(*) AS product_count,
    ROUND(AVG(discount_percent), 2) AS avg_discount_pct,
    ROUND(AVG(available_quantity), 0) AS avg_quantity,
    ROUND(AVG(price_per_kg), 2) AS avg_price_per_kg,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE stock_status IN ('OUT_OF_STOCK', 'CRITICAL_LOW')) / COUNT(*),
        2
    ) AS stockout_rate_pct,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE overstock_risk IN ('HIGH_RISK', 'VERY_HIGH_RISK')) / COUNT(*),
        2
    ) AS overstock_rate_pct
FROM zepto_summary
GROUP BY weight_category
ORDER BY weight_category;


-- QUESTION 10: PRICE SEGMENT ANALYSIS AND DEMAND PATTERNS


SELECT
    CASE
        WHEN discounted_selling_price < 50 THEN 'BUDGET (<50)'
        WHEN discounted_selling_price < 100 THEN 'AFFORDABLE (50-100)'
        WHEN discounted_selling_price < 250 THEN 'MID_RANGE (100-250)'
        WHEN discounted_selling_price < 500 THEN 'PREMIUM (250-500)'
        ELSE 'LUXURY (>500)'
    END AS price_segment,
    COUNT(*) AS product_count,
    ROUND(AVG(available_quantity), 0) AS avg_stock_level,
    ROUND(AVG(discount_percent), 2) AS avg_discount_pct,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE stock_status IN ('OUT_OF_STOCK', 'CRITICAL_LOW')) / COUNT(*),
        2
    ) AS stockout_rate_pct,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE overstock_risk IN ('HIGH_RISK', 'VERY_HIGH_RISK')) / COUNT(*),
        2
    ) AS overstock_rate_pct
FROM zepto_summary
GROUP BY price_segment
ORDER BY price_segment;