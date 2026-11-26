SELECT *
FROM {{ ref('fct_order_items') }}
WHERE product_id IS NULL