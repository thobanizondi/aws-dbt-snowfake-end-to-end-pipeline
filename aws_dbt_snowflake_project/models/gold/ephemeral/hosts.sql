{{ config(
      materialized='ephemeral'
      )      
}}

WITH hosts AS
(
    SELECT 
           host_id,
           host_name,
           is_superhost,
           host_created_at
    FROM 
          {{ ref('one_big_table') }}
)

SELECT *
FROM hosts 