{{ config(
    materialized='incremental',
    unique_key=['order_id', 'order_item_id']
) }}

WITH order_items AS (

    SELECT *
    FROM {{ ref('int_order_items_enriched') }}

),

final AS (

    SELECT
        order_id,
        order_item_id,
        customer_id,
        order_status,
        order_purchase_timestamp,
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
        seller_id,
        seller_city,
        seller_state,
        price,
        freight_value,
        item_total_value

    FROM order_items

    {% if is_incremental() %}

        WHERE order_purchase_timestamp >= (
            SELECT MAX(order_purchase_timestamp) - INTERVAL '3 days'
            FROM {{ this }}
        )

    {% endif %}

)

SELECT *
FROM final
