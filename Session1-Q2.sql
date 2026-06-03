WITH RECURSIVE date_spine AS (
    -- 1. Generate all dates in the requested 2-week window
    SELECT '2025-04-15'::DATE AS transaction_date
    UNION ALL
    SELECT transaction_date + 1
    FROM date_spine
    WHERE transaction_date < '2025-04-28'
),
valid_purchases AS (
    -- 2. Filter for the targeted completed US purchases
    SELECT 
        transaction_id,
        transaction_date,
        amount
    FROM product_sales
    WHERE product_id = 'PROD-2891'
      AND country = 'US'
      AND type = 'purchase'
      AND status = 'completed'
      AND transaction_date BETWEEN '2025-04-15' AND '2025-04-28'
),
associated_refunds AS (
    -- 3. Get all completed refunds tied back to those specific purchases
    SELECT 
        original_transaction_id,
        SUM(amount) AS total_refunded
    FROM product_sales
    WHERE type = 'refund'
      AND status = 'completed'
      AND original_transaction_id IN (SELECT transaction_id FROM valid_purchases)
    GROUP BY original_transaction_id
),
net_purchase_revenue AS (
    -- 4. Calculate net revenue per purchase transaction
    SELECT 
        p.transaction_date,
        (p.amount - COALESCE(r.total_refunded, 0)) AS net_amount
    FROM valid_purchases p
    LEFT JOIN associated_refunds r ON p.transaction_id = r.original_transaction_id
)
-- 5. Join against the date spine to ensure 0s are shown for empty days
SELECT 
    d.transaction_date,
    COALESCE(SUM(n.net_amount), 0) AS daily_net_revenue
FROM date_spine d
LEFT JOIN net_purchase_revenue n ON d.transaction_date = n.transaction_date
GROUP BY d.transaction_date
ORDER BY d.transaction_date;
