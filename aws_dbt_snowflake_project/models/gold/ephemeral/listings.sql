{{ config(
      materialized='ephemeral'
      )      
}}

WITH listings AS
(
    SELECT 
           listing_id,
           property_type,
           city,
           country,
           price_per_night,
           listing_created_at
    FROM 
          {{ ref('one_big_table') }}
)

SELECT *
FROM listings 