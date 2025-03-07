# DoorDash Logistics: Data Analysis Project
Analyzing peak hours, delivery time optimization, and driver utilization rates using data from Kaggle.

# Introduction

Hi! Welcome to my **DoorDash Logistics Analysis** project! This case study is part of my portfolio and focuses on optimizing delivery times, undestanding peak hour demand, and analyzing driver utilization rates.

**Disclamer:** The data, sourced from a Kaggle forum, simulates real-time delivery information from DoorDash. However, the dataset is completly fictional, and it does not necessaryly reflect real-world conditions, therefore the conclusions are based solely on the available data and may not accurately represent actual trends.

# Skills Demonstrated

**SQL Query Structuring & Organization:**
* Commenting, documentation, and `WITH` statements.

**Data Transformation & Aggregation:**
* Key operations: `ALTER TABLE`, `ADD COLUMN`, `UPDATE`, `COUNT()`, `SUM()`, `AVG()`, `GROUP BY`.

**Time-Based Analysis & Extraction:**
* Extracting insights using `EXTRACT(HOUR)` to analyze hourly demand patterns.

**Window Functions & Ranking:**
* Applying `ROW_NUMBER()`, `RANK()`, and `ORDER BY` to evaluate hourly performance.

**Conditional Logic & Case Statements:**
* Dynamic analysis using `CASE` for flexible reporting.

**Data Joining & Relationships:**
* Combining multiple analytical perspectives via `LEFT JOIN`.

**Business Analysis & Strategy Insights:**
* Translating raw data into actionable recommendations.

# Conclusions

| Findings  | Insight |
| ------------- | ------------- |
| Peak Hours  | Highest order volumes occur between **1:00-4:00 hrs** and **20:00 hrs**.  |
| Revenue Patterns  | Peak hours drive higher **order values**, even though **order size (items)** remains stable.  |
| Delivery Times  | Delivery times show **minor variation** between peak and off-peak hours.  |
| Driver Shortages  | Peak hour demand **exceeds available Dashers**, leading to potential delivery delays.  |

# Solutions

**1. Smoothing Peak Hours:**
* Notify users in advance with **ETA estimates** for sponsored restaurants, encouraging earlier/later orders.
* Offer **discounts/rewards** for ordering outside peak times.

**2. Optimizing Delivery Time:**
* Allow customers to **pre-schedule meals**, improving kitchen and driver coordination.
* Share **demand forecasts** with restaurants, encouraging pre-prep of popular dishes.

**3. Enhancing Driver Utilization:**
* Send proactive **notifications to Dashers** before peak times.
* Show Dashers real-time **surge pricing** for peak hour deliveries, driving supply alignment.

# Files in this Repository

| **File**  | **Description**  |
| ---------  | --------------- |
| [historical_data.csv](https://www.kaggle.com/datasets/dharun4772/doordash-eta-prediction) | Source data |
| [doordash_logistics.sql](https://github.com/jacinta-escaffi/DoorDash_logistics/blob/main/DoorDash_logistics.sql) | Full SQL script |
| [README.md](https://github.com/jacinta-escaffi/DoorDash_logistics/blob/main/README.md) | This documentation file |

You can also visualize the data through [Tableu](https://public.tableau.com/app/profile/jacinta.escaffi/viz/DoorDash_logistics/Dashboard1).
