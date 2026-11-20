{{ config(
    materialized='table'
) }}

WITH order_items AS (

    SELECT *
    FROM {{ ref('int_order_items_enriched') }}

),

final AS (

    SELECT
        order_id,
        order_item_id,

        -- Customer and order information
        customer_id,
        order_status,
        order_purchase_timestamp,

        -- Product information
        product_id,
        product_category_name,
        product_category_name_english,

        product_name_length,
        product_description_length,
        product_photos_qty,

        product_weight_g,
        product_length_cm,
        product_height_cm,
        product_width_cm,

        -- Seller information
        seller_id,
        seller_city,
        seller_state,

        -- Financial measures
        price,
        freight_value,
        item_total_value

    FROM order_items

)

SELECT *
FROM final
