{% macro tag(column) %}
     CASE
            WHEN {{ column }} < 100 THEN 'Low'
            WHEN {{ column }} < 200 THEN 'Medium'
            ELSE 'High'
     END
{% endmacro %}