# DoorDash_logistics
Analyzing peak hours, delivery time optimization, and driver utilization rates from a database extracted from Kaggle.

**INTRODUCTION**

Hi! Welcome to this project in my portfolio, where I extracted data from a forum about DoorDash delivery ETAs to analyze peak hours, delivery time optimization, and driver utilization rates.

This project demonstrates my SQL abilities, including:

	1. SQL Query Structuring & Organization: Commenting, documentation, and WITH statements.
	2. Data Transformation & Aggregation:
		- ALTER TABLE, ADD COLUMN, UPDATE.
		- COUNT(), SUM(), AVG(), MIN(), MAX().
		- GROUP BY.
	3. Window Functions & Ranking: ROW_NUMBER(), RANK(), ORDER BY.
	4. Time-Based Analysis & Extraction: EXTRACT(HOUR FROM created_at).
	5. Conditional Logic & Case Statements: CASE.
	6. Data Joining & Relationships: LEFT JOIN.
	7. Data Analysis, Business, and Strategy Insights.

**Disclaimer:** The data used in this project was extracted from a forum and does not reflect real-world conditions. Therefore, the conclusions are based solely on the available data and may not accurately represent actual trends.

**CONCLUSIONS**

	1. The times that have more orders are in the early morning (01:00, 02:00, 03:00, 04:00 hrs), and 20:00 hrs.
	2. The most demanded hours are also the most profitable.
	3. The average of items don't change much, so the consumers buy more expensive food in the peak hours.
	4. The delivery time doesn't change significantly from the non-peak hours.
	5. The amount of orders created are superior than the amount of dashers in peak hours, which creates a gap between demand and supply.

**SOLUTIONS**

To smooth peak hours:

	1. Send notifications to consumers with the estimated time of arrival for a sponsored restaurant near a peak hour. This can help extend the peak period while reducing its intensity.
	2. Offer discounts or rewards to consumers that order outside of the peak hours.

To improve delivery time optimization:

	1. Allow customers to schedule a meal for a specific time and coordinate meal preparation with the assignment of a Dasher.
	2. Give data to restaurants about the most demanted dishes so they can prepare in advance and pre-cook a batch before an order is created. 

To increase driver utilization rate:

	1. Send notifications to Dashers when a peak hour is about to start.
	2. Display data to Dashers about the increase in price per order, providing an incentive to work during high-demand hours.
 
