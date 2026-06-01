WITH sent_cte AS
(SELECT date,user_id_sender,user_id_receiver FROM fb_friend_requests WHERE action='sent'),
accepted_cte AS 
(SELECT date,user_id_sender,user_id_receiver FROM fb_friend_requests WHERE action='accepted')
SELECT a.date, COUNT(b.user_id_receiver)/CAST(COUNT(a.user_id_sender) AS DECIMAL)
  AS percentage_acceptance --as it is calculated from the accepted from the b table div by sent from a table
FROM sent_cte a 
  LEFT JOIN accepted_cte b ONa.user_id_sender=b.user_id_sender
AND a.user_id_receiver=b.user_id_receiver --just a way to link
GROUP BY a.date
