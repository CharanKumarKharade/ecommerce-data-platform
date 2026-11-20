
-- Model: fct_payments
-- Grain: One row per payment record

{{ config(materialized='table') }}

WITH payments AS (

    SELECT *
    FROM {{ ref('stg_order_payments') }}

),

final AS (

    SELECT
        order_id,
        payment_sequential,
        payment_type,
        payment_installments,
        payment_value,

        CASE
            WHEN payment_type = 'credit_card' THEN 'Card'
            WHEN payment_type = 'debit_card' THEN 'Card'
            WHEN payment_type = 'boleto' THEN 'Cash Voucher'
            WHEN payment_type = 'voucher' THEN 'Voucher'
            WHEN payment_type = 'not_defined' THEN 'Unknown'
            ELSE 'Other'
        END AS payment_category

    FROM payments

)

SELECT *
FROM final
