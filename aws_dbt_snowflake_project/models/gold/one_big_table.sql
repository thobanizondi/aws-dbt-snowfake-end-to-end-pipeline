{% set config = [
    {
        "table" : "AIRBNB_DB.DBT_SCHEMA_SILVER.silver_bookings",
        "columns" : "silver_bookings.*",
        "alias" : "silver_bookings"
    },
    {
        "table" : "AIRBNB_DB.DBT_SCHEMA_SILVER.silver_listings",
        "columns" : "silver_listings.property_type, silver_listings.city, silver_listings.country, silver_listings.accommodates, silver_listings.bedrooms, silver_listings.bathrooms, silver_listings.price_per_night, silver_listings.created_at as listing_created_at",
        "alias" : "silver_listings",
        "join_condition" : "silver_bookings.listing_id = silver_listings.listing_id"
    },
    {
        "table" : "AIRBNB_DB.DBT_SCHEMA_SILVER.silver_hosts",
        "columns" : "silver_hosts.host_id, silver_hosts.host_name, silver_hosts.is_superhost, silver_hosts.response_rate, silver_hosts.created_at as host_created_at",
        "alias" : "silver_hosts",
        "join_condition" : "silver_listings.host_id = silver_hosts.host_id"
    }
] %}

SELECT 
    {% for item in config %}
        {{ item['columns'] }}{% if not loop.last %},{% endif %}
    {% endfor %}
FROM 
    {% for item in config %}
    {% if loop.first %}
        {{ item['table'] }} AS {{ item['alias'] }}
    {% else %}
        LEFT JOIN {{ item['table'] }} AS {{ item['alias'] }} ON {{ item['join_condition'] }}
    {% endif %}
    {% endfor %}