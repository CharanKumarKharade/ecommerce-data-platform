
-- Model: int_order_items_enriched
-- Grain: One row per order item
-- Purpose: Enrich order items with order, product, seller and category information.

WITH order_items AS (

    SELECT *
    FROM {{ ref('stg_order_items') }}

),

orders AS (

    SELECT *
    FROM {{ ref('stg_orders') }}

),

products AS (

    SELECT *
    FROM {{ ref('stg_products') }}

),

sellers AS (

    SELECT *
    FROM {{ ref('stg_sellers') }}

),

category_translation AS (

    SELECT *
    FROM {{ ref('stg_product_category_translation') }}

),

enriched AS (

    SELECT
        oi.order_id,
        oi.order_item_id,

        -- Order information
        o.customer_id,
        o.order_status,
        o.order_purchase_timestamp,
        o.order_approved_at,
        o.order_delivered_carrier_date,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,

        -- Product information
        oi.product_id,
        p.product_category_name,
        ct.product_category_name_english,
        p.product_name_length,
        p.product_description_length,
        p.product_photos_qty,
        p.product_weight_g,
        p.product_length_cm,
        p.product_height_cm,
        p.product_width_cm,

        -- Seller information
        oi.seller_id,
        s.seller_city,
        s.seller_state,

        -- Financial information
        oi.price,
        oi.freight_value,
        oi.price + oi.freight_value AS item_total_value

    FROM order_items oi

    INNER JOIN orders o
        ON oi.order_id = o.order_id

    LEFT JOIN products p
        ON oi.product_id = p.product_id

    LEFT JOIN sellers s
        ON oi.seller_id = s.seller_id

    LEFT JOIN category_translation ct
        ON p.product_category_name = ct.product_category_name

)

SELECT *
FROM enriched
