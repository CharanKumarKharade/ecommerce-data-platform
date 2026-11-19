
-- Model: stg_geolocation
-- Purpose: Clean and standardise geolocation data.

WITH source AS (

    SELECT *
    FROM {{ source('olist', 'geolocation') }}

),

renamed AS (

    SELECT
        CAST(geolocation_zip_code_prefix AS VARCHAR) AS geolocation_zip_code_prefix,
        CAST(geolocation_lat AS NUMERIC) AS geolocation_lat,
        CAST(geolocation_lng AS NUMERIC) AS geolocation_lng,
        TRIM(geolocation_city) AS geolocation_city,
        UPPER(TRIM(geolocation_state)) AS geolocation_state

    FROM source

)

SELECT *
FROM renamed
