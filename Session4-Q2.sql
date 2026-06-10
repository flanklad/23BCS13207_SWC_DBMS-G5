WITH cleaned_tasks AS (
    
    SELECT DISTINCT start_time, end_time
    FROM task_schedule
    WHERE start_time IS NOT NULL AND end_time IS NOT NULL
),
events AS (
  
    SELECT start_time AS event_time, 1 AS cpu_change
    FROM cleaned_tasks
    UNION ALL
    SELECT end_time AS event_time, -1 AS cpu_change
    FROM cleaned_tasks
),
ordered_events AS (
    SELECT 
        SUM(cpu_change) OVER (
            ORDER BY event_time ASC, cpu_change ASC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS concurrent_cpus
    FROM events
)

SELECT MAX(concurrent_cpus) AS min_cpus
FROM ordered_events;
