{{ config(
      materialized='ephemeral'
      )      
}}

WITH bookings AS
(
    SELECT 
           booking_id,
           booking_date,
           booking_status,
           created_at
    FROM 
          {{ ref('one_big_table') }}
)

SELECT *
FROM bookings 