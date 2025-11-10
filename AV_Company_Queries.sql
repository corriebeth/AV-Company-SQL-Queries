SET SQL_SAFE_UPDATES = 0;

UPDATE equipment_rentals_2024_final
SET 
    equipment_rented = NULLIF(equipment_rented, ''),
    rental_cost = NULLIF(rental_cost, ''),
    labor_cost = NULLIF(labor_cost, ''),
    transport_cost = NULLIF(transport_cost, ''),
    client_satisfaction = NULLIF(client_satisfaction, ''),
    hours_on_site = NULLIF(hours_on_site, '');

-- Now convert data types
ALTER TABLE equipment_rentals_2024_final
MODIFY COLUMN equipment_rented INT,
MODIFY COLUMN rental_cost DOUBLE,
MODIFY COLUMN labor_cost DOUBLE,
MODIFY COLUMN transport_cost DOUBLE,
MODIFY COLUMN client_satisfaction DOUBLE,
MODIFY COLUMN hours_on_site DOUBLE;


SELECT *
FROM AV_Company.equipment_rentals_2024_final;

#Most and least profitable event types
SELECT event_type, ROUND(SUM(rental_cost) - (SUM(labor_cost) + SUM(transport_cost)),2) AS total_revenue
FROM AV_Company.equipment_rentals_2024_final
GROUP BY event_type
ORDER BY total_revenue DESC;

#Labor and transport cost per event type
SELECT event_type, ROUND(SUM(labor_cost),2) AS total_labor_cost, ROUND(SUM(transport_cost),2) AS total_transport_cost
FROM AV_Company.equipment_rentals_2024_final
GROUP BY event_type
ORDER BY total_labor_cost DESC;

#Avg profit margins by city 
SELECT city, ROUND(AVG(rental_cost - (labor_cost + transport_cost)),2) AS avg_profit_margin
FROM AV_Company.equipment_rentals_2024_final
GROUP BY city
ORDER BY avg_profit_margin DESC;

#Equipment utilization 
SELECT equipment_category, ROUND((SUM(equipment_rented)/SUM(hours_on_site)),2) AS equipment_utilization 
FROM AV_Company.equipment_rentals_2024_final
GROUP BY equipment_category
ORDER BY equipment_utilization DESC;

#Event duration vs. profitability 
SELECT
  ROUND(SUM(CASE WHEN hours_on_site < 10 THEN rental_cost - (labor_cost + transport_cost) ELSE 0 END), 2) AS low_hours_revenue,
  ROUND(SUM(CASE WHEN hours_on_site > 10 AND hours_on_site <= 20 THEN rental_cost - (labor_cost + transport_cost) ELSE 0 END), 2) AS mid_hours_revenue,
  ROUND(SUM(CASE WHEN hours_on_site > 20 THEN rental_cost - (labor_cost + transport_cost) ELSE 0 END), 2) AS high_hours_revenue
FROM AV_Company.equipment_rentals_2024_final;

#Events with high costs compared to revenue
SELECT event_type, AVG(rental_cost - (labor_cost + transport_cost)) AS avg_profit_margin, 
	AVG((rental_cost - (labor_cost + transport_cost)) / rental_cost) AS avg_margin_ratio
FROM AV_Company.equipment_rentals_2024_final
WHERE rental_cost IS NOT NULL AND labor_cost IS NOT NULL AND transport_cost IS NOT NULL
GROUP BY event_type
ORDER BY avg_profit_margin;

#Revenue vs. client_satisfaction
SELECT
  ROUND(SUM(CASE WHEN client_satisfaction < 3.5 
			THEN rental_cost - (labor_cost + transport_cost) ELSE 0 END), 2) AS low_satisfaction_revenue,
  ROUND(SUM(CASE WHEN client_satisfaction >= 3.5 
			THEN rental_cost - (labor_cost + transport_cost) ELSE 0 END), 2) AS high_satisfaction_revenue
FROM AV_Company.equipment_rentals_2024_final;

#Client satisfaction per event type
SELECT event_type, ROUND(AVG(client_satisfaction),2) AS avg_client_satisfaction
FROM AV_Company.equipment_rentals_2024_final
GROUP BY event_type
ORDER BY avg_client_satisfaction DESC;

#Client satisfaction per city
SELECT city, ROUND(AVG(client_satisfaction),2) AS avg_client_satisfaction
FROM AV_Company.equipment_rentals_2024_final
GROUP BY city
ORDER BY avg_client_satisfaction DESC;




