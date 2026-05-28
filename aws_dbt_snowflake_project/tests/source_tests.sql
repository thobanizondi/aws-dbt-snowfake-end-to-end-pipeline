-- This test FAILS if any booking_amount is less than 200
-- dbt expects 0 rows returned for a passing test

{{ config(severity='warn') }}

SELECT 
    booking_id,
    booking_amount
FROM {{ source('staging', 'BOOKINGS') }}
WHERE booking_amount < 200