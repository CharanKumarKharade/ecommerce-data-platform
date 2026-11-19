
-- Model: int_orders_enriched
-- Grain: One row per order
-- Purpose: Combine customer, item, payment and review metrics.

WITH orders AS (

    SELECT *
    FROM {{ ref('stg_orders') }}

),

customers AS (

    SELECT *
    FROM {{ ref('stg_customers') }}

),

order_items AS (

    SELECT
        order_id,
        COUNT(*) AS total_order_items,
        COUNT(DISTINCT product_id) AS distinct_products,
        COUNT(DISTINCT seller_id) AS distinct_sellers,
        SUM(price) AS total_item_price,
        SUM(freight_value) AS total_freight_value,
        SUM(item_total_value) AS total_order_item_value

    FROM {{ ref('int_order_items_enriched') }}
    GROUP BY order_id

),

payments AS (

    SELECT
        order_id,
        COUNT(*) AS total_payment_records,
        SUM(payment_value) AS total_payment_value,
        COUNT(DISTINCT payment_type) AS distinct_payment_types

    FROM {{ ref('stg_order_payments') }}
    GROUP BY order_id

),

reviews AS (

    SELECT
        order_id,
        COUNT(*) AS total_reviews,
        AVG(review_score) AS average_review_score

    FROM {{ ref('stg_order_reviews') }}
    GROUP BY order_id

),

enriched AS (

    SELECT
        o.order_id,

        -- Customer information
        o.customer_id,
        c.customer_unique_id,
        c.customer_city,
        c.customer_state,

        -- Order information
        o.order_status,
        o.order_purchase_timestamp,
        o.order_approved_at,
        o.order_delivered_carrier_date,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,

        -- Delivery performance
        CASE
            WHEN o.order_delivered_customer_date IS NOT NULL
             AND o.order_estimated_delivery_date IS NOT NULL
            THEN
                o.order_delivered_customer_date
                - o.order_estimated_delivery_date
        END AS delivery_delay,

        -- Item metrics
        COALESCE(oi.total_order_items, 0) AS total_order_items,
        COALESCE(oi.distinct_products, 0) AS distinct_products,
        COALESCE(oi.distinct_sellers, 0) AS distinct_sellers,
        COALESCE(oi.total_item_price, 0) AS total_item_price,
        COALESCE(oi.total_freight_value, 0) AS total_freight_value,
        COALESCE(oi.total_order_item_value, 0) AS total_order_item_value,

        -- Payment metrics
        COALESCE(p.total_payment_records, 0) AS total_payment_records,
        COALESCE(p.total_payment_value, 0) AS total_payment_value,
        COALESCE(p.distinct_payment_types, 0) AS distinct_payment_types,

        -- Review metrics
        COALESCE(r.total_reviews, 0) AS total_reviews,
        r.average_review_score

    FROM orders o

    LEFT JOIN customers c
        ON o.customer_id = c.customer_id

    LEFT JOIN order_items oi
        ON o.order_id = oi.order_id

    LEFT JOIN payments p
        ON o.order_id = p.order_id

    LEFT JOIN reviews r
        ON o.order_id = r.order_id

)

SELECT *
FROM enriched
