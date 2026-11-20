{{ config( materialized='table') }}

WITH orders AS (

    SELECT *
    FROM {{ ref('int_orders_enriched') }}

),

final AS (

    SELECT
        order_id,
        customer_id,

        order_status,

        order_purchase_timestamp,
        order_approved_at,
        order_delivered_carrier_date,
        order_delivered_customer_date,
        order_estimated_delivery_date,

        -- Order metrics
        total_order_items,
        distinct_products,
        distinct_sellers,

        -- Financial metrics
        total_item_price,
        total_freight_value,
        total_order_item_value,
        total_payment_value,

        -- Payment metrics
        total_payment_records,
        distinct_payment_types,

        -- Customer satisfaction
        total_reviews,
        average_review_score,

        -- Delivery performance
        delivery_delay,

        CASE
            WHEN delivery_delay IS NULL THEN 'Unknown'
            WHEN delivery_delay > INTERVAL '0 seconds' THEN 'Late'
            WHEN delivery_delay < INTERVAL '0 seconds' THEN 'Early'
            ELSE 'On Time'
        END AS delivery_status

    FROM orders

)

SELECT *
FROM final
