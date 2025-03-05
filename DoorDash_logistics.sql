/* DOORDASH LOGISTICS QUERY */

/* STEP 1 - ADDING COLUMNS FOR FUTURE USE */

-- Add a sequential ID column to track the order creation sequence.
-- This allows us to have a unique row identifier based on order time.
ALTER TABLE eta_doordash ADD COLUMN row_number INT;

-- Add a helper column with a constant value of 1 for later aggregations.
ALTER TABLE eta_doordash ADD COLUMN order_1 INTEGER DEFAULT 1;

-- Link the row_number column to the order creation timestamp.
-- This helps in ordering and tracking the sequence of orders over time.
UPDATE eta_doordash
SET row_number = subquery.row_number
FROM (
    SELECT 
	"created_at"
	, ROW_NUMBER() OVER (ORDER BY "created_at" ASC) AS row_number
    FROM eta_doordash
) AS subquery
WHERE eta_doordash."created_at" = subquery."created_at";

/* STEP 2 - PEAK DEMAND ANALYSIS */

-- Objective: Identify peak hours by counting orders per hour.

-- Step 2.1: Extract the hour from each order's creation timestamp.
-- This helps us group orders by hour to detect demand patterns.
WITH peak_hours AS (
    SELECT 
        EXTRACT(HOUR FROM created_at) AS order_hour 
        , COUNT(row_number) AS orders
	, subtotal
    FROM eta_doordash
    GROUP BY created_at, subtotal
)

-- Step 2.2: Aggregate total orders and average subtotal per hour.
, a AS (
	SELECT 
		order_hour
		, SUM(orders) AS total_orders
		, ROUND(AVG(subtotal)::NUMERIC, 0) AS avg_subtotal
	FROM peak_hours
	GROUP BY order_hour
	ORDER BY order_hour ASC
)

-- Step 2.3: Rank the hours by total number of order.
-- This allows us to quickly identify the 5 most active hours.
, ranked AS (
	SELECT 
		RANK() OVER (ORDER BY total_orders DESC) AS ranking
		, order_hour
		, total_orders
		, avg_subtotal
	FROM a
)

/* STEP 3 - DELIVERY TIME ANALYSIS */

-- Objective: Calculate average delivery time per hour and track variations.

-- Step 3.1: Calculate the delivery time in minutes for each order.
-- This captures time elapsed from order creation to actual delivery.
, minutes_passed AS (
	SELECT
		EXTRACT(HOUR FROM created_at) AS order_hour
		, order_1
		, total_items
		, EXTRACT(EPOCH FROM (actual_delivery_time - created_at)) / 60 AS minutes
	FROM eta_doordash
)

-- Step 3.2: Aggregate delivery metrics (avg, min, max) per hour.
, delivery AS(
	SELECT 
		order_hour
		, sum(order_1) AS total_orders
		, ROUND(AVG(total_items)::NUMERIC, 0) AS avg_items_order
		, ROUND(AVG(minutes)::NUMERIC, 0) AS avg_minutes
		, ROUND(MIN(minutes)::NUMERIC, 0) AS min_minutes
		, ROUND(MAX(minutes)::NUMERIC, 0) AS max_minutes
	FROM minutes_passed
	GROUP BY order_hour
	ORDER BY total_orders DESC
)

/* STEP 4 - DRIVER UTILIZATION RATE ANALYSIS */

-- Objective: Analyze supply and demand imbalances by hour.

-- Step 4.1: Extract dashers on shift, busy dashers, and outstanding orders per hour.
-- Claculate over-supply (idle dashers) and over-demand (unmet orders) per hour.
, drivers AS (
	SELECT
		EXTRACT(HOUR FROM created_at) AS order_hour
		, total_onshift_dashers
		, total_busy_dashers
		, total_outstanding_orders
		, CASE
			WHEN total_onshift_dashers - total_busy_dashers >= 0 THEN total_onshift_dashers - total_busy_dashers
			ELSE 0 END AS over_supply
		, CASE
			WHEN total_outstanding_orders - total_busy_dashers >= 0 THEN total_outstanding_orders - total_busy_dashers
			ELSE 0 END AS over_demand
	FROM eta_doordash
)

-- Step 4.2: Aggregate average supply, demand, and net balance per hour.
, utilization AS(
	SELECT
		order_hour
		, ROUND(AVG(total_onshift_dashers)::NUMERIC, 0) AS total_dashers
		, ROUND(AVG(total_busy_dashers)::NUMERIC, 0) AS busy_dashers
		, ROUND(AVG(total_outstanding_orders)::NUMERIC, 0) AS orders_created
		, ROUND(AVG(over_supply)::NUMERIC, 0) AS oversupply
		, ROUND(AVG(over_demand)::NUMERIC, 0) AS overdemand
		, ROUND(AVG(over_supply - over_demand)::NUMERIC, 0) AS net
	FROM drivers
	GROUP BY order_hour
	ORDER BY order_hour ASC
)

/* STEP 5 - SUMMARY REPORT */

-- Objective: Combine all metrics into a single report to analyze peak hours,
-- delivery performance, and dsher utilization side-by-side.

SELECT
	ranked.ranking
	, ranked.order_hour
	, ranked.avg_subtotal
	, delivery.avg_items_order
	, delivery.avg_minutes
	, delivery.min_minutes
	, delivery.max_minutes
	, utilization.total_dashers
	, utilization.total_dashers - utilization.net AS needed_dashers  -- Dashers required to meet demand
	, -utilization.net AS difference  -- Demand-supply imbalance (negative means shortage of dashers).
FROM ranked
LEFT JOIN delivery
ON ranked.order_hour = delivery.order_hour
LEFT JOIN utilization
ON ranked.order_hour = utilization.order_hour
ORDER BY ranking ASC;
