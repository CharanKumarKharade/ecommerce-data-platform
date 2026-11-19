SELECT *
FROM {{ ref('int_order_items_enriched') }}
WHERE item_total_value != (price + freight_value)