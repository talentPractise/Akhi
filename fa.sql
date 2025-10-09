SELECT DISTINCT
    PROVIDER_BUSINESS_GROUP_NBR,
    PROVIDER_BUSINESS_GROUP_SCORE_NBR,
    PROVIDER_IDENTIFICATION_NBR,
    PRODUCT_CD,
    SERVICE_LOCATION_NBR,
    NETWORK_ID,
    RATING_SYSTEM_CD,
    EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6697543
    AND NETWORK_ID = "00355"
    AND SERVICE_LOCATION_NBR = 9034514
    AND (
        SPECIALTY_CD = "90419"
        OR (
            SPECIALTY_CD IS NULL
            AND NOT EXISTS (
                SELECT 1
                FROM CET_PROVIDERS
                WHERE PROVIDER_IDENTIFICATION_NBR = 6697543
                  AND NETWORK_ID = "00355"
                  AND SERVICE_LOCATION_NBR = 9034514
                  AND SPECIALTY_CD = "90419"
            )
        )
    );





SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "99204"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND (
        SPECIALTY_CD = "90419"
        OR (
            SPECIALTY_CD IS NULL
            AND NOT EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "99204"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = "90419"
            )
        )
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;
