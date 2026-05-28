SELECT * FROM {{ ref('bronze_bookings')}}
SELECT * FROM {{ ref('bronze_hosts')}}
SELECT * FROM {{ ref('bronze_listings')}}