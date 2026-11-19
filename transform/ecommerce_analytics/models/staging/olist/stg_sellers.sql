WITH source AS (

    SELECT *
    FROM {{ source('olist', 'sellers') }}

),

renamed AS (

    SELECT
        seller_id,

        CAST(seller_zip_code_prefix AS VARCHAR)
            AS seller_zip_code_prefix,

        TRIM(seller_city) AS seller_city,

        UPPER(TRIM(seller_state)) AS seller_state

    FROM source

)

SELECT *
FROM renamed