SELECT 
    f.date,
    SUM(CASE WHEN a.paying_customer = 'no' THEN f.downloads ELSE 0 END) AS non_paying_downloads,
    SUM(CASE WHEN a.paying_customer = 'yes' THEN f.downloads ELSE 0 END) AS paying_downloads
FROM ms_download_facts f
JOIN ms_user_dimension u ON f.user_id = u.user_id
JOIN ms_acc_dimension a ON u.acc_id = a.acc_id
GROUP BY f.date
HAVING SUM(CASE WHEN a.paying_customer = 'no' THEN f.downloads ELSE 0 END) > 
       SUM(CASE WHEN a.paying_customer = 'yes' THEN f.downloads ELSE 0 END)
ORDER BY f.date ASC;
