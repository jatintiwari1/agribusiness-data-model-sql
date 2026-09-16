-- ============================================================
-- AGRIBUSINESS DATA MODEL - ANALYTICAL SQL QUERIES
-- MySQL 8.0+
-- ============================================================


-- ============================================================
-- Q1. Total and Average Yield per Crop
-- Business Question:
-- Which crops produce the highest total and average yield?
-- ============================================================

SELECT
    c.crop_name,
    COUNT(h.harvest_id) AS harvest_events,
    SUM(h.quantity_kg) AS total_yield_kg,
    ROUND(AVG(h.quantity_kg), 2) AS avg_yield_per_harvest_kg
FROM Harvest h
JOIN Planting p
    ON h.planting_id = p.planting_id
JOIN Crop c
    ON p.crop_id = c.crop_id
GROUP BY c.crop_id, c.crop_name
ORDER BY total_yield_kg DESC;


-- ============================================================
-- Q2. Yield per Hectare by Field
-- Business Question:
-- Which fields are the most productive based on yield per hectare?
-- ============================================================

SELECT
    f.field_name,
    c.crop_name,
    ROUND(SUM(h.quantity_kg) / f.area_hectares, 2)
        AS yield_per_hectare_kg
FROM Harvest h
JOIN Planting p
    ON h.planting_id = p.planting_id
JOIN Field f
    ON p.field_id = f.field_id
JOIN Crop c
    ON p.crop_id = c.crop_id
WHERE f.area_hectares > 0
GROUP BY f.field_id, f.field_name, c.crop_id, c.crop_name, f.area_hectares
ORDER BY yield_per_hectare_kg DESC;


-- ============================================================
-- Q3. Farm-Level Revenue, Costs and Net Profit
-- Business Question:
-- What are the revenue, costs and estimated net profit of each farm?
-- ============================================================

WITH Revenue AS (
    SELECT
        f.farm_id,
        f.farm_name,
        COALESCE(SUM(s.quantity_sold_kg * s.price_per_kg), 0)
            AS total_revenue
    FROM Farm f
    LEFT JOIN Field fld
        ON f.farm_id = fld.farm_id
    LEFT JOIN Planting p
        ON fld.field_id = p.field_id
    LEFT JOIN Harvest h
        ON p.planting_id = h.planting_id
    LEFT JOIN Sale s
        ON h.harvest_id = s.harvest_id
    GROUP BY f.farm_id, f.farm_name
),
InputCosts AS (
    SELECT
        farm_id,
        COALESCE(SUM(quantity * unit_cost), 0) AS input_cost
    FROM Input_Purchase
    GROUP BY farm_id
),
LaborCosts AS (
    SELECT
        e.farm_id,
        COALESCE(SUM(l.hours_worked * e.wage_rate), 0)
            AS labor_cost
    FROM Labor l
    JOIN Employee e
        ON l.employee_id = e.employee_id
    GROUP BY e.farm_id
),
OtherExpenses AS (
    SELECT
        farm_id,
        COALESCE(SUM(amount), 0) AS other_expenses
    FROM Expense
    GROUP BY farm_id
)
SELECT
    r.farm_name,
    ROUND(r.total_revenue, 2) AS total_revenue,
    ROUND(COALESCE(i.input_cost, 0), 2) AS input_cost,
    ROUND(COALESCE(l.labor_cost, 0), 2) AS labor_cost,
    ROUND(COALESCE(e.other_expenses, 0), 2) AS other_expenses,
    ROUND(
        r.total_revenue
        - COALESCE(i.input_cost, 0)
        - COALESCE(l.labor_cost, 0)
        - COALESCE(e.other_expenses, 0),
        2
    ) AS net_profit
FROM Revenue r
LEFT JOIN InputCosts i
    ON r.farm_id = i.farm_id
LEFT JOIN LaborCosts l
    ON r.farm_id = l.farm_id
LEFT JOIN OtherExpenses e
    ON r.farm_id = e.farm_id
ORDER BY net_profit DESC;


-- ============================================================
-- Q4. Crop Price Trend in a Market
-- Business Question:
-- How has the recorded market price of a crop changed over time?
-- ============================================================

SELECT
    c.crop_name,
    m.market_name,
    ph.price_date,
    ph.price_per_kg
FROM Price_History ph
JOIN Crop c
    ON ph.crop_id = c.crop_id
JOIN Market m
    ON ph.market_id = m.market_id
ORDER BY c.crop_name, m.market_name, ph.price_date;


-- ============================================================
-- Q5. Change from Previous Recorded Price
-- Business Question:
-- How much has the crop price changed from the previous
-- recorded observation?
-- ============================================================

SELECT
    c.crop_name,
    m.market_name,
    ph.price_date,
    ph.price_per_kg,
    LAG(ph.price_per_kg) OVER (
        PARTITION BY ph.crop_id, ph.market_id
        ORDER BY ph.price_date
    ) AS previous_price,
    ROUND(
        ph.price_per_kg -
        LAG(ph.price_per_kg) OVER (
            PARTITION BY ph.crop_id, ph.market_id
            ORDER BY ph.price_date
        ),
        2
    ) AS price_change
FROM Price_History ph
JOIN Crop c
    ON ph.crop_id = c.crop_id
JOIN Market m
    ON ph.market_id = m.market_id
ORDER BY c.crop_name, m.market_name, ph.price_date;


-- ============================================================
-- Q6. Labour Hours and Cost by Employee
-- Business Question:
-- How many hours has each employee worked and what is the
-- associated labour cost?
-- ============================================================

SELECT
    e.employee_name,
    e.role,
    f.farm_name,
    ROUND(SUM(l.hours_worked), 2) AS total_hours,
    ROUND(SUM(l.hours_worked * e.wage_rate), 2) AS total_labor_cost
FROM Labor l
JOIN Employee e
    ON l.employee_id = e.employee_id
JOIN Farm f
    ON e.farm_id = f.farm_id
GROUP BY
    e.employee_id,
    e.employee_name,
    e.role,
    f.farm_name
ORDER BY total_labor_cost DESC;


-- ============================================================
-- Q7. Equipment Utilization
-- Business Question:
-- Which equipment is used most and which equipment may be idle?
-- ============================================================

SELECT
    eq.equipment_name,
    eq.equipment_type,
    f.farm_name,
    COUNT(eu.usage_id) AS times_used,
    COALESCE(SUM(eu.hours_used), 0) AS total_hours_used
FROM Equipment eq
JOIN Farm f
    ON eq.farm_id = f.farm_id
LEFT JOIN Equipment_Usage eu
    ON eq.equipment_id = eu.equipment_id
GROUP BY
    eq.equipment_id,
    eq.equipment_name,
    eq.equipment_type,
    f.farm_name
ORDER BY total_hours_used DESC;


-- ============================================================
-- Q8. Top Suppliers by Procurement Spend
-- Business Question:
-- Which suppliers account for the largest procurement spend?
-- ============================================================

SELECT
    s.supplier_name,
    s.supplier_type,
    COUNT(ip.purchase_id) AS number_of_orders,
    ROUND(SUM(ip.quantity * ip.unit_cost), 2) AS total_spend
FROM Input_Purchase ip
JOIN Supplier s
    ON ip.supplier_id = s.supplier_id
GROUP BY
    s.supplier_id,
    s.supplier_name,
    s.supplier_type
ORDER BY total_spend DESC
LIMIT 10;


-- ============================================================
-- Q9. Top-Selling Crop in Each Market
-- Business Question:
-- Which crop generates the highest sales revenue in each market?
-- ============================================================

WITH CropMarketSales AS (
    SELECT
        m.market_id,
        m.market_name,
        c.crop_id,
        c.crop_name,
        SUM(s.quantity_sold_kg) AS total_quantity_sold_kg,
        SUM(s.quantity_sold_kg * s.price_per_kg) AS total_revenue
    FROM Sale s
    JOIN Harvest h
        ON s.harvest_id = h.harvest_id
    JOIN Planting p
        ON h.planting_id = p.planting_id
    JOIN Crop c
        ON p.crop_id = c.crop_id
    JOIN Market m
        ON s.market_id = m.market_id
    GROUP BY
        m.market_id,
        m.market_name,
        c.crop_id,
        c.crop_name
),
RankedSales AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY market_id
            ORDER BY total_revenue DESC
        ) AS market_rank
    FROM CropMarketSales
)
SELECT
    market_name,
    crop_name,
    ROUND(total_quantity_sold_kg, 2) AS total_quantity_sold_kg,
    ROUND(total_revenue, 2) AS total_revenue
FROM RankedSales
WHERE market_rank = 1
ORDER BY market_name;


-- ============================================================
-- Q10. Rainfall vs Yield
-- Business Question:
-- What was the average rainfall during each crop cycle
-- alongside the resulting harvest yield?
-- ============================================================

SELECT
    p.planting_id,
    c.crop_name,
    f.field_name,
    p.planting_date,
    h.harvest_date,
    ROUND(AVG(w.rainfall_mm), 2)
        AS avg_rainfall_mm_during_cycle,
    h.quantity_kg AS yield_kg
FROM Planting p
JOIN Field f
    ON p.field_id = f.field_id
JOIN Crop c
    ON p.crop_id = c.crop_id
JOIN Harvest h
    ON h.planting_id = p.planting_id
JOIN Weather_Log w
    ON w.farm_id = f.farm_id
    AND w.record_date BETWEEN p.planting_date AND h.harvest_date
GROUP BY
    p.planting_id,
    c.crop_name,
    f.field_name,
    p.planting_date,
    h.harvest_id,
    h.harvest_date,
    h.quantity_kg
ORDER BY p.planting_date;


-- ============================================================
-- Q11. Fields with a Declining Harvest Yield Trend
-- Business Question:
-- Which fields show a decrease compared with their
-- previous recorded harvest?
-- ============================================================

WITH HarvestTrend AS (
    SELECT
        f.field_id,
        f.field_name,
        c.crop_name,
        h.harvest_date,
        h.quantity_kg,
        LAG(h.quantity_kg) OVER (
            PARTITION BY f.field_id
            ORDER BY h.harvest_date
        ) AS previous_yield_kg
    FROM Harvest h
    JOIN Planting p
        ON h.planting_id = p.planting_id
    JOIN Field f
        ON p.field_id = f.field_id
    JOIN Crop c
        ON p.crop_id = c.crop_id
)
SELECT
    field_name,
    crop_name,
    harvest_date,
    quantity_kg,
    previous_yield_kg,
    ROUND(quantity_kg - previous_yield_kg, 2)
        AS yield_change_kg
FROM HarvestTrend
WHERE previous_yield_kg IS NOT NULL
  AND quantity_kg < previous_yield_kg
ORDER BY field_name, harvest_date;


-- ============================================================
-- Q12. Top Buyers by Market
-- Business Question:
-- Who are the largest buyers in each market by quantity
-- and total purchase value?
-- ============================================================

SELECT
    m.market_name,
    s.buyer_name,
    COUNT(s.sale_id) AS number_of_transactions,
    SUM(s.quantity_sold_kg) AS total_quantity_kg,
    SUM(s.quantity_sold_kg * s.price_per_kg) AS total_value
FROM Sale s
JOIN Market m
    ON s.market_id = m.market_id
GROUP BY
    m.market_id,
    m.market_name,
    s.buyer_name
ORDER BY
    m.market_name,
    total_value DESC;
