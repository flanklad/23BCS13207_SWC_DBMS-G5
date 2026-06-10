SELECT 
  7 AS month, 
  COUNT(DISTINCT user_id) AS monthly_active_users
FROM user_actions
WHERE EXTRACT(MONTH FROM event_date) = 7
  AND EXTRACT(YEAR FROM event_date) = 2022
  AND user_id IN (
    SELECT user_id
    FROM user_actions
    WHERE EXTRACT(MONTH FROM event_date) = 6
      AND EXTRACT(YEAR FROM event_date) = 2022
  );
