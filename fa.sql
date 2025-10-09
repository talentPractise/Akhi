SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = @servicecd
    AND SERVICE_TYPE_CD = @servicetype
    AND PLACE_OF_SERVICE_CD = @placeofservice
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND (
        -- If provider type exists, filter by it; otherwise fall back to NULL
        SPECIALTY_CD = @providertype
        OR (
            SPECIALTY_CD IS NULL
            AND NOT EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = @servicecd
                    AND SERVICE_TYPE_CD = @servicetype
                    AND PLACE_OF_SERVICE_CD = @placeofservice
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = @providertype
            )
        )
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;
