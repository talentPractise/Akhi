-- ROW 285
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "82947"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "81"
    AND ZIP_CODE_UN = "11208";

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7405820
    AND NETWORK_ID = "00357"
    AND PLACE_OF_SERVICE_CD = "81"
    AND SERVICE_CD = "82947"
    AND SERVICE_TYPE_CD = "CPT4";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
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

-- elif providertype
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
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

-- non standard rate (elif provider_type)
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


-- ROW 254
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "90460"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND ZIP_CODE_UN = "2476";

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 9326579
    AND NETWORK_ID = "00339"
    AND PLACE_OF_SERVICE_CD = "11"
    AND SERVICE_CD = "90460"
    AND SERVICE_TYPE_CD = "CPT4";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 9326579
    AND NETWORK_ID = "00339"
    AND SERVICE_LOCATION_NBR = 6570038
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 9326579 
                       AND NETWORK_ID = "00339" 
                       AND SERVICE_LOCATION_NBR = 6570038  
                       AND SPECIALTY_CD = "10401"
                    ) 
                THEN "10401" ELSE '' END);

-- elif providertype
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 9326579
    AND NETWORK_ID = "00339"
    AND SERVICE_LOCATION_NBR = 6570038
    AND PROVIDER_TYPE_CD = "PH";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 9326579
    AND NETWORK_ID = "00339"
    AND SERVICE_LOCATION_NBR = 6570038;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "90460"
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
    SERVICE_CD = "90460"
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
                WHERE SERVICE_CD = "90460"
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

-- non standard rate (elif provider_type)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "90460"
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
                WHERE SERVICE_CD = "90460"
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
  SERVICE_CD = "90460"
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
    SERVICE_CD = "90460"
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
                WHERE SERVICE_CD = "90460"
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
    SERVICE_CD = "90460"
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
                WHERE SERVICE_CD = "90460"
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
  SERVICE_CD = "90460"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "11"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE = 'D' 
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;


-- ROW 263
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "J0665"
    AND SERVICE_TYPE_CD = "HCPC"
    AND PLACE_OF_SERVICE_CD = "22"
    AND ZIP_CODE_UN = "28655";

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6380595
    AND NETWORK_ID = "00454"
    AND PLACE_OF_SERVICE_CD = "22"
    AND SERVICE_CD = "J0665"
    AND SERVICE_TYPE_CD = "HCPC";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6380595
    AND NETWORK_ID = "00454"
    AND SERVICE_LOCATION_NBR = 158015
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 6380595 
                       AND NETWORK_ID = "00454" 
                       AND SERVICE_LOCATION_NBR = 158015  
                       AND SPECIALTY_CD = @providerspecialtycode
                    ) 
                THEN @providerspecialtycode ELSE '' END);

-- elif providertype
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6380595
    AND NETWORK_ID = "00454"
    AND SERVICE_LOCATION_NBR = 158015
    AND PROVIDER_TYPE_CD = "HO";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6380595
    AND NETWORK_ID = "00454"
    AND SERVICE_LOCATION_NBR = 158015;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "J0665"
    AND SERVICE_TYPE_CD = "HCPC"
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
    SERVICE_CD = "J0665"
    AND SERVICE_TYPE_CD = "HCPC"
    AND PLACE_OF_SERVICE_CD = "22"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "J0665"
                    AND SERVICE_TYPE_CD = "HCPC"
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

-- non standard rate (elif provider_type)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "J0665"
    AND SERVICE_TYPE_CD = "HCPC"
    AND PLACE_OF_SERVICE_CD = "22"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "J0665"
                    AND SERVICE_TYPE_CD = "HCPC"
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
  SERVICE_CD = "J0665"
  AND SERVICE_TYPE_CD = "HCPC"
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
    SERVICE_CD = "J0665"
    AND SERVICE_TYPE_CD = "HCPC"
    AND PLACE_OF_SERVICE_CD = "22"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "J0665"
                    AND SERVICE_TYPE_CD = "HCPC"
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
    SERVICE_CD = "J0665"
    AND SERVICE_TYPE_CD = "HCPC"
    AND PLACE_OF_SERVICE_CD = "22"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "J0665"
                    AND SERVICE_TYPE_CD = "HCPC"
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
  SERVICE_CD = "J0665"
  AND SERVICE_TYPE_CD = "HCPC"
  AND PLACE_OF_SERVICE_CD = "22"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE = 'D' 
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;


-- ROW 280
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "97112"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND ZIP_CODE_UN = "27614";

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 9772264
    AND NETWORK_ID = "00606"
    AND PLACE_OF_SERVICE_CD = "11"
    AND SERVICE_CD = "97112"
    AND SERVICE_TYPE_CD = "CPT4";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 9772264
    AND NETWORK_ID = "00606"
    AND SERVICE_LOCATION_NBR = 6876720
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 9772264 
                       AND NETWORK_ID = "00606" 
                       AND SERVICE_LOCATION_NBR = 6876720  
                       AND SPECIALTY_CD = @providerspecialtycode
                    ) 
                THEN @providerspecialtycode ELSE '' END);

-- elif providertype
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 9772264
    AND NETWORK_ID = "00606"
    AND SERVICE_LOCATION_NBR = 6876720
    AND PROVIDER_TYPE_CD = "PT";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 9772264
    AND NETWORK_ID = "00606"
    AND SERVICE_LOCATION_NBR = 6876720;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "97112"
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
    SERVICE_CD = "97112"
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
                WHERE SERVICE_CD = "97112"
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

-- non standard rate (elif provider_type)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "97112"
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
                WHERE SERVICE_CD = "97112"
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
  SERVICE_CD = "97112"
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
    SERVICE_CD = "97112"
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
                WHERE SERVICE_CD = "97112"
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
    SERVICE_CD = "97112"
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
                WHERE SERVICE_CD = "97112"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = "PT"
            )
            THEN "PT"
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
  SERVICE_CD = "97112"
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

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4349221
    AND NETWORK_ID = "01344"
    AND PLACE_OF_SERVICE_CD = "11"
    AND SERVICE_CD = "99213"
    AND SERVICE_TYPE_CD = "CPT4";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
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

-- elif providertype
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

-- non standard rate (elif provider_type)
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


-- ROW 291
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "81025"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND ZIP_CODE_UN = "93710";

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7765082
    AND NETWORK_ID = "01472"
    AND PLACE_OF_SERVICE_CD = "11"
    AND SERVICE_CD = "81025"
    AND SERVICE_TYPE_CD = "CPT4";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7765082
    AND NETWORK_ID = "01472"
    AND SERVICE_LOCATION_NBR = 4645059
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 7765082 
                       AND NETWORK_ID = "01472" 
                       AND SERVICE_LOCATION_NBR = 4645059  
                       AND SPECIALTY_CD = "20101"
                    ) 
                THEN "20101" ELSE '' END);

-- elif providertype
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7765082
    AND NETWORK_ID = "01472"
    AND SERVICE_LOCATION_NBR = 4645059
    AND PROVIDER_TYPE_CD = "PH";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7765082
    AND NETWORK_ID = "01472"
    AND SERVICE_LOCATION_NBR = 4645059;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "81025"
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
    SERVICE_CD = "81025"
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
                WHERE SERVICE_CD = "81025"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = "20101"
            )
            THEN "20101"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- non standard rate (elif provider_type)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "81025"
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
                WHERE SERVICE_CD = "81025"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = "20101"
            )
            THEN "20101"
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
  SERVICE_CD = "81025"
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
    SERVICE_CD = "81025"
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
                WHERE SERVICE_CD = "81025"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = "20101"
            )
            THEN "20101"
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
    SERVICE_CD = "81025"
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
                WHERE SERVICE_CD = "81025"
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
  SERVICE_CD = "81025"
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

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 5800210
    AND NETWORK_ID = "00483"
    AND PLACE_OF_SERVICE_CD = "11"
    AND SERVICE_CD = "2000F"
    AND SERVICE_TYPE_CD = "CPT4";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
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

-- elif providertype
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

-- non standard rate (elif provider_type)
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


-- ROW 327
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "99491"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND ZIP_CODE_UN = "11580";

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 5235644
    AND NETWORK_ID = "01344"
    AND PLACE_OF_SERVICE_CD = "11"
    AND SERVICE_CD = "99491"
    AND SERVICE_TYPE_CD = "CPT4";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 5235644
    AND NETWORK_ID = "01344"
    AND SERVICE_LOCATION_NBR = 4822843
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 5235644 
                       AND NETWORK_ID = "01344" 
                       AND SERVICE_LOCATION_NBR = 4822843  
                       AND SPECIALTY_CD = "10201"
                    ) 
                THEN "10201" ELSE '' END);

-- elif providertype
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 5235644
    AND NETWORK_ID = "01344"
    AND SERVICE_LOCATION_NBR = 4822843
    AND PROVIDER_TYPE_CD = "PH";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 5235644
    AND NETWORK_ID = "01344"
    AND SERVICE_LOCATION_NBR = 4822843;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "99491"
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
    SERVICE_CD = "99491"
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
                WHERE SERVICE_CD = "99491"
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

-- non standard rate (elif provider_type)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "99491"
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
                WHERE SERVICE_CD = "99491"
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
  SERVICE_CD = "99491"
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
    SERVICE_CD = "99491"
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
                WHERE SERVICE_CD = "99491"
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
    SERVICE_CD = "99491"
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
                WHERE SERVICE_CD = "99491"
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
  SERVICE_CD = "99491"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "11"
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

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4402101
    AND NETWORK_ID = "00393"
    AND PLACE_OF_SERVICE_CD = "11"
    AND SERVICE_CD = "76811"
    AND SERVICE_TYPE_CD = "CPT4";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
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

-- elif providertype
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

-- non standard rate (elif provider_type)
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


-- ROW 1209
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "99213"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND ZIP_CODE_UN = "7733";

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4391185
    AND NETWORK_ID = "01449"
    AND PLACE_OF_SERVICE_CD = "11"
    AND SERVICE_CD = "99213"
    AND SERVICE_TYPE_CD = "CPT4";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
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

-- elif providertype
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

-- non standard rate (elif provider_type)
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


-- ROW 363
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "J1885"
    AND SERVICE_TYPE_CD = "HCPC"
    AND PLACE_OF_SERVICE_CD = "22"
    AND ZIP_CODE_UN = "31201";

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6210745
    AND NETWORK_ID = "01812"
    AND PLACE_OF_SERVICE_CD = "22"
    AND SERVICE_CD = "J1885"
    AND SERVICE_TYPE_CD = "HCPC";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6210745
    AND NETWORK_ID = "01812"
    AND SERVICE_LOCATION_NBR = 7490153
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 6210745 
                       AND NETWORK_ID = "01812" 
                       AND SERVICE_LOCATION_NBR = 7490153  
                       AND SPECIALTY_CD = @providerspecialtycode
                    ) 
                THEN @providerspecialtycode ELSE '' END);

-- elif providertype
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6210745
    AND NETWORK_ID = "01812"
    AND SERVICE_LOCATION_NBR = 7490153
    AND PROVIDER_TYPE_CD = "HO";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6210745
    AND NETWORK_ID = "01812"
    AND SERVICE_LOCATION_NBR = 7490153;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "J1885"
    AND SERVICE_TYPE_CD = "HCPC"
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
    SERVICE_CD = "J1885"
    AND SERVICE_TYPE_CD = "HCPC"
    AND PLACE_OF_SERVICE_CD = "22"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "J1885"
                    AND SERVICE_TYPE_CD = "HCPC"
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

-- non standard rate (elif provider_type)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "J1885"
    AND SERVICE_TYPE_CD = "HCPC"
    AND PLACE_OF_SERVICE_CD = "22"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "J1885"
                    AND SERVICE_TYPE_CD = "HCPC"
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
  SERVICE_CD = "J1885"
  AND SERVICE_TYPE_CD = "HCPC"
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
    SERVICE_CD = "J1885"
    AND SERVICE_TYPE_CD = "HCPC"
    AND PLACE_OF_SERVICE_CD = "22"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "J1885"
                    AND SERVICE_TYPE_CD = "HCPC"
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
    SERVICE_CD = "J1885"
    AND SERVICE_TYPE_CD = "HCPC"
    AND PLACE_OF_SERVICE_CD = "22"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "J1885"
                    AND SERVICE_TYPE_CD = "HCPC"
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
  SERVICE_CD = "J1885"
  AND SERVICE_TYPE_CD = "HCPC"
  AND PLACE_OF_SERVICE_CD = "22"
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

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 5819119
    AND NETWORK_ID = "13133"
    AND PLACE_OF_SERVICE_CD = "11"
    AND SERVICE_CD = "98941"
    AND SERVICE_TYPE_CD = "CPT4";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
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

-- elif providertype
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

-- non standard rate (elif provider_type)
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


-- ROW 416
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "S9083"
    AND SERVICE_TYPE_CD = "HCPC"
    AND PLACE_OF_SERVICE_CD = "20"
    AND ZIP_CODE_UN = "78704";

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 5540965
    AND NETWORK_ID = "00173"
    AND PLACE_OF_SERVICE_CD = "20"
    AND SERVICE_CD = "S9083"
    AND SERVICE_TYPE_CD = "HCPC";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 5540965
    AND NETWORK_ID = "00173"
    AND SERVICE_LOCATION_NBR = 5024387
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 5540965 
                       AND NETWORK_ID = "00173" 
                       AND SERVICE_LOCATION_NBR = 5024387  
                       AND SPECIALTY_CD = @providerspecialtycode
                    ) 
                THEN @providerspecialtycode ELSE '' END);

-- elif providertype
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 5540965
    AND NETWORK_ID = "00173"
    AND SERVICE_LOCATION_NBR = 5024387
    AND PROVIDER_TYPE_CD = "UC";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 5540965
    AND NETWORK_ID = "00173"
    AND SERVICE_LOCATION_NBR = 5024387;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "S9083"
    AND SERVICE_TYPE_CD = "HCPC"
    AND GEOGRAPHIC_AREA_CD = @geographicareacd
    AND PLACE_OF_SERVICE_CD = "20"
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
    SERVICE_CD = "S9083"
    AND SERVICE_TYPE_CD = "HCPC"
    AND PLACE_OF_SERVICE_CD = "20"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "S9083"
                    AND SERVICE_TYPE_CD = "HCPC"
                    AND PLACE_OF_SERVICE_CD = "20"
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

-- non standard rate (elif provider_type)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "S9083"
    AND SERVICE_TYPE_CD = "HCPC"
    AND PLACE_OF_SERVICE_CD = "20"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "S9083"
                    AND SERVICE_TYPE_CD = "HCPC"
                    AND PLACE_OF_SERVICE_CD = "20"
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
  SERVICE_CD = "S9083"
  AND SERVICE_TYPE_CD = "HCPC"
  AND PLACE_OF_SERVICE_CD = "20"
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
    SERVICE_CD = "S9083"
    AND SERVICE_TYPE_CD = "HCPC"
    AND PLACE_OF_SERVICE_CD = "20"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "S9083"
                    AND SERVICE_TYPE_CD = "HCPC"
                    AND PLACE_OF_SERVICE_CD = "20"
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
    SERVICE_CD = "S9083"
    AND SERVICE_TYPE_CD = "HCPC"
    AND PLACE_OF_SERVICE_CD = "20"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "S9083"
                    AND SERVICE_TYPE_CD = "HCPC"
                    AND PLACE_OF_SERVICE_CD = "20"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = "UC"
            )
            THEN "UC"
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
  SERVICE_CD = "S9083"
  AND SERVICE_TYPE_CD = "HCPC"
  AND PLACE_OF_SERVICE_CD = "20"
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

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7864393
    AND NETWORK_ID = "00357"
    AND PLACE_OF_SERVICE_CD = "11"
    AND SERVICE_CD = "99215"
    AND SERVICE_TYPE_CD = "CPT4";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
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

-- elif providertype
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

-- non standard rate (elif provider_type)
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


-- ROW 431
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "76830"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND ZIP_CODE_UN = "34787";

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6041595
    AND NETWORK_ID = "02284"
    AND PLACE_OF_SERVICE_CD = "11"
    AND SERVICE_CD = "76830"
    AND SERVICE_TYPE_CD = "CPT4";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6041595
    AND NETWORK_ID = "02284"
    AND SERVICE_LOCATION_NBR = 8377103
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 6041595 
                       AND NETWORK_ID = "02284" 
                       AND SERVICE_LOCATION_NBR = 8377103  
                       AND SPECIALTY_CD = @providerspecialtycode
                    ) 
                THEN @providerspecialtycode ELSE '' END);

-- elif providertype
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6041595
    AND NETWORK_ID = "02284"
    AND SERVICE_LOCATION_NBR = 8377103
    AND PROVIDER_TYPE_CD = "NP";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6041595
    AND NETWORK_ID = "02284"
    AND SERVICE_LOCATION_NBR = 8377103;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "76830"
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
    SERVICE_CD = "76830"
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
                WHERE SERVICE_CD = "76830"
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

-- non standard rate (elif provider_type)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "76830"
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
                WHERE SERVICE_CD = "76830"
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
  SERVICE_CD = "76830"
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
    SERVICE_CD = "76830"
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
                WHERE SERVICE_CD = "76830"
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
    SERVICE_CD = "76830"
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
                WHERE SERVICE_CD = "76830"
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
  SERVICE_CD = "76830"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "11"
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

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4719284
    AND NETWORK_ID = "00243"
    AND PLACE_OF_SERVICE_CD = "81"
    AND SERVICE_CD = "81528"
    AND SERVICE_TYPE_CD = "CPT4";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
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

-- elif providertype
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

-- non standard rate (elif provider_type)
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


-- ROW 478
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "99391"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND ZIP_CODE_UN = "38119";

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 9415884
    AND NETWORK_ID = "00398"
    AND PLACE_OF_SERVICE_CD = "11"
    AND SERVICE_CD = "99391"
    AND SERVICE_TYPE_CD = "CPT4";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 9415884
    AND NETWORK_ID = "00398"
    AND SERVICE_LOCATION_NBR = 2563105
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 9415884 
                       AND NETWORK_ID = "00398" 
                       AND SERVICE_LOCATION_NBR = 2563105  
                       AND SPECIALTY_CD = "10401"
                    ) 
                THEN "10401" ELSE '' END);

-- elif providertype
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 9415884
    AND NETWORK_ID = "00398"
    AND SERVICE_LOCATION_NBR = 2563105
    AND PROVIDER_TYPE_CD = "PH";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 9415884
    AND NETWORK_ID = "00398"
    AND SERVICE_LOCATION_NBR = 2563105;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "99391"
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
    SERVICE_CD = "99391"
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
                WHERE SERVICE_CD = "99391"
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

-- non standard rate (elif provider_type)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "99391"
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
                WHERE SERVICE_CD = "99391"
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
  SERVICE_CD = "99391"
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
    SERVICE_CD = "99391"
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
                WHERE SERVICE_CD = "99391"
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
    SERVICE_CD = "99391"
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
                WHERE SERVICE_CD = "99391"
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
  SERVICE_CD = "99391"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "11"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE = 'D' 
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;


-- ROW 543
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "99051"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND ZIP_CODE_UN = "27511";

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6578077
    AND NETWORK_ID = "00606"
    AND PLACE_OF_SERVICE_CD = "11"
    AND SERVICE_CD = "99051"
    AND SERVICE_TYPE_CD = "CPT4";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6578077
    AND NETWORK_ID = "00606"
    AND SERVICE_LOCATION_NBR = 5540878
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 6578077 
                       AND NETWORK_ID = "00606" 
                       AND SERVICE_LOCATION_NBR = 5540878  
                       AND SPECIALTY_CD = "10401"
                    ) 
                THEN "10401" ELSE '' END);

-- elif providertype
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6578077
    AND NETWORK_ID = "00606"
    AND SERVICE_LOCATION_NBR = 5540878
    AND PROVIDER_TYPE_CD = "PH";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6578077
    AND NETWORK_ID = "00606"
    AND SERVICE_LOCATION_NBR = 5540878;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "99051"
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
    SERVICE_CD = "99051"
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
                WHERE SERVICE_CD = "99051"
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

-- non standard rate (elif provider_type)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "99051"
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
                WHERE SERVICE_CD = "99051"
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
  SERVICE_CD = "99051"
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
    SERVICE_CD = "99051"
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
                WHERE SERVICE_CD = "99051"
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
    SERVICE_CD = "99051"
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
                WHERE SERVICE_CD = "99051"
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
  SERVICE_CD = "99051"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "11"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE = 'D' 
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;


-- ROW 554
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "76830"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND ZIP_CODE_UN = "98226";

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7168790
    AND NETWORK_ID = "00447"
    AND PLACE_OF_SERVICE_CD = "11"
    AND SERVICE_CD = "76830"
    AND SERVICE_TYPE_CD = "CPT4";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7168790
    AND NETWORK_ID = "00447"
    AND SERVICE_LOCATION_NBR = 1682595
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 7168790 
                       AND NETWORK_ID = "00447" 
                       AND SERVICE_LOCATION_NBR = 1682595  
                       AND SPECIALTY_CD = @providerspecialtycode
                    ) 
                THEN @providerspecialtycode ELSE '' END);

-- elif providertype
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7168790
    AND NETWORK_ID = "00447"
    AND SERVICE_LOCATION_NBR = 1682595
    AND PROVIDER_TYPE_CD = "RC";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7168790
    AND NETWORK_ID = "00447"
    AND SERVICE_LOCATION_NBR = 1682595;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "76830"
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
    SERVICE_CD = "76830"
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
                WHERE SERVICE_CD = "76830"
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

-- non standard rate (elif provider_type)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "76830"
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
                WHERE SERVICE_CD = "76830"
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
  SERVICE_CD = "76830"
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
    SERVICE_CD = "76830"
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
                WHERE SERVICE_CD = "76830"
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
    SERVICE_CD = "76830"
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
                WHERE SERVICE_CD = "76830"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = "RC"
            )
            THEN "RC"
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
  SERVICE_CD = "76830"
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

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6697543
    AND NETWORK_ID = "00355"
    AND PLACE_OF_SERVICE_CD = "11"
    AND SERVICE_CD = "99204"
    AND SERVICE_TYPE_CD = "CPT4";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
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

-- elif providertype
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

-- non standard rate (elif provider_type)
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


-- ROW 601
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "90461"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND ZIP_CODE_UN = "99218";

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7713675
    AND NETWORK_ID = "00437"
    AND PLACE_OF_SERVICE_CD = "11"
    AND SERVICE_CD = "90461"
    AND SERVICE_TYPE_CD = "CPT4";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7713675
    AND NETWORK_ID = "00437"
    AND SERVICE_LOCATION_NBR = 6956244
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 7713675 
                       AND NETWORK_ID = "00437" 
                       AND SERVICE_LOCATION_NBR = 6956244  
                       AND SPECIALTY_CD = "10401"
                    ) 
                THEN "10401" ELSE '' END);

-- elif providertype
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7713675
    AND NETWORK_ID = "00437"
    AND SERVICE_LOCATION_NBR = 6956244
    AND PROVIDER_TYPE_CD = "PH";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7713675
    AND NETWORK_ID = "00437"
    AND SERVICE_LOCATION_NBR = 6956244;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "90461"
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
    SERVICE_CD = "90461"
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
                WHERE SERVICE_CD = "90461"
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

-- non standard rate (elif provider_type)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "90461"
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
                WHERE SERVICE_CD = "90461"
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
  SERVICE_CD = "90461"
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
    SERVICE_CD = "90461"
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
                WHERE SERVICE_CD = "90461"
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
    SERVICE_CD = "90461"
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
                WHERE SERVICE_CD = "90461"
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
  SERVICE_CD = "90461"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "11"
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

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4734262
    AND NETWORK_ID = "00408"
    AND PLACE_OF_SERVICE_CD = "81"
    AND SERVICE_CD = "85027"
    AND SERVICE_TYPE_CD = "CPT4";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
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

-- elif providertype
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

-- non standard rate (elif provider_type)
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

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6544565
    AND NETWORK_ID = "00622"
    AND PLACE_OF_SERVICE_CD = "81"
    AND SERVICE_CD = "85027"
    AND SERVICE_TYPE_CD = "CPT4";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
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

-- elif providertype
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

-- non standard rate (elif provider_type)
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


-- ROW 621
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "77067"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "22"
    AND ZIP_CODE_UN = "28105";

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4497126
    AND NETWORK_ID = "00454"
    AND PLACE_OF_SERVICE_CD = "22"
    AND SERVICE_CD = "77067"
    AND SERVICE_TYPE_CD = "CPT4";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4497126
    AND NETWORK_ID = "00454"
    AND SERVICE_LOCATION_NBR = 4861139
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 4497126 
                       AND NETWORK_ID = "00454" 
                       AND SERVICE_LOCATION_NBR = 4861139  
                       AND SPECIALTY_CD = @providerspecialtycode
                    ) 
                THEN @providerspecialtycode ELSE '' END);

-- elif providertype
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4497126
    AND NETWORK_ID = "00454"
    AND SERVICE_LOCATION_NBR = 4861139
    AND PROVIDER_TYPE_CD = "HO";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4497126
    AND NETWORK_ID = "00454"
    AND SERVICE_LOCATION_NBR = 4861139;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "77067"
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
    SERVICE_CD = "77067"
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
                WHERE SERVICE_CD = "77067"
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

-- non standard rate (elif provider_type)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "77067"
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
                WHERE SERVICE_CD = "77067"
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
  SERVICE_CD = "77067"
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
    SERVICE_CD = "77067"
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
                WHERE SERVICE_CD = "77067"
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
    SERVICE_CD = "77067"
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
                WHERE SERVICE_CD = "77067"
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
  SERVICE_CD = "77067"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "22"
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

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 8697277
    AND NETWORK_ID = "08164"
    AND PLACE_OF_SERVICE_CD = "81"
    AND SERVICE_CD = "85027"
    AND SERVICE_TYPE_CD = "CPT4";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
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

-- elif providertype
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

-- non standard rate (elif provider_type)
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


-- ROW 609
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "85027"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "81"
    AND ZIP_CODE_UN = "97213";

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6985711
    AND NETWORK_ID = "03999"
    AND PLACE_OF_SERVICE_CD = "81"
    AND SERVICE_CD = "85027"
    AND SERVICE_TYPE_CD = "CPT4";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
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

-- elif providertype
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

-- non standard rate (elif provider_type)
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


-- ROW 856
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "80048"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "81"
    AND ZIP_CODE_UN = "60515";

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 9601070
    AND NETWORK_ID = "00638"
    AND PLACE_OF_SERVICE_CD = "81"
    AND SERVICE_CD = "80048"
    AND SERVICE_TYPE_CD = "CPT4";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
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

-- elif providertype
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

-- non standard rate (elif provider_type)
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


-- ROW 692
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "J2704"
    AND SERVICE_TYPE_CD = "HCPC"
    AND PLACE_OF_SERVICE_CD = "22"
    AND ZIP_CODE_UN = "28105";

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4497126
    AND NETWORK_ID = "00454"
    AND PLACE_OF_SERVICE_CD = "22"
    AND SERVICE_CD = "J2704"
    AND SERVICE_TYPE_CD = "HCPC";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4497126
    AND NETWORK_ID = "00454"
    AND SERVICE_LOCATION_NBR = 4861139
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 4497126 
                       AND NETWORK_ID = "00454" 
                       AND SERVICE_LOCATION_NBR = 4861139  
                       AND SPECIALTY_CD = @providerspecialtycode
                    ) 
                THEN @providerspecialtycode ELSE '' END);

-- elif providertype
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4497126
    AND NETWORK_ID = "00454"
    AND SERVICE_LOCATION_NBR = 4861139
    AND PROVIDER_TYPE_CD = "HO";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4497126
    AND NETWORK_ID = "00454"
    AND SERVICE_LOCATION_NBR = 4861139;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "J2704"
    AND SERVICE_TYPE_CD = "HCPC"
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
    SERVICE_CD = "J2704"
    AND SERVICE_TYPE_CD = "HCPC"
    AND PLACE_OF_SERVICE_CD = "22"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "J2704"
                    AND SERVICE_TYPE_CD = "HCPC"
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

-- non standard rate (elif provider_type)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "J2704"
    AND SERVICE_TYPE_CD = "HCPC"
    AND PLACE_OF_SERVICE_CD = "22"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "J2704"
                    AND SERVICE_TYPE_CD = "HCPC"
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
  SERVICE_CD = "J2704"
  AND SERVICE_TYPE_CD = "HCPC"
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
    SERVICE_CD = "J2704"
    AND SERVICE_TYPE_CD = "HCPC"
    AND PLACE_OF_SERVICE_CD = "22"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "J2704"
                    AND SERVICE_TYPE_CD = "HCPC"
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
    SERVICE_CD = "J2704"
    AND SERVICE_TYPE_CD = "HCPC"
    AND PLACE_OF_SERVICE_CD = "22"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "J2704"
                    AND SERVICE_TYPE_CD = "HCPC"
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
  SERVICE_CD = "J2704"
  AND SERVICE_TYPE_CD = "HCPC"
  AND PLACE_OF_SERVICE_CD = "22"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE = 'D' 
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;


-- ROW 700
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "99233"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "21"
    AND ZIP_CODE_UN = "20007";

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7712368
    AND NETWORK_ID = "00385"
    AND PLACE_OF_SERVICE_CD = "21"
    AND SERVICE_CD = "99233"
    AND SERVICE_TYPE_CD = "CPT4";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7712368
    AND NETWORK_ID = "00385"
    AND SERVICE_LOCATION_NBR = 4836453
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 7712368 
                       AND NETWORK_ID = "00385" 
                       AND SERVICE_LOCATION_NBR = 4836453  
                       AND SPECIALTY_CD = "11001"
                    ) 
                THEN "11001" ELSE '' END);

-- elif providertype
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7712368
    AND NETWORK_ID = "00385"
    AND SERVICE_LOCATION_NBR = 4836453
    AND PROVIDER_TYPE_CD = "PH";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7712368
    AND NETWORK_ID = "00385"
    AND SERVICE_LOCATION_NBR = 4836453;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "99233"
    AND SERVICE_TYPE_CD = "CPT4"
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
    SERVICE_CD = "99233"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "21"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "99233"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "21"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = "11001"
            )
            THEN "11001"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- non standard rate (elif provider_type)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "99233"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "21"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "99233"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "21"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = "11001"
            )
            THEN "11001"
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
  SERVICE_CD = "99233"
  AND SERVICE_TYPE_CD = "CPT4"
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
    SERVICE_CD = "99233"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "21"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "99233"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "21"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = "11001"
            )
            THEN "11001"
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
    SERVICE_CD = "99233"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "21"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "99233"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "21"
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
  SERVICE_CD = "99233"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "21"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE = 'D' 
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;


-- ROW 723
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "99214"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND ZIP_CODE_UN = "62526";

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 8368864
    AND NETWORK_ID = "03780"
    AND PLACE_OF_SERVICE_CD = "11"
    AND SERVICE_CD = "99214"
    AND SERVICE_TYPE_CD = "CPT4";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 8368864
    AND NETWORK_ID = "03780"
    AND SERVICE_LOCATION_NBR = 4153418
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 8368864 
                       AND NETWORK_ID = "03780" 
                       AND SERVICE_LOCATION_NBR = 4153418  
                       AND SPECIALTY_CD = "10401"
                    ) 
                THEN "10401" ELSE '' END);

-- elif providertype
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 8368864
    AND NETWORK_ID = "03780"
    AND SERVICE_LOCATION_NBR = 4153418
    AND PROVIDER_TYPE_CD = "PH";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 8368864
    AND NETWORK_ID = "03780"
    AND SERVICE_LOCATION_NBR = 4153418;

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

-- non standard rate (elif provider_type)
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


-- ROW 728
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "96160"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND ZIP_CODE_UN = "22205";

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7727548
    AND NETWORK_ID = "00098"
    AND PLACE_OF_SERVICE_CD = "11"
    AND SERVICE_CD = "96160"
    AND SERVICE_TYPE_CD = "CPT4";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7727548
    AND NETWORK_ID = "00098"
    AND SERVICE_LOCATION_NBR = 890166
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 7727548 
                       AND NETWORK_ID = "00098" 
                       AND SERVICE_LOCATION_NBR = 890166  
                       AND SPECIALTY_CD = "20101"
                    ) 
                THEN "20101" ELSE '' END);

-- elif providertype
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7727548
    AND NETWORK_ID = "00098"
    AND SERVICE_LOCATION_NBR = 890166
    AND PROVIDER_TYPE_CD = "PH";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7727548
    AND NETWORK_ID = "00098"
    AND SERVICE_LOCATION_NBR = 890166;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "96160"
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
    SERVICE_CD = "96160"
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
                WHERE SERVICE_CD = "96160"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = "20101"
            )
            THEN "20101"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- non standard rate (elif provider_type)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "96160"
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
                WHERE SERVICE_CD = "96160"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = "20101"
            )
            THEN "20101"
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
  SERVICE_CD = "96160"
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
    SERVICE_CD = "96160"
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
                WHERE SERVICE_CD = "96160"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = "20101"
            )
            THEN "20101"
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
    SERVICE_CD = "96160"
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
                WHERE SERVICE_CD = "96160"
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
  SERVICE_CD = "96160"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "11"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE = 'D' 
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;


-- ROW 732
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "90461"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND ZIP_CODE_UN = "75070";

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6347355
    AND NETWORK_ID = "08158"
    AND PLACE_OF_SERVICE_CD = "11"
    AND SERVICE_CD = "90461"
    AND SERVICE_TYPE_CD = "CPT4";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6347355
    AND NETWORK_ID = "08158"
    AND SERVICE_LOCATION_NBR = 8646357
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 6347355 
                       AND NETWORK_ID = "08158" 
                       AND SERVICE_LOCATION_NBR = 8646357  
                       AND SPECIALTY_CD = "10401"
                    ) 
                THEN "10401" ELSE '' END);

-- elif providertype
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6347355
    AND NETWORK_ID = "08158"
    AND SERVICE_LOCATION_NBR = 8646357
    AND PROVIDER_TYPE_CD = "PH";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6347355
    AND NETWORK_ID = "08158"
    AND SERVICE_LOCATION_NBR = 8646357;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "90461"
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
    SERVICE_CD = "90461"
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
                WHERE SERVICE_CD = "90461"
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

-- non standard rate (elif provider_type)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "90461"
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
                WHERE SERVICE_CD = "90461"
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
  SERVICE_CD = "90461"
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
    SERVICE_CD = "90461"
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
                WHERE SERVICE_CD = "90461"
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
    SERVICE_CD = "90461"
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
                WHERE SERVICE_CD = "90461"
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
  SERVICE_CD = "90461"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "11"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE = 'D' 
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;


-- ROW 742
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "H0035"
    AND SERVICE_TYPE_CD = "HCPC"
    AND PLACE_OF_SERVICE_CD = "22"
    AND ZIP_CODE_UN = "27104";

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7539690
    AND NETWORK_ID = "00606"
    AND PLACE_OF_SERVICE_CD = "22"
    AND SERVICE_CD = "H0035"
    AND SERVICE_TYPE_CD = "HCPC";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7539690
    AND NETWORK_ID = "00606"
    AND SERVICE_LOCATION_NBR = 158112
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 7539690 
                       AND NETWORK_ID = "00606" 
                       AND SERVICE_LOCATION_NBR = 158112  
                       AND SPECIALTY_CD = @providerspecialtycode
                    ) 
                THEN @providerspecialtycode ELSE '' END);

-- elif providertype
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7539690
    AND NETWORK_ID = "00606"
    AND SERVICE_LOCATION_NBR = 158112
    AND PROVIDER_TYPE_CD = "PSH";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7539690
    AND NETWORK_ID = "00606"
    AND SERVICE_LOCATION_NBR = 158112;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "H0035"
    AND SERVICE_TYPE_CD = "HCPC"
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
    SERVICE_CD = "H0035"
    AND SERVICE_TYPE_CD = "HCPC"
    AND PLACE_OF_SERVICE_CD = "22"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "H0035"
                    AND SERVICE_TYPE_CD = "HCPC"
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

-- non standard rate (elif provider_type)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "H0035"
    AND SERVICE_TYPE_CD = "HCPC"
    AND PLACE_OF_SERVICE_CD = "22"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "H0035"
                    AND SERVICE_TYPE_CD = "HCPC"
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
  SERVICE_CD = "H0035"
  AND SERVICE_TYPE_CD = "HCPC"
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
    SERVICE_CD = "H0035"
    AND SERVICE_TYPE_CD = "HCPC"
    AND PLACE_OF_SERVICE_CD = "22"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "H0035"
                    AND SERVICE_TYPE_CD = "HCPC"
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
    SERVICE_CD = "H0035"
    AND SERVICE_TYPE_CD = "HCPC"
    AND PLACE_OF_SERVICE_CD = "22"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "H0035"
                    AND SERVICE_TYPE_CD = "HCPC"
                    AND PLACE_OF_SERVICE_CD = "22"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = "PSH"
            )
            THEN "PSH"
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
  SERVICE_CD = "H0035"
  AND SERVICE_TYPE_CD = "HCPC"
  AND PLACE_OF_SERVICE_CD = "22"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE = 'D' 
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;


-- ROW 757
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "99213"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND ZIP_CODE_UN = "10941";

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7333594
    AND NETWORK_ID = "00357"
    AND PLACE_OF_SERVICE_CD = "11"
    AND SERVICE_CD = "99213"
    AND SERVICE_TYPE_CD = "CPT4";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7333594
    AND NETWORK_ID = "00357"
    AND SERVICE_LOCATION_NBR = 4071677
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 7333594 
                       AND NETWORK_ID = "00357" 
                       AND SERVICE_LOCATION_NBR = 4071677  
                       AND SPECIALTY_CD = "11002"
                    ) 
                THEN "11002" ELSE '' END);

-- elif providertype
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7333594
    AND NETWORK_ID = "00357"
    AND SERVICE_LOCATION_NBR = 4071677
    AND PROVIDER_TYPE_CD = "PH";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7333594
    AND NETWORK_ID = "00357"
    AND SERVICE_LOCATION_NBR = 4071677;

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
                    AND SPECIALTY_CD = "11002"
            )
            THEN "11002"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- non standard rate (elif provider_type)
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
                    AND SPECIALTY_CD = "11002"
            )
            THEN "11002"
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
                    AND SPECIALTY_CD = "11002"
            )
            THEN "11002"
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


-- ROW 774
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "G0136"
    AND SERVICE_TYPE_CD = "HCPC"
    AND PLACE_OF_SERVICE_CD = "11"
    AND ZIP_CODE_UN = "27030";

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7243170
    AND NETWORK_ID = "03200"
    AND PLACE_OF_SERVICE_CD = "11"
    AND SERVICE_CD = "G0136"
    AND SERVICE_TYPE_CD = "HCPC";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7243170
    AND NETWORK_ID = "03200"
    AND SERVICE_LOCATION_NBR = 7896102
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 7243170 
                       AND NETWORK_ID = "03200" 
                       AND SERVICE_LOCATION_NBR = 7896102  
                       AND SPECIALTY_CD = "10201"
                    ) 
                THEN "10201" ELSE '' END);

-- elif providertype
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7243170
    AND NETWORK_ID = "03200"
    AND SERVICE_LOCATION_NBR = 7896102
    AND PROVIDER_TYPE_CD = "PH";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7243170
    AND NETWORK_ID = "03200"
    AND SERVICE_LOCATION_NBR = 7896102;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "G0136"
    AND SERVICE_TYPE_CD = "HCPC"
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
    SERVICE_CD = "G0136"
    AND SERVICE_TYPE_CD = "HCPC"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "G0136"
                    AND SERVICE_TYPE_CD = "HCPC"
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

-- non standard rate (elif provider_type)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "G0136"
    AND SERVICE_TYPE_CD = "HCPC"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "G0136"
                    AND SERVICE_TYPE_CD = "HCPC"
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
  SERVICE_CD = "G0136"
  AND SERVICE_TYPE_CD = "HCPC"
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
    SERVICE_CD = "G0136"
    AND SERVICE_TYPE_CD = "HCPC"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "G0136"
                    AND SERVICE_TYPE_CD = "HCPC"
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
    SERVICE_CD = "G0136"
    AND SERVICE_TYPE_CD = "HCPC"
    AND PLACE_OF_SERVICE_CD = "11"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "G0136"
                    AND SERVICE_TYPE_CD = "HCPC"
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
  SERVICE_CD = "G0136"
  AND SERVICE_TYPE_CD = "HCPC"
  AND PLACE_OF_SERVICE_CD = "11"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE = 'D' 
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;


-- ROW 821
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "81003"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND ZIP_CODE_UN = "30701";

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4998887
    AND NETWORK_ID = "00639"
    AND PLACE_OF_SERVICE_CD = "11"
    AND SERVICE_CD = "81003"
    AND SERVICE_TYPE_CD = "CPT4";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4998887
    AND NETWORK_ID = "00639"
    AND SERVICE_LOCATION_NBR = 2156779
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 4998887 
                       AND NETWORK_ID = "00639" 
                       AND SERVICE_LOCATION_NBR = 2156779  
                       AND SPECIALTY_CD = "20101"
                    ) 
                THEN "20101" ELSE '' END);

-- elif providertype
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4998887
    AND NETWORK_ID = "00639"
    AND SERVICE_LOCATION_NBR = 2156779
    AND PROVIDER_TYPE_CD = "PH";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4998887
    AND NETWORK_ID = "00639"
    AND SERVICE_LOCATION_NBR = 2156779;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "81003"
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
    SERVICE_CD = "81003"
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
                WHERE SERVICE_CD = "81003"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = "20101"
            )
            THEN "20101"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- non standard rate (elif provider_type)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "81003"
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
                WHERE SERVICE_CD = "81003"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = "20101"
            )
            THEN "20101"
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
  SERVICE_CD = "81003"
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
    SERVICE_CD = "81003"
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
                WHERE SERVICE_CD = "81003"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = "20101"
            )
            THEN "20101"
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
    SERVICE_CD = "81003"
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
                WHERE SERVICE_CD = "81003"
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
  SERVICE_CD = "81003"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "11"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE = 'D' 
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;


-- ROW 823
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "91321"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND ZIP_CODE_UN = "98121";

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 9731502
    AND NETWORK_ID = "00447"
    AND PLACE_OF_SERVICE_CD = "11"
    AND SERVICE_CD = "91321"
    AND SERVICE_TYPE_CD = "CPT4";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 9731502
    AND NETWORK_ID = "00447"
    AND SERVICE_LOCATION_NBR = 6605677
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 9731502 
                       AND NETWORK_ID = "00447" 
                       AND SERVICE_LOCATION_NBR = 6605677  
                       AND SPECIALTY_CD = @providerspecialtycode
                    ) 
                THEN @providerspecialtycode ELSE '' END);

-- elif providertype
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 9731502
    AND NETWORK_ID = "00447"
    AND SERVICE_LOCATION_NBR = 6605677
    AND PROVIDER_TYPE_CD = "OMP";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 9731502
    AND NETWORK_ID = "00447"
    AND SERVICE_LOCATION_NBR = 6605677;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "91321"
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
    SERVICE_CD = "91321"
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
                WHERE SERVICE_CD = "91321"
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

-- non standard rate (elif provider_type)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "91321"
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
                WHERE SERVICE_CD = "91321"
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
  SERVICE_CD = "91321"
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
    SERVICE_CD = "91321"
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
                WHERE SERVICE_CD = "91321"
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
    SERVICE_CD = "91321"
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
                WHERE SERVICE_CD = "91321"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = "OMP"
            )
            THEN "OMP"
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
  SERVICE_CD = "91321"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "11"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE = 'D' 
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;


-- ROW 855
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "99284"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "23"
    AND ZIP_CODE_UN = "78233";

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 8715650
    AND NETWORK_ID = "00190"
    AND PLACE_OF_SERVICE_CD = "23"
    AND SERVICE_CD = "99284"
    AND SERVICE_TYPE_CD = "CPT4";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 8715650
    AND NETWORK_ID = "00190"
    AND SERVICE_LOCATION_NBR = 8591815
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 8715650 
                       AND NETWORK_ID = "00190" 
                       AND SERVICE_LOCATION_NBR = 8591815  
                       AND SPECIALTY_CD = "10701"
                    ) 
                THEN "10701" ELSE '' END);

-- elif providertype
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 8715650
    AND NETWORK_ID = "00190"
    AND SERVICE_LOCATION_NBR = 8591815
    AND PROVIDER_TYPE_CD = "PH";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 8715650
    AND NETWORK_ID = "00190"
    AND SERVICE_LOCATION_NBR = 8591815;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "99284"
    AND SERVICE_TYPE_CD = "CPT4"
    AND GEOGRAPHIC_AREA_CD = @geographicareacd
    AND PLACE_OF_SERVICE_CD = "23"
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
    SERVICE_CD = "99284"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "23"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "99284"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "23"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = "10701"
            )
            THEN "10701"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- non standard rate (elif provider_type)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "99284"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "23"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "99284"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "23"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = "10701"
            )
            THEN "10701"
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
  SERVICE_CD = "99284"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "23"
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
    SERVICE_CD = "99284"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "23"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "99284"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "23"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = "10701"
            )
            THEN "10701"
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
    SERVICE_CD = "99284"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "23"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "99284"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "23"
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
  SERVICE_CD = "99284"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "23"
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

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6961187
    AND NETWORK_ID = "00346"
    AND PLACE_OF_SERVICE_CD = "81"
    AND SERVICE_CD = "85027"
    AND SERVICE_TYPE_CD = "CPT4";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
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

-- elif providertype
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

-- non standard rate (elif provider_type)
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


-- ROW 857
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "93000"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND ZIP_CODE_UN = "11720";

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7258128
    AND NETWORK_ID = "00357"
    AND PLACE_OF_SERVICE_CD = "11"
    AND SERVICE_CD = "93000"
    AND SERVICE_TYPE_CD = "CPT4";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7258128
    AND NETWORK_ID = "00357"
    AND SERVICE_LOCATION_NBR = 5394720
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 7258128 
                       AND NETWORK_ID = "00357" 
                       AND SERVICE_LOCATION_NBR = 5394720  
                       AND SPECIALTY_CD = "10301"
                    ) 
                THEN "10301" ELSE '' END);

-- elif providertype
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7258128
    AND NETWORK_ID = "00357"
    AND SERVICE_LOCATION_NBR = 5394720
    AND PROVIDER_TYPE_CD = "PH";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7258128
    AND NETWORK_ID = "00357"
    AND SERVICE_LOCATION_NBR = 5394720;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "93000"
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
    SERVICE_CD = "93000"
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
                WHERE SERVICE_CD = "93000"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = "10301"
            )
            THEN "10301"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- non standard rate (elif provider_type)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "93000"
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
                WHERE SERVICE_CD = "93000"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = "10301"
            )
            THEN "10301"
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
  SERVICE_CD = "93000"
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
    SERVICE_CD = "93000"
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
                WHERE SERVICE_CD = "93000"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = "10301"
            )
            THEN "10301"
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
    SERVICE_CD = "93000"
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
                WHERE SERVICE_CD = "93000"
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
  SERVICE_CD = "93000"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "11"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE = 'D' 
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;


-- ROW 861
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "87651"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND ZIP_CODE_UN = "28277";

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4233642
    AND NETWORK_ID = "00454"
    AND PLACE_OF_SERVICE_CD = "11"
    AND SERVICE_CD = "87651"
    AND SERVICE_TYPE_CD = "CPT4";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4233642
    AND NETWORK_ID = "00454"
    AND SERVICE_LOCATION_NBR = 9536181
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 4233642 
                       AND NETWORK_ID = "00454" 
                       AND SERVICE_LOCATION_NBR = 9536181  
                       AND SPECIALTY_CD = "10401"
                    ) 
                THEN "10401" ELSE '' END);

-- elif providertype
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4233642
    AND NETWORK_ID = "00454"
    AND SERVICE_LOCATION_NBR = 9536181
    AND PROVIDER_TYPE_CD = "PH";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4233642
    AND NETWORK_ID = "00454"
    AND SERVICE_LOCATION_NBR = 9536181;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "87651"
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
    SERVICE_CD = "87651"
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
                WHERE SERVICE_CD = "87651"
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

-- non standard rate (elif provider_type)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "87651"
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
                WHERE SERVICE_CD = "87651"
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
  SERVICE_CD = "87651"
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
    SERVICE_CD = "87651"
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
                WHERE SERVICE_CD = "87651"
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
    SERVICE_CD = "87651"
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
                WHERE SERVICE_CD = "87651"
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
  SERVICE_CD = "87651"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "11"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE = 'D' 
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;


-- ROW 864
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "99284"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "23"
    AND ZIP_CODE_UN = "84067";

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7005047
    AND NETWORK_ID = "09512"
    AND PLACE_OF_SERVICE_CD = "23"
    AND SERVICE_CD = "99284"
    AND SERVICE_TYPE_CD = "CPT4";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7005047
    AND NETWORK_ID = "09512"
    AND SERVICE_LOCATION_NBR = 7944919
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 7005047 
                       AND NETWORK_ID = "09512" 
                       AND SERVICE_LOCATION_NBR = 7944919  
                       AND SPECIALTY_CD = "10701"
                    ) 
                THEN "10701" ELSE '' END);

-- elif providertype
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7005047
    AND NETWORK_ID = "09512"
    AND SERVICE_LOCATION_NBR = 7944919
    AND PROVIDER_TYPE_CD = "PH";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7005047
    AND NETWORK_ID = "09512"
    AND SERVICE_LOCATION_NBR = 7944919;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "99284"
    AND SERVICE_TYPE_CD = "CPT4"
    AND GEOGRAPHIC_AREA_CD = @geographicareacd
    AND PLACE_OF_SERVICE_CD = "23"
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
    SERVICE_CD = "99284"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "23"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "99284"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "23"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = "10701"
            )
            THEN "10701"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- non standard rate (elif provider_type)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "99284"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "23"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "99284"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "23"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = "10701"
            )
            THEN "10701"
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
  SERVICE_CD = "99284"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "23"
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
    SERVICE_CD = "99284"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "23"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "99284"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "23"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = "10701"
            )
            THEN "10701"
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
    SERVICE_CD = "99284"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "23"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "99284"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "23"
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
  SERVICE_CD = "99284"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "23"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE = 'D' 
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;


-- ROW 891
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "90661"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND ZIP_CODE_UN = "10573";

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4720723
    AND NETWORK_ID = "00391"
    AND PLACE_OF_SERVICE_CD = "11"
    AND SERVICE_CD = "90661"
    AND SERVICE_TYPE_CD = "CPT4";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4720723
    AND NETWORK_ID = "00391"
    AND SERVICE_LOCATION_NBR = 48221
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 4720723 
                       AND NETWORK_ID = "00391" 
                       AND SERVICE_LOCATION_NBR = 48221  
                       AND SPECIALTY_CD = "90353"
                    ) 
                THEN "90353" ELSE '' END);

-- elif providertype
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4720723
    AND NETWORK_ID = "00391"
    AND SERVICE_LOCATION_NBR = 48221
    AND PROVIDER_TYPE_CD = "NP";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4720723
    AND NETWORK_ID = "00391"
    AND SERVICE_LOCATION_NBR = 48221;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "90661"
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
    SERVICE_CD = "90661"
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
                WHERE SERVICE_CD = "90661"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = "90353"
            )
            THEN "90353"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- non standard rate (elif provider_type)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "90661"
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
                WHERE SERVICE_CD = "90661"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = "90353"
            )
            THEN "90353"
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
  SERVICE_CD = "90661"
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
    SERVICE_CD = "90661"
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
                WHERE SERVICE_CD = "90661"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = "90353"
            )
            THEN "90353"
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
    SERVICE_CD = "90661"
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
                WHERE SERVICE_CD = "90661"
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
  SERVICE_CD = "90661"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "11"
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

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6152740
    AND NETWORK_ID = "00226"
    AND PLACE_OF_SERVICE_CD = "22"
    AND SERVICE_CD = "76014"
    AND SERVICE_TYPE_CD = "CPT4";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
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

-- elif providertype
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

-- non standard rate (elif provider_type)
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


-- ROW 1010
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "31231"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND ZIP_CODE_UN = "60169";

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 9259598
    AND NETWORK_ID = "00243"
    AND PLACE_OF_SERVICE_CD = "11"
    AND SERVICE_CD = "31231"
    AND SERVICE_TYPE_CD = "CPT4";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 9259598
    AND NETWORK_ID = "00243"
    AND SERVICE_LOCATION_NBR = 2672805
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 9259598 
                       AND NETWORK_ID = "00243" 
                       AND SERVICE_LOCATION_NBR = 2672805  
                       AND SPECIALTY_CD = "30601"
                    ) 
                THEN "30601" ELSE '' END);

-- elif providertype
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 9259598
    AND NETWORK_ID = "00243"
    AND SERVICE_LOCATION_NBR = 2672805
    AND PROVIDER_TYPE_CD = "PH";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 9259598
    AND NETWORK_ID = "00243"
    AND SERVICE_LOCATION_NBR = 2672805;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "31231"
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
    SERVICE_CD = "31231"
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
                WHERE SERVICE_CD = "31231"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = "30601"
            )
            THEN "30601"
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- non standard rate (elif provider_type)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "31231"
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
                WHERE SERVICE_CD = "31231"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE IN ('C', 'N')
                    AND SPECIALTY_CD = "30601"
            )
            THEN "30601"
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
  SERVICE_CD = "31231"
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
    SERVICE_CD = "31231"
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
                WHERE SERVICE_CD = "31231"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "11"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = "30601"
            )
            THEN "30601"
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
    SERVICE_CD = "31231"
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
                WHERE SERVICE_CD = "31231"
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
  SERVICE_CD = "31231"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "11"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE = 'D' 
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;


-- ROW 1023
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "99381"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND ZIP_CODE_UN = "20147";

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 9400970
    AND NETWORK_ID = "00385"
    AND PLACE_OF_SERVICE_CD = "11"
    AND SERVICE_CD = "99381"
    AND SERVICE_TYPE_CD = "CPT4";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 9400970
    AND NETWORK_ID = "00385"
    AND SERVICE_LOCATION_NBR = 712831
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 9400970 
                       AND NETWORK_ID = "00385" 
                       AND SERVICE_LOCATION_NBR = 712831  
                       AND SPECIALTY_CD = "10401"
                    ) 
                THEN "10401" ELSE '' END);

-- elif providertype
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 9400970
    AND NETWORK_ID = "00385"
    AND SERVICE_LOCATION_NBR = 712831
    AND PROVIDER_TYPE_CD = "PH";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 9400970
    AND NETWORK_ID = "00385"
    AND SERVICE_LOCATION_NBR = 712831;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "99381"
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
    SERVICE_CD = "99381"
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
                WHERE SERVICE_CD = "99381"
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

-- non standard rate (elif provider_type)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "99381"
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
                WHERE SERVICE_CD = "99381"
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
  SERVICE_CD = "99381"
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
    SERVICE_CD = "99381"
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
                WHERE SERVICE_CD = "99381"
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
    SERVICE_CD = "99381"
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
                WHERE SERVICE_CD = "99381"
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
  SERVICE_CD = "99381"
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

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6649889
    AND NETWORK_ID = "02159"
    AND PLACE_OF_SERVICE_CD = "11"
    AND SERVICE_CD = "99395"
    AND SERVICE_TYPE_CD = "CPT4";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
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

-- elif providertype
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

-- non standard rate (elif provider_type)
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


-- ROW 1047
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "77067"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "22"
    AND ZIP_CODE_UN = "10591";

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6451270
    AND NETWORK_ID = "00357"
    AND PLACE_OF_SERVICE_CD = "22"
    AND SERVICE_CD = "77067"
    AND SERVICE_TYPE_CD = "CPT4";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6451270
    AND NETWORK_ID = "00357"
    AND SERVICE_LOCATION_NBR = 1380685
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 6451270 
                       AND NETWORK_ID = "00357" 
                       AND SERVICE_LOCATION_NBR = 1380685  
                       AND SPECIALTY_CD = @providerspecialtycode
                    ) 
                THEN @providerspecialtycode ELSE '' END);

-- elif providertype
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6451270
    AND NETWORK_ID = "00357"
    AND SERVICE_LOCATION_NBR = 1380685
    AND PROVIDER_TYPE_CD = "HO";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6451270
    AND NETWORK_ID = "00357"
    AND SERVICE_LOCATION_NBR = 1380685;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "77067"
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
    SERVICE_CD = "77067"
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
                WHERE SERVICE_CD = "77067"
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

-- non standard rate (elif provider_type)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "77067"
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
                WHERE SERVICE_CD = "77067"
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
  SERVICE_CD = "77067"
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
    SERVICE_CD = "77067"
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
                WHERE SERVICE_CD = "77067"
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
    SERVICE_CD = "77067"
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
                WHERE SERVICE_CD = "77067"
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
  SERVICE_CD = "77067"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "22"
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

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4231738
    AND NETWORK_ID = "00395"
    AND PLACE_OF_SERVICE_CD = "11"
    AND SERVICE_CD = "90380"
    AND SERVICE_TYPE_CD = "CPT4";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
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

-- elif providertype
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

-- non standard rate (elif provider_type)
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


-- ROW 1074
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "99283"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "23"
    AND ZIP_CODE_UN = "77339";

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6543355
    AND NETWORK_ID = "00248"
    AND PLACE_OF_SERVICE_CD = "23"
    AND SERVICE_CD = "99283"
    AND SERVICE_TYPE_CD = "CPT4";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6543355
    AND NETWORK_ID = "00248"
    AND SERVICE_LOCATION_NBR = 730117
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 6543355 
                       AND NETWORK_ID = "00248" 
                       AND SERVICE_LOCATION_NBR = 730117  
                       AND SPECIALTY_CD = @providerspecialtycode
                    ) 
                THEN @providerspecialtycode ELSE '' END);

-- elif providertype
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6543355
    AND NETWORK_ID = "00248"
    AND SERVICE_LOCATION_NBR = 730117
    AND PROVIDER_TYPE_CD = "HO";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6543355
    AND NETWORK_ID = "00248"
    AND SERVICE_LOCATION_NBR = 730117;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "99283"
    AND SERVICE_TYPE_CD = "CPT4"
    AND GEOGRAPHIC_AREA_CD = @geographicareacd
    AND PLACE_OF_SERVICE_CD = "23"
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
    SERVICE_CD = "99283"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "23"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "99283"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "23"
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

-- non standard rate (elif provider_type)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "99283"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "23"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "99283"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "23"
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
  SERVICE_CD = "99283"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "23"
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
    SERVICE_CD = "99283"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "23"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "99283"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "23"
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
    SERVICE_CD = "99283"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "23"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "99283"
                    AND SERVICE_TYPE_CD = "CPT4"
                    AND PLACE_OF_SERVICE_CD = "23"
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
  SERVICE_CD = "99283"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "23"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE = 'D' 
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;


-- ROW 1084
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "A9579"
    AND SERVICE_TYPE_CD = "HCPC"
    AND PLACE_OF_SERVICE_CD = "22"
    AND ZIP_CODE_UN = "77030";

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6541570
    AND NETWORK_ID = "00248"
    AND PLACE_OF_SERVICE_CD = "22"
    AND SERVICE_CD = "A9579"
    AND SERVICE_TYPE_CD = "HCPC";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6541570
    AND NETWORK_ID = "00248"
    AND SERVICE_LOCATION_NBR = 160705
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 6541570 
                       AND NETWORK_ID = "00248" 
                       AND SERVICE_LOCATION_NBR = 160705  
                       AND SPECIALTY_CD = @providerspecialtycode
                    ) 
                THEN @providerspecialtycode ELSE '' END);

-- elif providertype
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6541570
    AND NETWORK_ID = "00248"
    AND SERVICE_LOCATION_NBR = 160705
    AND PROVIDER_TYPE_CD = "CH";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6541570
    AND NETWORK_ID = "00248"
    AND SERVICE_LOCATION_NBR = 160705;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "A9579"
    AND SERVICE_TYPE_CD = "HCPC"
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
    SERVICE_CD = "A9579"
    AND SERVICE_TYPE_CD = "HCPC"
    AND PLACE_OF_SERVICE_CD = "22"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "A9579"
                    AND SERVICE_TYPE_CD = "HCPC"
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

-- non standard rate (elif provider_type)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "A9579"
    AND SERVICE_TYPE_CD = "HCPC"
    AND PLACE_OF_SERVICE_CD = "22"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "A9579"
                    AND SERVICE_TYPE_CD = "HCPC"
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
  SERVICE_CD = "A9579"
  AND SERVICE_TYPE_CD = "HCPC"
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
    SERVICE_CD = "A9579"
    AND SERVICE_TYPE_CD = "HCPC"
    AND PLACE_OF_SERVICE_CD = "22"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "A9579"
                    AND SERVICE_TYPE_CD = "HCPC"
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
    SERVICE_CD = "A9579"
    AND SERVICE_TYPE_CD = "HCPC"
    AND PLACE_OF_SERVICE_CD = "22"
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM CET_RATES
                WHERE SERVICE_CD = "A9579"
                    AND SERVICE_TYPE_CD = "HCPC"
                    AND PLACE_OF_SERVICE_CD = "22"
                    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
                    AND CONTRACT_TYPE = 'D'
                    AND SPECIALTY_CD = "CH"
            )
            THEN "CH"
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
  SERVICE_CD = "A9579"
  AND SERVICE_TYPE_CD = "HCPC"
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

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4472332
    AND NETWORK_ID = "00483"
    AND PLACE_OF_SERVICE_CD = "11"
    AND SERVICE_CD = "99214"
    AND SERVICE_TYPE_CD = "CPT4";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
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

-- elif providertype
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

-- non standard rate (elif provider_type)
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


-- ROW 1103
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "99417"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND ZIP_CODE_UN = "32207";

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 9860434
    AND NETWORK_ID = "03892"
    AND PLACE_OF_SERVICE_CD = "11"
    AND SERVICE_CD = "99417"
    AND SERVICE_TYPE_CD = "CPT4";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 9860434
    AND NETWORK_ID = "03892"
    AND SERVICE_LOCATION_NBR = 5134124
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 9860434 
                       AND NETWORK_ID = "03892" 
                       AND SERVICE_LOCATION_NBR = 5134124  
                       AND SPECIALTY_CD = "10401"
                    ) 
                THEN "10401" ELSE '' END);

-- elif providertype
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 9860434
    AND NETWORK_ID = "03892"
    AND SERVICE_LOCATION_NBR = 5134124
    AND PROVIDER_TYPE_CD = "PH";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 9860434
    AND NETWORK_ID = "03892"
    AND SERVICE_LOCATION_NBR = 5134124;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "99417"
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
    SERVICE_CD = "99417"
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
                WHERE SERVICE_CD = "99417"
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

-- non standard rate (elif provider_type)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "99417"
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
                WHERE SERVICE_CD = "99417"
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
  SERVICE_CD = "99417"
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
    SERVICE_CD = "99417"
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
                WHERE SERVICE_CD = "99417"
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
    SERVICE_CD = "99417"
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
                WHERE SERVICE_CD = "99417"
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
  SERVICE_CD = "99417"
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

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6210155
    AND NETWORK_ID = "00393"
    AND PLACE_OF_SERVICE_CD = "21"
    AND SERVICE_CD = "805"
    AND SERVICE_TYPE_CD = "DRG";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
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

-- elif providertype
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

-- non standard rate (elif provider_type)
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


-- ROW 1110
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "90698"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND ZIP_CODE_UN = "11368";

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 5323162
    AND NETWORK_ID = "01344"
    AND PLACE_OF_SERVICE_CD = "11"
    AND SERVICE_CD = "90698"
    AND SERVICE_TYPE_CD = "CPT4";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
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

-- elif providertype
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

-- non standard rate (elif provider_type)
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


-- ROW 1128
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "92551"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND ZIP_CODE_UN = "22031";

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4252081
    AND NETWORK_ID = "00098"
    AND PLACE_OF_SERVICE_CD = "11"
    AND SERVICE_CD = "92551"
    AND SERVICE_TYPE_CD = "CPT4";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4252081
    AND NETWORK_ID = "00098"
    AND SERVICE_LOCATION_NBR = 2790243
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 4252081 
                       AND NETWORK_ID = "00098" 
                       AND SERVICE_LOCATION_NBR = 2790243  
                       AND SPECIALTY_CD = "10401"
                    ) 
                THEN "10401" ELSE '' END);

-- elif providertype
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4252081
    AND NETWORK_ID = "00098"
    AND SERVICE_LOCATION_NBR = 2790243
    AND PROVIDER_TYPE_CD = "PH";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4252081
    AND NETWORK_ID = "00098"
    AND SERVICE_LOCATION_NBR = 2790243;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "92551"
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
    SERVICE_CD = "92551"
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
                WHERE SERVICE_CD = "92551"
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

-- non standard rate (elif provider_type)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "92551"
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
                WHERE SERVICE_CD = "92551"
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
  SERVICE_CD = "92551"
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
    SERVICE_CD = "92551"
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
                WHERE SERVICE_CD = "92551"
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
    SERVICE_CD = "92551"
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
                WHERE SERVICE_CD = "92551"
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
  SERVICE_CD = "92551"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "11"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE = 'D' 
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;


-- ROW 1133
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "99459"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND ZIP_CODE_UN = "27713";

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 9018694
    AND NETWORK_ID = "00606"
    AND PLACE_OF_SERVICE_CD = "11"
    AND SERVICE_CD = "99459"
    AND SERVICE_TYPE_CD = "CPT4";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 9018694
    AND NETWORK_ID = "00606"
    AND SERVICE_LOCATION_NBR = 4045564
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 9018694 
                       AND NETWORK_ID = "00606" 
                       AND SERVICE_LOCATION_NBR = 4045564  
                       AND SPECIALTY_CD = @providerspecialtycode
                    ) 
                THEN @providerspecialtycode ELSE '' END);

-- elif providertype
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 9018694
    AND NETWORK_ID = "00606"
    AND SERVICE_LOCATION_NBR = 4045564
    AND PROVIDER_TYPE_CD = "NP";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 9018694
    AND NETWORK_ID = "00606"
    AND SERVICE_LOCATION_NBR = 4045564;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "99459"
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
    SERVICE_CD = "99459"
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
                WHERE SERVICE_CD = "99459"
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

-- non standard rate (elif provider_type)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "99459"
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
                WHERE SERVICE_CD = "99459"
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
  SERVICE_CD = "99459"
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
    SERVICE_CD = "99459"
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
                WHERE SERVICE_CD = "99459"
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
    SERVICE_CD = "99459"
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
                WHERE SERVICE_CD = "99459"
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
  SERVICE_CD = "99459"
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

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 9944998
    AND NETWORK_ID = "09696"
    AND PLACE_OF_SERVICE_CD = "11"
    AND SERVICE_CD = "97153"
    AND SERVICE_TYPE_CD = "CPT4";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
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

-- elif providertype
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

-- non standard rate (elif provider_type)
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


-- ROW 1147
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "93798"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "22"
    AND ZIP_CODE_UN = "27607";

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6380685
    AND NETWORK_ID = "00606"
    AND PLACE_OF_SERVICE_CD = "22"
    AND SERVICE_CD = "93798"
    AND SERVICE_TYPE_CD = "CPT4";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6380685
    AND NETWORK_ID = "00606"
    AND SERVICE_LOCATION_NBR = 111426
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 6380685 
                       AND NETWORK_ID = "00606" 
                       AND SERVICE_LOCATION_NBR = 111426  
                       AND SPECIALTY_CD = @providerspecialtycode
                    ) 
                THEN @providerspecialtycode ELSE '' END);

-- elif providertype
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6380685
    AND NETWORK_ID = "00606"
    AND SERVICE_LOCATION_NBR = 111426
    AND PROVIDER_TYPE_CD = "HO";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6380685
    AND NETWORK_ID = "00606"
    AND SERVICE_LOCATION_NBR = 111426;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "93798"
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
    SERVICE_CD = "93798"
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
                WHERE SERVICE_CD = "93798"
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

-- non standard rate (elif provider_type)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "93798"
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
                WHERE SERVICE_CD = "93798"
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
  SERVICE_CD = "93798"
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
    SERVICE_CD = "93798"
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
                WHERE SERVICE_CD = "93798"
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
    SERVICE_CD = "93798"
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
                WHERE SERVICE_CD = "93798"
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
  SERVICE_CD = "93798"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "22"
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE = 'D' 
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;


-- ROW 1176
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "99396"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND ZIP_CODE_UN = "16066";

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4187775
    AND NETWORK_ID = "02152"
    AND PLACE_OF_SERVICE_CD = "11"
    AND SERVICE_CD = "99396"
    AND SERVICE_TYPE_CD = "CPT4";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4187775
    AND NETWORK_ID = "02152"
    AND SERVICE_LOCATION_NBR = 7830924
    AND SPECIALTY_CD = 
    (
                SELECT CASE WHEN EXISTS 
                    (SELECT 1 
                     FROM CET_PROVIDERS 
                     WHERE PROVIDER_IDENTIFICATION_NBR = 4187775 
                       AND NETWORK_ID = "02152" 
                       AND SERVICE_LOCATION_NBR = 7830924  
                       AND SPECIALTY_CD = "10201"
                    ) 
                THEN "10201" ELSE '' END);

-- elif providertype
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4187775
    AND NETWORK_ID = "02152"
    AND SERVICE_LOCATION_NBR = 7830924
    AND PROVIDER_TYPE_CD = "PH";

-- else 
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4187775
    AND NETWORK_ID = "02152"
    AND SERVICE_LOCATION_NBR = 7830924;

-- standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = "99396"
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
    SERVICE_CD = "99396"
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
                WHERE SERVICE_CD = "99396"
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

-- non standard rate (elif provider_type)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM CET_RATES
WHERE
    SERVICE_CD = "99396"
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
                WHERE SERVICE_CD = "99396"
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
  SERVICE_CD = "99396"
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
    SERVICE_CD = "99396"
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
                WHERE SERVICE_CD = "99396"
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
    SERVICE_CD = "99396"
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
                WHERE SERVICE_CD = "99396"
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
  SERVICE_CD = "99396"
  AND SERVICE_TYPE_CD = "CPT4"
  AND PLACE_OF_SERVICE_CD = "11"
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

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4610543
    AND NETWORK_ID = "00357"
    AND PLACE_OF_SERVICE_CD = "11"
    AND SERVICE_CD = "3075F"
    AND SERVICE_TYPE_CD = "CPT4";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
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

-- elif providertype
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

-- non standard rate (elif provider_type)
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


-- ROW 660
-- OON
SELECT MAX(RATE) AS RATE
FROM CET_OON
WHERE
    SERVICE_CD = "99411"
    AND SERVICE_TYPE_CD = "CPT4"
    AND PLACE_OF_SERVICE_CD = "11"
    AND ZIP_CODE_UN = "6902";

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 5072460
    AND NETWORK_ID = "00387"
    AND PLACE_OF_SERVICE_CD = "11"
    AND SERVICE_CD = "99411"
    AND SERVICE_TYPE_CD = "CPT4";

-- building params PROVIDER_SPECIALTY_CD AND PROVODIER_TYPE (IF PROVIDER_SPECIALTY_CD)
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

-- elif providertype
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

-- non standard rate (elif provider_type)
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

