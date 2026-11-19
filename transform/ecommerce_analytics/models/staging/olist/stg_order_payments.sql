
-- Model: stg_order_payments
-- Purpose: Clean and standardise payment data.

WITH source AS (

    SELECT *
    FROM {{ source('olist', 'order_payments') }}

),

renamed AS (

    SELECT
        order_id,
        CAST(payment_sequential AS INTEGER) AS payment_sequential,
        LOWER(TRIM(payment_type)) AS payment_type,
        CAST(payment_installments AS INTEGER) AS payment_installments,
        CAST(payment_value AS NUMERIC(12, 2)) AS payment_value

    FROM source

)

SELECT *
FROM renamed
