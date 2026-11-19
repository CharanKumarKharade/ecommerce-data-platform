
-- Model: int_customer_orders
-- Grain: One row per actual customer
-- Purpose: Calculate customer-level purchasing metrics.

WITH orders AS (

    SELECT *
    FROM {{ ref('int_orders_enriched') }}

),

customer_metrics AS (

    SELECT
        customer_unique_id,

        COUNT(DISTINCT customer_id) AS total_customer_ids,

        COUNT(DISTINCT order_id) AS total_orders,

        COUNT(DISTINCT CASE
            WHEN order_status = 'delivered'
            THEN order_id
        END) AS delivered_orders,

        COUNT(DISTINCT CASE
            WHEN order_status = 'canceled'
            THEN order_id
        END) AS cancelled_orders,

        MIN(order_purchase_timestamp) AS first_purchase_date,

        MAX(order_purchase_timestamp) AS last_purchase_date,

        SUM(total_payment_value) AS total_customer_spend,

        AVG(total_payment_value) AS average_order_payment,

        SUM(total_order_items) AS total_items_purchased

    FROM orders

    WHERE customer_unique_id IS NOT NULL

    GROUP BY customer_unique_id

)

SELECT
    customer_unique_id,
    total_customer_ids,
    total_orders,
    delivered_orders,
    cancelled_orders,
    first_purchase_date,
    last_purchase_date,
    total_customer_spend,
    average_order_payment,
    total_items_purchased

FROM customer_metrics
