Q1 (Last booked room): You need to find the latest date. Think about MAX(date) or sorting by date and limiting the result.
 >> SELECT user_id, room_no, booking_date
FROM (
    SELECT user_id, room_no, booking_date,
           ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY booking_date DESC) as rn
    FROM bookings
) t
WHERE rn = 1;

Q2 (Billing in Nov 2021): This requires joining bookings, booking_commercials, and items. You will need to calculate quantity * rate to get the amount.
>>SELECT 
    b.booking_id, 
    SUM(bc.item_quantity * i.item_rate) AS total_billing
FROM 
    bookings b
JOIN 
    booking_commercials bc ON b.booking_id = bc.booking_id
JOIN 
    items i ON bc.item_id = i.item_id
WHERE 
    b.booking_date >= '2021-11-01' AND b.booking_date < '2021-12-01'
GROUP BY 
    b.booking_id;

Q3 (Bills > 1000): Use the HAVING clause to filter after you have summed up the bill amounts.
>>SELECT bc.bill_id, SUM(bc.item_quantity * i.item_rate) AS bill_total
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
WHERE bc.bill_date BETWEEN '2021-10-01' AND '2021-10-31'
GROUP BY bc.bill_id
HAVING bill_total > 1000;

Q4 (Most/Least ordered): You need to group by Month and Item. This might require a "Window Function" (like RANK or ROW_NUMBER) to find the top and bottom items per month.
>>WITH MonthlyStats AS (
    SELECT 
        EXTRACT(MONTH FROM bill_date) as bill_month,
        item_id, 
        SUM(item_quantity) as total_qty,
        RANK() OVER(PARTITION BY EXTRACT(MONTH FROM bill_date) ORDER BY SUM(item_quantity) DESC) as most_rank,
        RANK() OVER(PARTITION BY EXTRACT(MONTH FROM bill_date) ORDER BY SUM(item_quantity) ASC) as least_rank
    FROM booking_commercials
    WHERE EXTRACT(YEAR FROM bill_date) = 2021
    GROUP BY 1, 2
)
SELECT bill_month, item_id, total_qty,
       CASE WHEN most_rank = 1 THEN 'Most Ordered' ELSE 'Least Ordered' END as status
FROM MonthlyStats
WHERE most_rank = 1 OR least_rank = 1;

Q5 (2nd Highest Bill): Similar to Q4, use a ranking function to find the bill in the 2nd position.
>>SELECT bill_id, bill_total
FROM (
    SELECT bc.bill_id, SUM(bc.item_quantity * i.item_rate) AS bill_total,
           DENSE_RANK() OVER(ORDER BY SUM(bc.item_quantity * i.item_rate) DESC) as rnk
    FROM booking_commercials bc
    JOIN items i ON bc.item_id = i.item_id
    GROUP BY bc.bill_id
) t
WHERE rnk = 2;