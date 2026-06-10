WITH next_transactions AS (
  SELECT 
    transaction_id,
    merchant_id,
    credit_card_id,
    amount,
    transaction_timestamp,
    LEAD(transaction_timestamp) OVER(
      PARTITION BY merchant_id, credit_card_id, amount 
      ORDER BY transaction_timestamp
    ) AS next_timestamp
  FROM transactions
)

SELECT COUNT(*) AS payment_count
FROM next_transactions
WHERE next_timestamp - transaction_timestamp <= INTERVAL '10 minutes';
