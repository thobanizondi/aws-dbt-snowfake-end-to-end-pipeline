SELECT 
    obt.listing_id,
    obt.booking_id,
    obt.host_id,
    obt.total_price,
    obt.accommodates,
    obt.bedrooms,
    obt.bathrooms,
    obt.price_per_night,
    obt.response_rate
FROM AIRBNB_DB.DBT_SCHEMA_GOLD.ONE_BIG_TABLE AS obt