---Top 5 winning numbers

SELECT number, COUNT(*) as count
FROM (
  SELECT 
    split_part(winning_numbers, ' ', 1) as number
  FROM "superset_table"
  UNION ALL
  SELECT 
    split_part(winning_numbers, ' ', 2)
  FROM "superset_table"
  UNION ALL
  SELECT 
    split_part(winning_numbers, ' ', 3)
  FROM "superset_table"
  UNION ALL
  SELECT 
    split_part(winning_numbers, ' ', 4)
  FROM "superset_table"
  UNION ALL
  SELECT 
    split_part(winning_numbers, ' ', 5)
  FROM "superset_table"
) as numbers
GROUP BY number
ORDER BY count DESC
LIMIT 5;

---Average Multiplier Value
SELECT AVG(CAST(multiplier AS DOUBLE)) as average_multiplier
FROM "superset_table";

---Top 5 Mega Ball Numbers
SELECT mega_ball, COUNT(*) as count
FROM "superset_table"
GROUP BY mega_ball
ORDER BY count DESC
LIMIT 5;

---Lotteries drawn on weekday vs weekend
SELECT 
  CASE 
    WHEN day_of_week IN (6, 7) THEN 'Weekend'  -- Assuming 6 = Saturday, 7 = Sunday
    ELSE 'Weekday'
  END as day_type,
  COUNT(*) as count
FROM (
  SELECT 
    EXTRACT(DAY_OF_WEEK FROM DATE_PARSE(draw_date, '%m/%d/%Y')) as day_of_week
  FROM "superset_table"
) as derived_table
GROUP BY 
  CASE 
    WHEN day_of_week IN (6, 7) THEN 'Weekend'
    ELSE 'Weekday'
  END;
