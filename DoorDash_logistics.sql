/* DOORDASH LOGISTICS QUERY */

/* ADDING COLUMNS FOR FUTURE USE */

-- Create a new column to set an identification number for each column and a column with a constant 1

ALTER TABLE eta_doordash ADD COLUMN row_number INT;
ALTER TABLE eta_doordash ADD COLUMN order_1 INTEGER DEFAULT 1;

-- Link the new identification number to the time the order was created
-- so id number 1 matches with the first order created

UPDATE eta_doordash
SET row_number = subquery.row_number
FROM (
    SELECT 
	"created_at"
	, ROW_NUMBER() OVER (ORDER BY "created_at" ASC) AS row_number
    FROM eta_doordash
) AS subquery
WHERE eta_doordash."created_at" = subquery."created_at";

/* PEAK DEMAND ANALYSIS */

-- Count the number of orders in each hour of the day

WITH peak_hours AS (
    SELECT 
        EXTRACT(HOUR FROM created_at) AS order_hour 
        , COUNT(row_number) AS orders
		, subtotal
    FROM eta_doordash
    GROUP BY created_at, subtotal
)
, a AS (
	SELECT 
		order_hour
		, SUM(orders) AS total_orders
		, ROUND(AVG(subtotal)::numeric, 0) AS avg_subtotal
	FROM peak_hours
	GROUP BY order_hour
	ORDER BY order_hour ASC
)

-- Make a raking with the top 5 hours of the day with the most amount of orders

, ranked AS (
	SELECT 
		RANK() OVER (ORDER BY total_orders DESC) AS ranking
		, order_hour
		, total_orders
		, avg_subtotal
	FROM a
)

/* DELIVERY TIME OPTIMIZATION */

-- Calculate the minutes passed between the order's creation to the order's delivery

, minutes_passed AS (
	SELECT
		EXTRACT(HOUR FROM created_at) AS order_hour
		, order_1
		, total_items
		, EXTRACT(EPOCH FROM (actual_delivery_time - created_at)) / 60 AS minutes
	FROM eta_doordash
)

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

/* DRIVER UTILIZATION RATE */

-- Extract the data of the amount of drivers and orders

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

/* PUTTING EVERYTHING TOGETHER */

-- Join ranked, delivery and utilization with the hour.

SELECT
	ranked.ranking
	, ranked.order_hour
	, ranked.avg_subtotal
	, delivery.avg_items_order
	, delivery.avg_minutes
	, delivery.min_minutes
	, delivery.max_minutes
	, utilization.total_dashers
	, utilization.total_dashers - utilization.net AS needed_dashers
	, -utilization.net AS difference
FROM ranked
LEFT JOIN delivery
ON ranked.order_hour = delivery.order_hour
LEFT JOIN utilization
ON ranked.order_hour = utilization.order_hour
ORDER BY ranking ASC