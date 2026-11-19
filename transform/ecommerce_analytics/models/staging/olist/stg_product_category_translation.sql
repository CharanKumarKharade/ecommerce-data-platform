
-- Model: stg_product_category_translation
-- Purpose: Clean product category translations.

WITH source AS (

    SELECT *
    FROM {{ source('olist', 'product_category_translation') }}

),

renamed AS (

    SELECT
        TRIM(product_category_name) AS product_category_name,
        TRIM(product_category_name_english) AS product_category_name_english

    FROM source

)

SELECT *
FROM renamed
