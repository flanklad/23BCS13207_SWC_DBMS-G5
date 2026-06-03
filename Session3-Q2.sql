WITH monthly_status AS (
    SELECT 
        product_name,
        month_start,
        monthly_active_users AS mau,
        -- Check if current month is increasing or decreasing compared to last month
        CASE 
            WHEN monthly_active_users > LAG(monthly_active_users) OVER(PARTITION BY product_name ORDER BY month_start) THEN 'Growth'
            WHEN monthly_active_users < LAG(monthly_active_users) OVER(PARTITION BY product_name ORDER BY month_start) THEN 'Decline'
            ELSE 'Stable'
        END AS status
    FROM product_engagement
),

momentum_check AS (
    SELECT 
        product_name,
        month_start AS lowest_point_month,
        mau AS lowest_users,
        -- Pull the exact start and end points we need for the final output
        LAG(month_start, 3) OVER(PARTITION BY product_name ORDER BY month_start) AS decline_started,
        LEAD(month_start, 1) OVER(PARTITION BY product_name ORDER BY month_start) AS growth_resumed,
        LEAD(mau, 3) OVER(PARTITION BY product_name ORDER BY month_start) AS peak_users,
        
        -- Look back at the status of the last 3 months
        LAG(status, 0) OVER(PARTITION BY product_name ORDER BY month_start) AS current_status,
        LAG(status, 1) OVER(PARTITION BY product_name ORDER BY month_start) AS prev_1,
        LAG(status, 2) OVER(PARTITION BY product_name ORDER BY month_start) AS prev_2,
        
        -- Look forward at the status of the next 3 months
        LEAD(status, 1) OVER(PARTITION BY product_name ORDER BY month_start) AS next_1,
        LEAD(status, 2) OVER(PARTITION BY product_name ORDER BY month_start) AS next_2,
        LEAD(status, 3) OVER(PARTITION BY product_name ORDER BY month_start) AS next_3
    FROM monthly_status
)

SELECT 
    product_name,
    decline_started,
    growth_resumed,
    (peak_users - lowest_users)::FLOAT / lowest_users AS growth_ratio
FROM momentum_check
WHERE 
    -- Target the bottom/inflection month: 3 declines leading to it, 3 growths after it
    current_status = 'Decline' AND prev_1 = 'Decline' AND prev_2 = 'Decline'
    AND next_1 = 'Growth' AND next_2 = 'Growth' AND next_3 = 'Growth';
