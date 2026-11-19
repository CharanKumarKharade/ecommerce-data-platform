
-- Model: stg_order_reviews
-- Purpose: Clean and standardise customer review data.

WITH source AS (

    SELECT *
    FROM {{ source('olist', 'order_reviews') }}

),

renamed AS (

    SELECT
        review_id,
        order_id,
        CAST(review_score AS INTEGER) AS review_score,
        NULLIF(TRIM(review_comment_title), '') AS review_comment_title,
        NULLIF(TRIM(review_comment_message), '') AS review_comment_message,
        CAST(review_creation_date AS TIMESTAMP) AS review_creation_date,
        CAST(review_answer_timestamp AS TIMESTAMP) AS review_answer_timestamp

    FROM source

)

SELECT *
FROM renamed
