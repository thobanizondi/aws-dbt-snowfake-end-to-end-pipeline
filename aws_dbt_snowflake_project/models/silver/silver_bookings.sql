{{
    config(
        materialized='incremental', 
        unique_key='booking_id')
}}

SELECT
    booking_id,
    listing_id,
    booking_date,
    {{ multiply('nights_booked', 'booking_amount', 2) }} + cleaning_fee + service_fee AS total_price,
    booking_status,
    created_at
FROM {{ ref('bronze_bookings')}}
