-- ROW 285
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "82947"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "81"
    AND ZIP_CODE_UN = "11208";

-- cet_claim_based_amounts table
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7405820
    AND NETWORK_ID = "00357"
    AND PLACE_OF_SERVICE_CD = "81"
    AND SERVICE_CD = "82947"
    AND SERVICE_TYPE_CD = "CPT4";

-- Cet_Provider Table (if specialty_cd)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7405820
    AND NETWORK_ID = "00357"
    AND SERVICE_LOCATION_NBR = 4921825
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 7405820 
                       AND NETWORK_ID = "00357" 
                       AND SERVICE_LOCATION_NBR = 4921825  
                       AND SPECIALTY_CD = @providerspecialtycode
                    ) 
                THEN @providerspecialtycode ELSE '' END);

-- provider table (if provider_type_cd)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7405820
    AND NETWORK_ID = "00357"
    AND SERVICE_LOCATION_NBR = 4921825
    AND PROVIDER_TYPE_CD = "LB";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7405820
    AND NETWORK_ID = "00357"
    AND SERVICE_LOCATION_NBR = 4921825;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "82947"
    AND SERVICE_TYPE_CD = "CPT4"
    AND GEOGRAPHIC_AREA_CD = @geographicareacd
    AND PLACE_OF_SERVICE_CD = "81"
    AND (PRODUCT_CD = @productcd OR @productcd = 'ALL')
    AND CONTRACT_TYPE = 'S';

-- non standard rate (if SPECIALTY_CD)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "82947"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "81"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "82947"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "81"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = @providerspecialtycode
            )
            THEN @providerspecialtycode
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- non standard rate (elif provider_type_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "82947"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "81"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "82947"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "81"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = 
            )
            THEN @providerspecialtycode
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- else 
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = "82947"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "81"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE IN ('C', 'N')
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;

-- Default rate  (if PROVIDER_SPECIALTY_CD)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "82947"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "81"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "82947"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "81"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = @providerspecialtycode
            )
            THEN @providerspecialtycode
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- elif provider_type 
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "82947"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "81"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "82947"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "81"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = "LB"
            )
            THEN "LB"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- else 
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = "82947"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "81"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE = 'D' 
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;





-- ROW 321
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "85027"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "81"
    AND ZIP_CODE_UN = "7012";

-- cet_claim_based_amounts table table
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4734262
    AND NETWORK_ID = "00408"
    AND PLACE_OF_SERVICE_CD = "81"
    AND SERVICE_CD = "85027"
    AND SERVICE_TYPE_CD = "CPT4";

-- Cet_Provider Table (if specialty_cd)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4734262
    AND NETWORK_ID = "00408"
    AND SERVICE_LOCATION_NBR = 7186551
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 4734262 
                       AND NETWORK_ID = "00408" 
                       AND SERVICE_LOCATION_NBR = 7186551  
                       AND SPECIALTY_CD = @providerspecialtycode
                    ) 
                THEN @providerspecialtycode ELSE '' END);

-- provider table (if provider_type_cd)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4734262
    AND NETWORK_ID = "00408"
    AND SERVICE_LOCATION_NBR = 7186551
    AND PROVIDER_TYPE_CD = "LB";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4734262
    AND NETWORK_ID = "00408"
    AND SERVICE_LOCATION_NBR = 7186551;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "85027"
    AND SERVICE_TYPE_CD = "CPT4"
    AND GEOGRAPHIC_AREA_CD = @geographicareacd
    AND PLACE_OF_SERVICE_CD = "81"
    AND (PRODUCT_CD = @productcd OR @productcd = 'ALL')
    AND CONTRACT_TYPE = 'S';

-- non standard rate (if SPECIALTY_CD)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "85027"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "81"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "85027"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "81"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = @providerspecialtycode
            )
            THEN @providerspecialtycode
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- non standard rate (elif provider_type_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "85027"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "81"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "85027"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "81"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = @providerspecialtycode
            )
            THEN @providerspecialtycode
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- else 
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = "85027"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "81"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE IN ('C', 'N')
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;

-- Default rate  (if PROVIDER_SPECIALTY_CD)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "85027"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "81"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "85027"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "81"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = @providerspecialtycode
            )
            THEN @providerspecialtycode
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- elif provider_type 
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "85027"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "81"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "85027"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "81"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = "LB"
            )
            THEN "LB"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- else 
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = "85027"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "81"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE = 'D' 
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;





-- ROW 336
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "85027"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "81"
    AND ZIP_CODE_UN = "35233";

-- cet_claim_based_amounts table
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6544565
    AND NETWORK_ID = "00622"
    AND PLACE_OF_SERVICE_CD = "81"
    AND SERVICE_CD = "85027"
    AND SERVICE_TYPE_CD = "CPT4";

-- Cet_Provider Table (if specialty_cd)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6544565
    AND NETWORK_ID = "00622"
    AND SERVICE_LOCATION_NBR = 21431
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 6544565 
                       AND NETWORK_ID = "00622" 
                       AND SERVICE_LOCATION_NBR = 21431  
                       AND SPECIALTY_CD = @providerspecialtycode
                    ) 
                THEN @providerspecialtycode ELSE '' END);

-- provider table (if provider_type_cd)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6544565
    AND NETWORK_ID = "00622"
    AND SERVICE_LOCATION_NBR = 21431
    AND PROVIDER_TYPE_CD = "LB";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6544565
    AND NETWORK_ID = "00622"
    AND SERVICE_LOCATION_NBR = 21431;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "85027"
    AND SERVICE_TYPE_CD = "CPT4"
    AND GEOGRAPHIC_AREA_CD = @geographicareacd
    AND PLACE_OF_SERVICE_CD = "81"
    AND (PRODUCT_CD = @productcd OR @productcd = 'ALL')
    AND CONTRACT_TYPE = 'S';

-- non standard rate (if SPECIALTY_CD)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "85027"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "81"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "85027"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "81"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = @providerspecialtycode
            )
            THEN @providerspecialtycode
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- non standard rate (elif provider_type_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "85027"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "81"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "85027"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "81"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = @providerspecialtycode
            )
            THEN @providerspecialtycode
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- else 
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = "85027"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "81"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE IN ('C', 'N')
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;

-- Default rate  (if PROVIDER_SPECIALTY_CD)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "85027"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "81"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "85027"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "81"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = @providerspecialtycode
            )
            THEN @providerspecialtycode
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- elif provider_type 
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "85027"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "81"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "85027"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "81"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = "LB"
            )
            THEN "LB"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- else 
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = "85027"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "81"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE = 'D' 
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;





-- ROW 339
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "85027"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "81"
    AND ZIP_CODE_UN = "78945";

-- cet_claim_based_amounts table
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 8697277
    AND NETWORK_ID = "08164"
    AND PLACE_OF_SERVICE_CD = "81"
    AND SERVICE_CD = "85027"
    AND SERVICE_TYPE_CD = "CPT4";

-- Cet_Provider Table (if specialty_cd)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 8697277
    AND NETWORK_ID = "08164"
    AND SERVICE_LOCATION_NBR = 1227427
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 8697277 
                       AND NETWORK_ID = "08164" 
                       AND SERVICE_LOCATION_NBR = 1227427  
                       AND SPECIALTY_CD = @providerspecialtycode
                    ) 
                THEN @providerspecialtycode ELSE '' END);

-- provider table (if provider_type_cd)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 8697277
    AND NETWORK_ID = "08164"
    AND SERVICE_LOCATION_NBR = 1227427
    AND PROVIDER_TYPE_CD = "LB";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 8697277
    AND NETWORK_ID = "08164"
    AND SERVICE_LOCATION_NBR = 1227427;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "85027"
    AND SERVICE_TYPE_CD = "CPT4"
    AND GEOGRAPHIC_AREA_CD = @geographicareacd
    AND PLACE_OF_SERVICE_CD = "81"
    AND (PRODUCT_CD = @productcd OR @productcd = 'ALL')
    AND CONTRACT_TYPE = 'S';

-- non standard rate (if SPECIALTY_CD)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "85027"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "81"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "85027"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "81"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = @providerspecialtycode
            )
            THEN @providerspecialtycode
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- non standard rate (elif provider_type_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "85027"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "81"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "85027"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "81"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = @providerspecialtycode
            )
            THEN @providerspecialtycode
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- else 
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = "85027"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "81"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE IN ('C', 'N')
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;

-- Default rate  (if PROVIDER_SPECIALTY_CD)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "85027"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "81"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "85027"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "81"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = @providerspecialtycode
            )
            THEN @providerspecialtycode
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- elif provider_type 
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "85027"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "81"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "85027"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "81"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = "LB"
            )
            THEN "LB"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- else 
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = "85027"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "81"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE = 'D' 
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;





-- ROW 367
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "3075F"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND ZIP_CODE_UN = "10924";

-- cet_claim_based_amounts table
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4610543
    AND NETWORK_ID = "00357"
    AND PLACE_OF_SERVICE_CD = "11"
    AND SERVICE_CD = "3075F"
    AND SERVICE_TYPE_CD = "CPT4";

-- Cet_Provider Table (if specialty_cd)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4610543
    AND NETWORK_ID = "00357"
    AND SERVICE_LOCATION_NBR = 3946262
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 4610543 
                       AND NETWORK_ID = "00357" 
                       AND SERVICE_LOCATION_NBR = 3946262  
                       AND SPECIALTY_CD = "10307"
                    ) 
                THEN "10307" ELSE '' END);

-- provider table (if provider_type_cd)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4610543
    AND NETWORK_ID = "00357"
    AND SERVICE_LOCATION_NBR = 3946262
    AND PROVIDER_TYPE_CD = "PH";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4610543
    AND NETWORK_ID = "00357"
    AND SERVICE_LOCATION_NBR = 3946262;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "3075F"
    AND SERVICE_TYPE_CD = "CPT4"
    AND GEOGRAPHIC_AREA_CD = @geographicareacd
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR @productcd = 'ALL')
    AND CONTRACT_TYPE = 'S';

-- non standard rate (if SPECIALTY_CD)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "3075F"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "3075F"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = "10307"
            )
            THEN "10307"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- non standard rate (elif provider_type_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "3075F"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "3075F"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = "10307"
            )
            THEN "10307"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- else 
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = "3075F"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "11"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE IN ('C', 'N')
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;

-- Default rate  (if PROVIDER_SPECIALTY_CD)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "3075F"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "3075F"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = "10307"
            )
            THEN "10307"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- elif provider_type 
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "3075F"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "3075F"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = "PH"
            )
            THEN "PH"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- else 
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = "3075F"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "11"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE = 'D' 
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;





-- ROW 430
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "90380"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND ZIP_CODE_UN = "77054";

-- cet_claim_based_amounts table
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4231738
    AND NETWORK_ID = "00395"
    AND PLACE_OF_SERVICE_CD = "11"
    AND SERVICE_CD = "90380"
    AND SERVICE_TYPE_CD = "CPT4";

-- Cet_Provider Table (if specialty_cd)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4231738
    AND NETWORK_ID = "00395"
    AND SERVICE_LOCATION_NBR = 6662559
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 4231738 
                       AND NETWORK_ID = "00395" 
                       AND SERVICE_LOCATION_NBR = 6662559  
                       AND SPECIALTY_CD = "10401"
                    ) 
                THEN "10401" ELSE '' END);

-- provider table (if provider_type_cd)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4231738
    AND NETWORK_ID = "00395"
    AND SERVICE_LOCATION_NBR = 6662559
    AND PROVIDER_TYPE_CD = "PH";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4231738
    AND NETWORK_ID = "00395"
    AND SERVICE_LOCATION_NBR = 6662559;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "90380"
    AND SERVICE_TYPE_CD = "CPT4"
    AND GEOGRAPHIC_AREA_CD = @geographicareacd
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR @productcd = 'ALL')
    AND CONTRACT_TYPE = 'S';

-- non standard rate (if SPECIALTY_CD)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "90380"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "90380"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = "10401"
            )
            THEN "10401"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- non standard rate (elif provider_type_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "90380"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "90380"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = "10401"
            )
            THEN "10401"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- else 
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = "90380"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "11"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE IN ('C', 'N')
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;

-- Default rate  (if PROVIDER_SPECIALTY_CD)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "90380"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "90380"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = "10401"
            )
            THEN "10401"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- elif provider_type 
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "90380"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "90380"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = "PH"
            )
            THEN "PH"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- else 
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = "90380"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "11"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE = 'D' 
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;





-- ROW 455
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "98941"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND ZIP_CODE_UN = "99611";

-- cet_claim_based_amounts table
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 5819119
    AND NETWORK_ID = "13133"
    AND PLACE_OF_SERVICE_CD = "11"
    AND SERVICE_CD = "98941"
    AND SERVICE_TYPE_CD = "CPT4";

-- Cet_Provider Table (if specialty_cd)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 5819119
    AND NETWORK_ID = "13133"
    AND SERVICE_LOCATION_NBR = 9051885
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 5819119 
                       AND NETWORK_ID = "13133" 
                       AND SERVICE_LOCATION_NBR = 9051885  
                       AND SPECIALTY_CD = @providerspecialtycode
                    ) 
                THEN @providerspecialtycode ELSE '' END);

-- provider table (if provider_type_cd)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 5819119
    AND NETWORK_ID = "13133"
    AND SERVICE_LOCATION_NBR = 9051885
    AND PROVIDER_TYPE_CD = "DC";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 5819119
    AND NETWORK_ID = "13133"
    AND SERVICE_LOCATION_NBR = 9051885;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "98941"
    AND SERVICE_TYPE_CD = "CPT4"
    AND GEOGRAPHIC_AREA_CD = @geographicareacd
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR @productcd = 'ALL')
    AND CONTRACT_TYPE = 'S';

-- non standard rate (if SPECIALTY_CD)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "98941"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "98941"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = @providerspecialtycode
            )
            THEN @providerspecialtycode
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- non standard rate (elif provider_type_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "98941"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "98941"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = @providerspecialtycode
            )
            THEN @providerspecialtycode
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- else 
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = "98941"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "11"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE IN ('C', 'N')
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;

-- Default rate  (if PROVIDER_SPECIALTY_CD)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "98941"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "98941"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = @providerspecialtycode
            )
            THEN @providerspecialtycode
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- elif provider_type 
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "98941"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "98941"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = "DC"
            )
            THEN "DC"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- else 
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = "98941"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "11"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE = 'D' 
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;





-- ROW 566
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "99213"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND ZIP_CODE_UN = "10463";

-- cet_claim_based_amounts table
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4349221
    AND NETWORK_ID = "01344"
    AND PLACE_OF_SERVICE_CD = "11"
    AND SERVICE_CD = "99213"
    AND SERVICE_TYPE_CD = "CPT4";

-- Cet_Provider Table (if specialty_cd)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4349221
    AND NETWORK_ID = "01344"
    AND SERVICE_LOCATION_NBR = 1594295
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 4349221 
                       AND NETWORK_ID = "01344" 
                       AND SERVICE_LOCATION_NBR = 1594295  
                       AND SPECIALTY_CD = "10201"
                    ) 
                THEN "10201" ELSE '' END);

-- provider table (if provider_type_cd)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4349221
    AND NETWORK_ID = "01344"
    AND SERVICE_LOCATION_NBR = 1594295
    AND PROVIDER_TYPE_CD = "PH";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4349221
    AND NETWORK_ID = "01344"
    AND SERVICE_LOCATION_NBR = 1594295;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "99213"
    AND SERVICE_TYPE_CD = "CPT4"
    AND GEOGRAPHIC_AREA_CD = @geographicareacd
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR @productcd = 'ALL')
    AND CONTRACT_TYPE = 'S';

-- non standard rate (if SPECIALTY_CD)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "99213"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "99213"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = "10201"
            )
            THEN "10201"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- non standard rate (elif provider_type_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "99213"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "99213"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = "10201"
            )
            THEN "10201"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- else 
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = "99213"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "11"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE IN ('C', 'N')
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;

-- Default rate  (if PROVIDER_SPECIALTY_CD)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "99213"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "99213"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = "10201"
            )
            THEN "10201"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- elif provider_type 
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "99213"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "99213"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = "PH"
            )
            THEN "PH"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- else 
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = "99213"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "11"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE = 'D' 
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;





-- ROW 590
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "2000F"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND ZIP_CODE_UN = "12866";

-- cet_claim_based_amounts table
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 5800210
    AND NETWORK_ID = "00483"
    AND PLACE_OF_SERVICE_CD = "11"
    AND SERVICE_CD = "2000F"
    AND SERVICE_TYPE_CD = "CPT4";

-- Cet_Provider Table (if specialty_cd)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 5800210
    AND NETWORK_ID = "00483"
    AND SERVICE_LOCATION_NBR = 4172394
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 5800210 
                       AND NETWORK_ID = "00483" 
                       AND SERVICE_LOCATION_NBR = 4172394  
                       AND SPECIALTY_CD = "10201"
                    ) 
                THEN "10201" ELSE '' END);

-- provider table (if provider_type_cd)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 5800210
    AND NETWORK_ID = "00483"
    AND SERVICE_LOCATION_NBR = 4172394
    AND PROVIDER_TYPE_CD = "PH";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 5800210
    AND NETWORK_ID = "00483"
    AND SERVICE_LOCATION_NBR = 4172394;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "2000F"
    AND SERVICE_TYPE_CD = "CPT4"
    AND GEOGRAPHIC_AREA_CD = @geographicareacd
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR @productcd = 'ALL')
    AND CONTRACT_TYPE = 'S';

-- non standard rate (if SPECIALTY_CD)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "2000F"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "2000F"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = "10201"
            )
            THEN "10201"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- non standard rate (elif provider_type_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "2000F"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "2000F"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = "10201"
            )
            THEN "10201"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- else 
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = "2000F"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "11"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE IN ('C', 'N')
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;

-- Default rate  (if PROVIDER_SPECIALTY_CD)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "2000F"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "2000F"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = "10201"
            )
            THEN "10201"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- elif provider_type 
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "2000F"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "2000F"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = "PH"
            )
            THEN "PH"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- else 
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = "2000F"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "11"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE = 'D' 
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;





-- ROW 603
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "99395"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND ZIP_CODE_UN = "89052";

-- cet_claim_based_amounts table
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6649889
    AND NETWORK_ID = "02159"
    AND PLACE_OF_SERVICE_CD = "11"
    AND SERVICE_CD = "99395"
    AND SERVICE_TYPE_CD = "CPT4";

-- Cet_Provider Table (if specialty_cd)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6649889
    AND NETWORK_ID = "02159"
    AND SERVICE_LOCATION_NBR = 1735392
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 6649889 
                       AND NETWORK_ID = "02159" 
                       AND SERVICE_LOCATION_NBR = 1735392  
                       AND SPECIALTY_CD = "10201"
                    ) 
                THEN "10201" ELSE '' END);

-- provider table (if provider_type_cd)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6649889
    AND NETWORK_ID = "02159"
    AND SERVICE_LOCATION_NBR = 1735392
    AND PROVIDER_TYPE_CD = "PH";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6649889
    AND NETWORK_ID = "02159"
    AND SERVICE_LOCATION_NBR = 1735392;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "99395"
    AND SERVICE_TYPE_CD = "CPT4"
    AND GEOGRAPHIC_AREA_CD = @geographicareacd
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR @productcd = 'ALL')
    AND CONTRACT_TYPE = 'S';

-- non standard rate (if SPECIALTY_CD)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "99395"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "99395"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = "10201"
            )
            THEN "10201"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- non standard rate (elif provider_type_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "99395"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "99395"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = "10201"
            )
            THEN "10201"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- else 
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = "99395"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "11"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE IN ('C', 'N')
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;

-- Default rate  (if PROVIDER_SPECIALTY_CD)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "99395"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "99395"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = "10201"
            )
            THEN "10201"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- elif provider_type 
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "99395"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "99395"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = "PH"
            )
            THEN "PH"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- else 
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = "99395"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "11"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE = 'D' 
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;





-- ROW 609
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "85027"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "81"
    AND ZIP_CODE_UN = "97213";

-- cet_claim_based_amounts table
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6985711
    AND NETWORK_ID = "03999"
    AND PLACE_OF_SERVICE_CD = "81"
    AND SERVICE_CD = "85027"
    AND SERVICE_TYPE_CD = "CPT4";

-- Cet_Provider Table (if specialty_cd)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6985711
    AND NETWORK_ID = "03999"
    AND SERVICE_LOCATION_NBR = 2897250
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 6985711 
                       AND NETWORK_ID = "03999" 
                       AND SERVICE_LOCATION_NBR = 2897250  
                       AND SPECIALTY_CD = @providerspecialtycode
                    ) 
                THEN @providerspecialtycode ELSE '' END);

-- provider table (if provider_type_cd)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6985711
    AND NETWORK_ID = "03999"
    AND SERVICE_LOCATION_NBR = 2897250
    AND PROVIDER_TYPE_CD = "LB";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6985711
    AND NETWORK_ID = "03999"
    AND SERVICE_LOCATION_NBR = 2897250;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "85027"
    AND SERVICE_TYPE_CD = "CPT4"
    AND GEOGRAPHIC_AREA_CD = @geographicareacd
    AND PLACE_OF_SERVICE_CD = "81"
    AND (PRODUCT_CD = @productcd OR @productcd = 'ALL')
    AND CONTRACT_TYPE = 'S';

-- non standard rate (if SPECIALTY_CD)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "85027"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "81"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "85027"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "81"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = @providerspecialtycode
            )
            THEN @providerspecialtycode
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- non standard rate (elif provider_type_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "85027"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "81"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "85027"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "81"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = @providerspecialtycode
            )
            THEN @providerspecialtycode
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- else 
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = "85027"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "81"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE IN ('C', 'N')
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;

-- Default rate  (if PROVIDER_SPECIALTY_CD)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "85027"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "81"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "85027"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "81"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = @providerspecialtycode
            )
            THEN @providerspecialtycode
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- elif provider_type 
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "85027"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "81"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "85027"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "81"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = "LB"
            )
            THEN "LB"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- else 
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = "85027"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "81"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE = 'D' 
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;





-- ROW 625
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "76811"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND ZIP_CODE_UN = "30046";

-- cet_claim_based_amounts table
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4402101
    AND NETWORK_ID = "00393"
    AND PLACE_OF_SERVICE_CD = "11"
    AND SERVICE_CD = "76811"
    AND SERVICE_TYPE_CD = "CPT4";

-- Cet_Provider Table (if specialty_cd)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4402101
    AND NETWORK_ID = "00393"
    AND SERVICE_LOCATION_NBR = 4891135
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 4402101 
                       AND NETWORK_ID = "00393" 
                       AND SERVICE_LOCATION_NBR = 4891135  
                       AND SPECIALTY_CD = "20104"
                    ) 
                THEN "20104" ELSE '' END);

-- provider table (if provider_type_cd)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4402101
    AND NETWORK_ID = "00393"
    AND SERVICE_LOCATION_NBR = 4891135
    AND PROVIDER_TYPE_CD = "PH";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4402101
    AND NETWORK_ID = "00393"
    AND SERVICE_LOCATION_NBR = 4891135;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "76811"
    AND SERVICE_TYPE_CD = "CPT4"
    AND GEOGRAPHIC_AREA_CD = @geographicareacd
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR @productcd = 'ALL')
    AND CONTRACT_TYPE = 'S';

-- non standard rate (if SPECIALTY_CD)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "76811"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "76811"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = "20104"
            )
            THEN "20104"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- non standard rate (elif provider_type_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "76811"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "76811"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = "20104"
            )
            THEN "20104"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- else 
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = "76811"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "11"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE IN ('C', 'N')
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;

-- Default rate  (if PROVIDER_SPECIALTY_CD)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "76811"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "76811"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = "20104"
            )
            THEN "20104"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- elif provider_type 
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "76811"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "76811"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = "PH"
            )
            THEN "PH"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- else 
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = "76811"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "11"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE = 'D' 
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;





-- ROW 660
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "99411"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND ZIP_CODE_UN = "6902";

-- cet_claim_based_amounts table
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 5072460
    AND NETWORK_ID = "00387"
    AND PLACE_OF_SERVICE_CD = "11"
    AND SERVICE_CD = "99411"
    AND SERVICE_TYPE_CD = "CPT4";

-- Cet_Provider Table (if specialty_cd)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 5072460
    AND NETWORK_ID = "00387"
    AND SERVICE_LOCATION_NBR = 7023374
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 5072460 
                       AND NETWORK_ID = "00387" 
                       AND SERVICE_LOCATION_NBR = 7023374  
                       AND SPECIALTY_CD = "10303"
                    ) 
                THEN "10303" ELSE '' END);

-- provider table (if provider_type_cd)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 5072460
    AND NETWORK_ID = "00387"
    AND SERVICE_LOCATION_NBR = 7023374
    AND PROVIDER_TYPE_CD = "PH";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 5072460
    AND NETWORK_ID = "00387"
    AND SERVICE_LOCATION_NBR = 7023374;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "99411"
    AND SERVICE_TYPE_CD = "CPT4"
    AND GEOGRAPHIC_AREA_CD = @geographicareacd
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR @productcd = 'ALL')
    AND CONTRACT_TYPE = 'S';

-- non standard rate (if SPECIALTY_CD)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "99411"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "99411"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = "10303"
            )
            THEN "10303"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- non standard rate (elif provider_type_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "99411"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "99411"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = "10303"
            )
            THEN "10303"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- else 
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = "99411"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "11"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE IN ('C', 'N')
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;

-- Default rate  (if PROVIDER_SPECIALTY_CD)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "99411"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "99411"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = "10303"
            )
            THEN "10303"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- elif provider_type 
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "99411"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "99411"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = "PH"
            )
            THEN "PH"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- else 
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = "99411"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "11"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE = 'D' 
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;





-- ROW 673
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "99215"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND ZIP_CODE_UN = "11042";

-- cet_claim_based_amounts table
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7864393
    AND NETWORK_ID = "00357"
    AND PLACE_OF_SERVICE_CD = "11"
    AND SERVICE_CD = "99215"
    AND SERVICE_TYPE_CD = "CPT4";

-- Cet_Provider Table (if specialty_cd)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7864393
    AND NETWORK_ID = "00357"
    AND SERVICE_LOCATION_NBR = 9370433
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 7864393 
                       AND NETWORK_ID = "00357" 
                       AND SERVICE_LOCATION_NBR = 9370433  
                       AND SPECIALTY_CD = "30810"
                    ) 
                THEN "30810" ELSE '' END);

-- provider table (if provider_type_cd)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7864393
    AND NETWORK_ID = "00357"
    AND SERVICE_LOCATION_NBR = 9370433
    AND PROVIDER_TYPE_CD = "PH";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7864393
    AND NETWORK_ID = "00357"
    AND SERVICE_LOCATION_NBR = 9370433;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "99215"
    AND SERVICE_TYPE_CD = "CPT4"
    AND GEOGRAPHIC_AREA_CD = @geographicareacd
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR @productcd = 'ALL')
    AND CONTRACT_TYPE = 'S';

-- non standard rate (if SPECIALTY_CD)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "99215"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "99215"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = "30810"
            )
            THEN "30810"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- non standard rate (elif provider_type_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "99215"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "99215"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = "30810"
            )
            THEN "30810"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- else 
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = "99215"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "11"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE IN ('C', 'N')
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;

-- Default rate  (if PROVIDER_SPECIALTY_CD)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "99215"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "99215"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = "30810"
            )
            THEN "30810"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- elif provider_type 
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "99215"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "99215"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = "PH"
            )
            THEN "PH"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- else 
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = "99215"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "11"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE = 'D' 
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;





-- ROW 856
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "80048"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "81"
    AND ZIP_CODE_UN = "60515";

-- cet_claim_based_amounts table
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 9601070
    AND NETWORK_ID = "00638"
    AND PLACE_OF_SERVICE_CD = "81"
    AND SERVICE_CD = "80048"
    AND SERVICE_TYPE_CD = "CPT4";

-- Cet_Provider Table (if specialty_cd)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 9601070
    AND NETWORK_ID = "00638"
    AND SERVICE_LOCATION_NBR = 4444593
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 9601070 
                       AND NETWORK_ID = "00638" 
                       AND SERVICE_LOCATION_NBR = 4444593  
                       AND SPECIALTY_CD = @providerspecialtycode
                    ) 
                THEN @providerspecialtycode ELSE '' END);

-- provider table (if provider_type_cd)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 9601070
    AND NETWORK_ID = "00638"
    AND SERVICE_LOCATION_NBR = 4444593
    AND PROVIDER_TYPE_CD = "LB";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 9601070
    AND NETWORK_ID = "00638"
    AND SERVICE_LOCATION_NBR = 4444593;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "80048"
    AND SERVICE_TYPE_CD = "CPT4"
    AND GEOGRAPHIC_AREA_CD = @geographicareacd
    AND PLACE_OF_SERVICE_CD = "81"
    AND (PRODUCT_CD = @productcd OR @productcd = 'ALL')
    AND CONTRACT_TYPE = 'S';

-- non standard rate (if SPECIALTY_CD)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "80048"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "81"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "80048"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "81"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = @providerspecialtycode
            )
            THEN @providerspecialtycode
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- non standard rate (elif provider_type_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "80048"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "81"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "80048"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "81"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = @providerspecialtycode
            )
            THEN @providerspecialtycode
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- else 
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = "80048"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "81"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE IN ('C', 'N')
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;

-- Default rate  (if PROVIDER_SPECIALTY_CD)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "80048"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "81"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "80048"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "81"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = @providerspecialtycode
            )
            THEN @providerspecialtycode
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- elif provider_type 
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "80048"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "81"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "80048"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "81"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = "LB"
            )
            THEN "LB"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- else 
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = "80048"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "81"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE = 'D' 
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;





-- ROW 960
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "81528"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "81"
    AND ZIP_CODE_UN = "53713";

-- cet_claim_based_amounts table
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4719284
    AND NETWORK_ID = "00243"
    AND PLACE_OF_SERVICE_CD = "81"
    AND SERVICE_CD = "81528"
    AND SERVICE_TYPE_CD = "CPT4";

-- Cet_Provider Table (if specialty_cd)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4719284
    AND NETWORK_ID = "00243"
    AND SERVICE_LOCATION_NBR = 4734915
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 4719284 
                       AND NETWORK_ID = "00243" 
                       AND SERVICE_LOCATION_NBR = 4734915  
                       AND SPECIALTY_CD = @providerspecialtycode
                    ) 
                THEN @providerspecialtycode ELSE '' END);

-- provider table (if provider_type_cd)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4719284
    AND NETWORK_ID = "00243"
    AND SERVICE_LOCATION_NBR = 4734915
    AND PROVIDER_TYPE_CD = "LB";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4719284
    AND NETWORK_ID = "00243"
    AND SERVICE_LOCATION_NBR = 4734915;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "81528"
    AND SERVICE_TYPE_CD = "CPT4"
    AND GEOGRAPHIC_AREA_CD = @geographicareacd
    AND PLACE_OF_SERVICE_CD = "81"
    AND (PRODUCT_CD = @productcd OR @productcd = 'ALL')
    AND CONTRACT_TYPE = 'S';

-- non standard rate (if SPECIALTY_CD)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "81528"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "81"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "81528"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "81"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = @providerspecialtycode
            )
            THEN @providerspecialtycode
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- non standard rate (elif provider_type_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "81528"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "81"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "81528"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "81"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = @providerspecialtycode
            )
            THEN @providerspecialtycode
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- else 
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = "81528"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "81"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE IN ('C', 'N')
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;

-- Default rate  (if PROVIDER_SPECIALTY_CD)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "81528"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "81"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "81528"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "81"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = @providerspecialtycode
            )
            THEN @providerspecialtycode
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- elif provider_type 
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "81528"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "81"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "81528"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "81"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = "LB"
            )
            THEN "LB"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- else 
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = "81528"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "81"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE = 'D' 
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;





-- ROW 1044
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "85027"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "81"
    AND ZIP_CODE_UN = "92128";

-- cet_claim_based_amounts table
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6961187
    AND NETWORK_ID = "00346"
    AND PLACE_OF_SERVICE_CD = "81"
    AND SERVICE_CD = "85027"
    AND SERVICE_TYPE_CD = "CPT4";

-- Cet_Provider Table (if specialty_cd)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6961187
    AND NETWORK_ID = "00346"
    AND SERVICE_LOCATION_NBR = 3665196
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 6961187 
                       AND NETWORK_ID = "00346" 
                       AND SERVICE_LOCATION_NBR = 3665196  
                       AND SPECIALTY_CD = @providerspecialtycode
                    ) 
                THEN @providerspecialtycode ELSE '' END);

-- provider table (if provider_type_cd)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6961187
    AND NETWORK_ID = "00346"
    AND SERVICE_LOCATION_NBR = 3665196
    AND PROVIDER_TYPE_CD = "LB";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6961187
    AND NETWORK_ID = "00346"
    AND SERVICE_LOCATION_NBR = 3665196;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "85027"
    AND SERVICE_TYPE_CD = "CPT4"
    AND GEOGRAPHIC_AREA_CD = @geographicareacd
    AND PLACE_OF_SERVICE_CD = "81"
    AND (PRODUCT_CD = @productcd OR @productcd = 'ALL')
    AND CONTRACT_TYPE = 'S';

-- non standard rate (if SPECIALTY_CD)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "85027"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "81"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "85027"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "81"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = @providerspecialtycode
            )
            THEN @providerspecialtycode
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- non standard rate (elif provider_type_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "85027"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "81"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "85027"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "81"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = @providerspecialtycode
            )
            THEN @providerspecialtycode
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- else 
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = "85027"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "81"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE IN ('C', 'N')
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;

-- Default rate  (if PROVIDER_SPECIALTY_CD)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "85027"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "81"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "85027"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "81"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = @providerspecialtycode
            )
            THEN @providerspecialtycode
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- elif provider_type 
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "85027"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "81"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "85027"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "81"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = "LB"
            )
            THEN "LB"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- else 
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = "85027"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "81"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE = 'D' 
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;





-- ROW 1066
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "76014"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "22"
    AND ZIP_CODE_UN = "90505";

-- cet_claim_based_amounts table
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6152740
    AND NETWORK_ID = "00226"
    AND PLACE_OF_SERVICE_CD = "22"
    AND SERVICE_CD = "76014"
    AND SERVICE_TYPE_CD = "CPT4";

-- Cet_Provider Table (if specialty_cd)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6152740
    AND NETWORK_ID = "00226"
    AND SERVICE_LOCATION_NBR = 83545
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 6152740 
                       AND NETWORK_ID = "00226" 
                       AND SERVICE_LOCATION_NBR = 83545  
                       AND SPECIALTY_CD = @providerspecialtycode
                    ) 
                THEN @providerspecialtycode ELSE '' END);

-- provider table (if provider_type_cd)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6152740
    AND NETWORK_ID = "00226"
    AND SERVICE_LOCATION_NBR = 83545
    AND PROVIDER_TYPE_CD = "HO";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6152740
    AND NETWORK_ID = "00226"
    AND SERVICE_LOCATION_NBR = 83545;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "76014"
    AND SERVICE_TYPE_CD = "CPT4"
    AND GEOGRAPHIC_AREA_CD = @geographicareacd
    AND PLACE_OF_SERVICE_CD = "22"
    AND (PRODUCT_CD = @productcd OR @productcd = 'ALL')
    AND CONTRACT_TYPE = 'S';

-- non standard rate (if SPECIALTY_CD)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "76014"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "22"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "76014"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "22"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = @providerspecialtycode
            )
            THEN @providerspecialtycode
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- non standard rate (elif provider_type_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "76014"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "22"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "76014"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "22"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = @providerspecialtycode
            )
            THEN @providerspecialtycode
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- else 
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = "76014"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "22"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE IN ('C', 'N')
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;

-- Default rate  (if PROVIDER_SPECIALTY_CD)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "76014"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "22"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "76014"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "22"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = @providerspecialtycode
            )
            THEN @providerspecialtycode
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- elif provider_type 
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "76014"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "22"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "76014"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "22"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = "HO"
            )
            THEN "HO"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- else 
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = "76014"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "22"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE = 'D' 
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;





-- ROW 1088
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "99214"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND ZIP_CODE_UN = "13031";

-- cet_claim_based_amounts table
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4472332
    AND NETWORK_ID = "00483"
    AND PLACE_OF_SERVICE_CD = "11"
    AND SERVICE_CD = "99214"
    AND SERVICE_TYPE_CD = "CPT4";

-- Cet_Provider Table (if specialty_cd)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4472332
    AND NETWORK_ID = "00483"
    AND SERVICE_LOCATION_NBR = 5515069
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 4472332 
                       AND NETWORK_ID = "00483" 
                       AND SERVICE_LOCATION_NBR = 5515069  
                       AND SPECIALTY_CD = "10303"
                    ) 
                THEN "10303" ELSE '' END);

-- provider table (if provider_type_cd)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4472332
    AND NETWORK_ID = "00483"
    AND SERVICE_LOCATION_NBR = 5515069
    AND PROVIDER_TYPE_CD = "PH";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4472332
    AND NETWORK_ID = "00483"
    AND SERVICE_LOCATION_NBR = 5515069;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "99214"
    AND SERVICE_TYPE_CD = "CPT4"
    AND GEOGRAPHIC_AREA_CD = @geographicareacd
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR @productcd = 'ALL')
    AND CONTRACT_TYPE = 'S';

-- non standard rate (if SPECIALTY_CD)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "99214"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "99214"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = "10303"
            )
            THEN "10303"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- non standard rate (elif provider_type_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "99214"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "99214"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = "10303"
            )
            THEN "10303"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- else 
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = "99214"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "11"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE IN ('C', 'N')
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;

-- Default rate  (if PROVIDER_SPECIALTY_CD)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "99214"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "99214"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = "10303"
            )
            THEN "10303"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- elif provider_type 
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "99214"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "99214"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = "PH"
            )
            THEN "PH"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- else 
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = "99214"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "11"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE = 'D' 
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;





-- ROW 1104
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "97153"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND ZIP_CODE_UN = "27607";

-- cet_claim_based_amounts table
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 9944998
    AND NETWORK_ID = "09696"
    AND PLACE_OF_SERVICE_CD = "11"
    AND SERVICE_CD = "97153"
    AND SERVICE_TYPE_CD = "CPT4";

-- Cet_Provider Table (if specialty_cd)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 9944998
    AND NETWORK_ID = "09696"
    AND SERVICE_LOCATION_NBR = 1675670
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 9944998 
                       AND NETWORK_ID = "09696" 
                       AND SERVICE_LOCATION_NBR = 1675670  
                       AND SPECIALTY_CD = @providerspecialtycode
                    ) 
                THEN @providerspecialtycode ELSE '' END);

-- provider table (if provider_type_cd)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 9944998
    AND NETWORK_ID = "09696"
    AND SERVICE_LOCATION_NBR = 1675670
    AND PROVIDER_TYPE_CD = "ABA";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 9944998
    AND NETWORK_ID = "09696"
    AND SERVICE_LOCATION_NBR = 1675670;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "97153"
    AND SERVICE_TYPE_CD = "CPT4"
    AND GEOGRAPHIC_AREA_CD = @geographicareacd
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR @productcd = 'ALL')
    AND CONTRACT_TYPE = 'S';

-- non standard rate (if SPECIALTY_CD)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "97153"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "97153"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = @providerspecialtycode
            )
            THEN @providerspecialtycode
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- non standard rate (elif provider_type_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "97153"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "97153"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = @providerspecialtycode
            )
            THEN @providerspecialtycode
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- else 
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = "97153"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "11"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE IN ('C', 'N')
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;

-- Default rate  (if PROVIDER_SPECIALTY_CD)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "97153"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "97153"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = @providerspecialtycode
            )
            THEN @providerspecialtycode
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- elif provider_type 
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "97153"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "97153"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = "ABA"
            )
            THEN "ABA"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- else 
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = "97153"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "11"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE = 'D' 
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;





-- ROW 1110
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "90698"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND ZIP_CODE_UN = "11368";

-- cet_claim_based_amounts table
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 5323162
    AND NETWORK_ID = "01344"
    AND PLACE_OF_SERVICE_CD = "11"
    AND SERVICE_CD = "90698"
    AND SERVICE_TYPE_CD = "CPT4";

-- Cet_Provider Table (if specialty_cd)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 5323162
    AND NETWORK_ID = "01344"
    AND SERVICE_LOCATION_NBR = 1734857
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 5323162 
                       AND NETWORK_ID = "01344" 
                       AND SERVICE_LOCATION_NBR = 1734857  
                       AND SPECIALTY_CD = "10401"
                    ) 
                THEN "10401" ELSE '' END);

-- provider table (if provider_type_cd)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 5323162
    AND NETWORK_ID = "01344"
    AND SERVICE_LOCATION_NBR = 1734857
    AND PROVIDER_TYPE_CD = "PH";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 5323162
    AND NETWORK_ID = "01344"
    AND SERVICE_LOCATION_NBR = 1734857;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "90698"
    AND SERVICE_TYPE_CD = "CPT4"
    AND GEOGRAPHIC_AREA_CD = @geographicareacd
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR @productcd = 'ALL')
    AND CONTRACT_TYPE = 'S';

-- non standard rate (if SPECIALTY_CD)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "90698"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "90698"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = "10401"
            )
            THEN "10401"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- non standard rate (elif provider_type_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "90698"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "90698"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = "10401"
            )
            THEN "10401"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- else 
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = "90698"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "11"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE IN ('C', 'N')
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;

-- Default rate  (if PROVIDER_SPECIALTY_CD)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "90698"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "90698"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = "10401"
            )
            THEN "10401"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- elif provider_type 
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "90698"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "90698"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = "PH"
            )
            THEN "PH"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- else 
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = "90698"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "11"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE = 'D' 
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;





-- ROW 1134
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "805"
    AND SERVICE_TYPE_CD = "DRG"
    AND PLACE_OF_SERVICE_CD = "21"
    AND ZIP_CODE_UN = "30308";

-- cet_claim_based_amounts table
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6210155
    AND NETWORK_ID = "00393"
    AND PLACE_OF_SERVICE_CD = "21"
    AND SERVICE_CD = "805"
    AND SERVICE_TYPE_CD = "DRG";

-- Cet_Provider Table (if specialty_cd)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6210155
    AND NETWORK_ID = "00393"
    AND SERVICE_LOCATION_NBR = 2441661
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 6210155 
                       AND NETWORK_ID = "00393" 
                       AND SERVICE_LOCATION_NBR = 2441661  
                       AND SPECIALTY_CD = @providerspecialtycode
                    ) 
                THEN @providerspecialtycode ELSE '' END);

-- provider table (if provider_type_cd)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6210155
    AND NETWORK_ID = "00393"
    AND SERVICE_LOCATION_NBR = 2441661
    AND PROVIDER_TYPE_CD = "HO";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6210155
    AND NETWORK_ID = "00393"
    AND SERVICE_LOCATION_NBR = 2441661;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "805"
    AND SERVICE_TYPE_CD = "DRG"
    AND GEOGRAPHIC_AREA_CD = @geographicareacd
    AND PLACE_OF_SERVICE_CD = "21"
    AND (PRODUCT_CD = @productcd OR @productcd = 'ALL')
    AND CONTRACT_TYPE = 'S';

-- non standard rate (if SPECIALTY_CD)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "805"
    AND SERVICE_TYPE_CD = "DRG"
    AND PLACE_OF_SERVICE_CD = "21"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "805"
                    AND SERVICE_TYPE_CD = "DRG"
                    AND PLACE_OF_SERVICE_CD = "21"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = @providerspecialtycode
            )
            THEN @providerspecialtycode
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- non standard rate (elif provider_type_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "805"
    AND SERVICE_TYPE_CD = "DRG"
    AND PLACE_OF_SERVICE_CD = "21"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "805"
                    AND SERVICE_TYPE_CD = "DRG"
                    AND PLACE_OF_SERVICE_CD = "21"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = @providerspecialtycode
            )
            THEN @providerspecialtycode
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- else 
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = "805"
  AND SERVICE_TYPE_CD = "DRG"
  AND PLACE_OF_SERVICE_CD = "21"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE IN ('C', 'N')
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;

-- Default rate  (if PROVIDER_SPECIALTY_CD)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "805"
    AND SERVICE_TYPE_CD = "DRG"
    AND PLACE_OF_SERVICE_CD = "21"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "805"
                    AND SERVICE_TYPE_CD = "DRG"
                    AND PLACE_OF_SERVICE_CD = "21"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = @providerspecialtycode
            )
            THEN @providerspecialtycode
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- elif provider_type 
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "805"
    AND SERVICE_TYPE_CD = "DRG"
    AND PLACE_OF_SERVICE_CD = "21"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "805"
                    AND SERVICE_TYPE_CD = "DRG"
                    AND PLACE_OF_SERVICE_CD = "21"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = "HO"
            )
            THEN "HO"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- else 
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = "805"
  AND SERVICE_TYPE_CD = "DRG"
  AND PLACE_OF_SERVICE_CD = "21"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE = 'D' 
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;





-- ROW 1209
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "99213"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND ZIP_CODE_UN = "7733";

-- cet_claim_based_amounts table
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4391185
    AND NETWORK_ID = "01449"
    AND PLACE_OF_SERVICE_CD = "11"
    AND SERVICE_CD = "99213"
    AND SERVICE_TYPE_CD = "CPT4";

-- Cet_Provider Table (if specialty_cd)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4391185
    AND NETWORK_ID = "01449"
    AND SERVICE_LOCATION_NBR = 5740818
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 4391185 
                       AND NETWORK_ID = "01449" 
                       AND SERVICE_LOCATION_NBR = 5740818  
                       AND SPECIALTY_CD = "10401"
                    ) 
                THEN "10401" ELSE '' END);

-- provider table (if provider_type_cd)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4391185
    AND NETWORK_ID = "01449"
    AND SERVICE_LOCATION_NBR = 5740818
    AND PROVIDER_TYPE_CD = "PH";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4391185
    AND NETWORK_ID = "01449"
    AND SERVICE_LOCATION_NBR = 5740818;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "99213"
    AND SERVICE_TYPE_CD = "CPT4"
    AND GEOGRAPHIC_AREA_CD = @geographicareacd
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR @productcd = 'ALL')
    AND CONTRACT_TYPE = 'S';

-- non standard rate (if SPECIALTY_CD)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "99213"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "99213"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = "10401"
            )
            THEN "10401"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- non standard rate (elif provider_type_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "99213"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "99213"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = "10401"
            )
            THEN "10401"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- else 
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = "99213"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "11"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE IN ('C', 'N')
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;

-- Default rate  (if PROVIDER_SPECIALTY_CD)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "99213"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "99213"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = "10401"
            )
            THEN "10401"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- elif provider_type 
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "99213"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "99213"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = "PH"
            )
            THEN "PH"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- else 
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = "99213"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "11"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE = 'D' 
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;





-- ROW 1234
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "99204"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND ZIP_CODE_UN = "85018";

-- cet_claim_based_amounts table
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6697543
    AND NETWORK_ID = "00355"
    AND PLACE_OF_SERVICE_CD = "11"
    AND SERVICE_CD = "99204"
    AND SERVICE_TYPE_CD = "CPT4";

-- Cet_Provider Table (if specialty_cd)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6697543
    AND NETWORK_ID = "00355"
    AND SERVICE_LOCATION_NBR = 9034514
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 6697543 
                       AND NETWORK_ID = "00355" 
                       AND SERVICE_LOCATION_NBR = 9034514  
                       AND SPECIALTY_CD = "90419"
                    ) 
                THEN "90419" ELSE '' END);

-- provider table (if provider_type_cd)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6697543
    AND NETWORK_ID = "00355"
    AND SERVICE_LOCATION_NBR = 9034514
    AND PROVIDER_TYPE_CD = "NP";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6697543
    AND NETWORK_ID = "00355"
    AND SERVICE_LOCATION_NBR = 9034514;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "99204"
    AND SERVICE_TYPE_CD = "CPT4"
    AND GEOGRAPHIC_AREA_CD = @geographicareacd
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR @productcd = 'ALL')
    AND CONTRACT_TYPE = 'S';

-- non standard rate (if SPECIALTY_CD)
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
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
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
            THEN "90419"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- non standard rate (elif provider_type_cd)
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
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
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
            THEN "90419"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- else 
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = "99204"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "11"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE IN ('C', 'N')
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;

-- Default rate  (if PROVIDER_SPECIALTY_CD)
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
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "99204"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = "90419"
            )
            THEN "90419"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- elif provider_type 
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
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "99204"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = "NP"
            )
            THEN "NP"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- else 
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = "99204"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "11"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE = 'D' 
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;

