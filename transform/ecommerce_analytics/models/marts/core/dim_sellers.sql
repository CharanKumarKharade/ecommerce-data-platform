
-- Model: dim_sellers
-- Grain: One row per seller_id

{{ config(materialized='table') }}

WITH sellers AS (

    SELECT *
    FROM {{ ref('stg_sellers') }}

),

final AS (

    SELECT
        seller_id,
        seller_zip_code_prefix,
        seller_city,
        seller_state

    FROM sellers

)

SELECT *
FROM final
