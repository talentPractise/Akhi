-- Row 291

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM `prv_ps_ce_dec_hcb_dev.CET_CLAIM_BASED_AMOUNTS`WHERE
    PROVIDER_IDENTIFICATION_NBR = 7765082
    AND NETWORK_ID = 1472
    AND PLACE_OF_SERVICE_CD = '11'
    AND SERVICE_CD = '81025'
    AND SERVICE_TYPE_CD = 'CPT4';

-- cet_provider table (if specialty_cd)
SELECT DISTINCT
    PROVIDER_BUSINESS_GROUP_NBR,
    PROVIDER_BUSINESS_GROUP_SCORE_NBR,
    PROVIDER_IDENTIFICATION_NBR,
    PRODUCT_CD,
    SERVICE_LOCATION_NBR,
    NETWORK_ID,
    RATING_SYSTEM_CD,
    EPDB_GEOGRAPHIC_AREA_CD
FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7765082
    AND NETWORK_ID = '01472'
    AND SERVICE_LOCATION_NBR = 4645059
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
                WHERE
                    PROVIDER_IDENTIFICATION_NBR = 7765082
                    AND NETWORK_ID = '01472'
                    AND SERVICE_LOCATION_NBR = 4645059
                    AND SPECIALTY_CD = '20101'
            )
            THEN '20101'
            ELSE ''
        END
    );

-- cet_provider table (elif provider_type_cd)
SELECT DISTINCT
    PROVIDER_BUSINESS_GROUP_NBR,
    PROVIDER_BUSINESS_GROUP_SCORE_NBR,
    PROVIDER_IDENTIFICATION_NBR,
    PRODUCT_CD,
    SERVICE_LOCATION_NBR,
    NETWORK_ID,
    RATING_SYSTEM_CD,
    EPDB_GEOGRAPHIC_AREA_CD
FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7765082
    AND NETWORK_ID = '01472'
    AND SERVICE_LOCATION_NBR = 4645059
    AND PROVIDER_TYPE_CD = 'PH';

-- standard rate
SELECT MAX(RATE) AS RATE
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    RATE_SYSTEM_CD = ''
    AND SERVICE_CD = '81025'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND GEOGRAPHIC_AREA_CD = ''
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')


-- non standard rate (if specialty_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    SERVICE_CD = '81025'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR =
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
                WHERE
                    SERVICE_CD = '81025'
                    AND SERVICE_TYPE_CD = 'CPT4'
                    AND PLACE_OF_SERVICE_CD = '11'
                    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR =
                    AND SPECIALTY_CD = '20101'
            )
            THEN '20101'
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- default rate (if provider_type_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    SERVICE_CD = '81025'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR =


    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
                WHERE
                    SERVICE_CD = '81025'
                    AND SERVICE_TYPE_CD = 'CPT4'
                    AND PLACE_OF_SERVICE_CD = '11'
                    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR =
                    AND SPECIALTY_CD = 'PH'
            )
            THEN 'PH'
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;



-- Row 327

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM `prv_ps_ce_dec_hcb_dev.CET_CLAIM_BASED_AMOUNTS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 5235644
    AND NETWORK_ID = 1344
    AND PLACE_OF_SERVICE_CD = '11'
    AND SERVICE_CD = '99491'
    AND SERVICE_TYPE_CD = 'CPT4';

-- cet_provider table (if specialty_cd)
SELECT DISTINCT
    PROVIDER_BUSINESS_GROUP_NBR,
    PROVIDER_BUSINESS_GROUP_SCORE_NBR,
    PROVIDER_IDENTIFICATION_NBR,
    PRODUCT_CD,
    SERVICE_LOCATION_NBR,
    NETWORK_ID,
    RATING_SYSTEM_CD,
    EPDB_GEOGRAPHIC_AREA_CD
FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 5235644
    AND NETWORK_ID = '01344'
    AND SERVICE_LOCATION_NBR = 4822843
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
                WHERE
                    PROVIDER_IDENTIFICATION_NBR = 5235644
                    AND NETWORK_ID = '01344'
                    AND SERVICE_LOCATION_NBR = 4822843
                    AND SPECIALTY_CD = '10201'
            )
            THEN '10201'
            ELSE ''
        END
    );

-- cet_provider table (elif provider_type_cd)
SELECT DISTINCT
    PROVIDER_BUSINESS_GROUP_NBR,
    PROVIDER_BUSINESS_GROUP_SCORE_NBR,
    PROVIDER_IDENTIFICATION_NBR,
    PRODUCT_CD,
    SERVICE_LOCATION_NBR,
    NETWORK_ID,
    RATING_SYSTEM_CD,
    EPDB_GEOGRAPHIC_AREA_CD
FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 5235644
    AND NETWORK_ID = '01344'
    AND SERVICE_LOCATION_NBR = 4822843
    AND PROVIDER_TYPE_CD = 'PH';

-- standard rate
SELECT MAX(RATE) AS RATE
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    RATE_SYSTEM_CD = ''
    AND SERVICE_CD = '99491'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND GEOGRAPHIC_AREA_CD = ''
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')


-- non standard rate (if specialty_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    SERVICE_CD = '99491'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR =
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
                WHERE
                    SERVICE_CD = '99491'
                    AND SERVICE_TYPE_CD = 'CPT4'
                    AND PLACE_OF_SERVICE_CD = '11'
                    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR =
                    AND SPECIALTY_CD = '10201'
            )
            THEN '10201'
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- default rate (if provider_type_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    SERVICE_CD = '99491'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR =


    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
                WHERE
                    SERVICE_CD = '99491'
                    AND SERVICE_TYPE_CD = 'CPT4'
                    AND PLACE_OF_SERVICE_CD = '11'
                    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR =
                    AND SPECIALTY_CD = 'PH'
            )
            THEN 'PH'
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;



-- Row 416

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM `prv_ps_ce_dec_hcb_dev.CET_CLAIM_BASED_AMOUNTS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 5540965
    AND NETWORK_ID = 173
    AND PLACE_OF_SERVICE_CD = '20'
    AND SERVICE_CD = 'S9083'
    AND SERVICE_TYPE_CD = 'HCPC';

-- cet_provider table (if specialty_cd)
SELECT DISTINCT
    PROVIDER_BUSINESS_GROUP_NBR,
    PROVIDER_BUSINESS_GROUP_SCORE_NBR,
    PROVIDER_IDENTIFICATION_NBR,
    PRODUCT_CD,
    SERVICE_LOCATION_NBR,
    NETWORK_ID,
    RATING_SYSTEM_CD,
    EPDB_GEOGRAPHIC_AREA_CD
FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 5540965
    AND NETWORK_ID = '00173'
    AND SERVICE_LOCATION_NBR = 5024387
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
                WHERE
                    PROVIDER_IDENTIFICATION_NBR = 5540965
                    AND NETWORK_ID = '00173'
                    AND SERVICE_LOCATION_NBR = 5024387
                    AND SPECIALTY_CD = ''
            )
            THEN ''
            ELSE ''
        END
    );

-- cet_provider table (elif provider_type_cd)
SELECT DISTINCT
    PROVIDER_BUSINESS_GROUP_NBR,
    PROVIDER_BUSINESS_GROUP_SCORE_NBR,
    PROVIDER_IDENTIFICATION_NBR,
    PRODUCT_CD,
    SERVICE_LOCATION_NBR,
    NETWORK_ID,
    RATING_SYSTEM_CD,
    EPDB_GEOGRAPHIC_AREA_CD
FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 5540965
    AND NETWORK_ID = '00173'
    AND SERVICE_LOCATION_NBR = 5024387
    AND PROVIDER_TYPE_CD = 'UC';

-- standard rate
SELECT MAX(RATE) AS RATE
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    RATE_SYSTEM_CD = ''
    AND SERVICE_CD = 'S9083'
    AND SERVICE_TYPE_CD = 'HCPC'
    AND GEOGRAPHIC_AREA_CD = ''
    AND PLACE_OF_SERVICE_CD = '20'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')


-- non standard rate (if specialty_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    SERVICE_CD = 'S9083'
    AND SERVICE_TYPE_CD = 'HCPC'
    AND PLACE_OF_SERVICE_CD = '20'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR =
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
                WHERE
                    SERVICE_CD = 'S9083'
                    AND SERVICE_TYPE_CD = 'HCPC'
                    AND PLACE_OF_SERVICE_CD = '20'
                    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR =
                    AND SPECIALTY_CD = ''
            )
            THEN ''
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- default rate (if provider_type_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    SERVICE_CD = 'S9083'
    AND SERVICE_TYPE_CD = 'HCPC'
    AND PLACE_OF_SERVICE_CD = '20'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR =


    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
                WHERE
                    SERVICE_CD = 'S9083'
                    AND SERVICE_TYPE_CD = 'HCPC'
                    AND PLACE_OF_SERVICE_CD = '20'
                    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR =
                    AND SPECIALTY_CD = 'UC'
            )
            THEN 'UC'
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;



-- Row 431

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM `prv_ps_ce_dec_hcb_dev.CET_CLAIM_BASED_AMOUNTS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6041595
    AND NETWORK_ID = 2284
    AND PLACE_OF_SERVICE_CD = '11'
    AND SERVICE_CD = '76830'
    AND SERVICE_TYPE_CD = 'CPT4';

-- cet_provider table (if specialty_cd)
SELECT DISTINCT
    PROVIDER_BUSINESS_GROUP_NBR,
    PROVIDER_BUSINESS_GROUP_SCORE_NBR,
    PROVIDER_IDENTIFICATION_NBR,
    PRODUCT_CD,
    SERVICE_LOCATION_NBR,
    NETWORK_ID,
    RATING_SYSTEM_CD,
    EPDB_GEOGRAPHIC_AREA_CD
FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6041595
    AND NETWORK_ID = '02284'
    AND SERVICE_LOCATION_NBR = 8377103
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
                WHERE
                    PROVIDER_IDENTIFICATION_NBR = 6041595
                    AND NETWORK_ID = '02284'
                    AND SERVICE_LOCATION_NBR = 8377103
                    AND SPECIALTY_CD = ''
            )
            THEN ''
            ELSE ''
        END
    );

-- cet_provider table (elif provider_type_cd)
SELECT DISTINCT
    PROVIDER_BUSINESS_GROUP_NBR,
    PROVIDER_BUSINESS_GROUP_SCORE_NBR,
    PROVIDER_IDENTIFICATION_NBR,
    PRODUCT_CD,
    SERVICE_LOCATION_NBR,
    NETWORK_ID,
    RATING_SYSTEM_CD,
    EPDB_GEOGRAPHIC_AREA_CD
FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6041595
    AND NETWORK_ID = '02284'
    AND SERVICE_LOCATION_NBR = 8377103
    AND PROVIDER_TYPE_CD = 'NP';

-- standard rate
SELECT MAX(RATE) AS RATE
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    RATE_SYSTEM_CD = ''
    AND SERVICE_CD = '76830'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND GEOGRAPHIC_AREA_CD = ''
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')


-- non standard rate (if specialty_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    SERVICE_CD = '76830'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR =
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
                WHERE
                    SERVICE_CD = '76830'
                    AND SERVICE_TYPE_CD = 'CPT4'
                    AND PLACE_OF_SERVICE_CD = '11'
                    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR =
                    AND SPECIALTY_CD = ''
            )
            THEN ''
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- default rate (if provider_type_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    SERVICE_CD = '76830'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR =


    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
                WHERE
                    SERVICE_CD = '76830'
                    AND SERVICE_TYPE_CD = 'CPT4'
                    AND PLACE_OF_SERVICE_CD = '11'
                    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR =
                    AND SPECIALTY_CD = 'NP'
            )
            THEN 'NP'
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;



-- Row 478

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM `prv_ps_ce_dec_hcb_dev.CET_CLAIM_BASED_AMOUNTS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 9415884
    AND NETWORK_ID = 398
    AND PLACE_OF_SERVICE_CD = '11'
    AND SERVICE_CD = '99391'
    AND SERVICE_TYPE_CD = 'CPT4';

-- cet_provider table (if specialty_cd)
SELECT DISTINCT
    PROVIDER_BUSINESS_GROUP_NBR,
    PROVIDER_BUSINESS_GROUP_SCORE_NBR,
    PROVIDER_IDENTIFICATION_NBR,
    PRODUCT_CD,
    SERVICE_LOCATION_NBR,
    NETWORK_ID,
    RATING_SYSTEM_CD,
    EPDB_GEOGRAPHIC_AREA_CD
FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 9415884
    AND NETWORK_ID = '00398'
    AND SERVICE_LOCATION_NBR = 2563105
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
                WHERE
                    PROVIDER_IDENTIFICATION_NBR = 9415884
                    AND NETWORK_ID = '00398'
                    AND SERVICE_LOCATION_NBR = 2563105
                    AND SPECIALTY_CD = '10401'
            )
            THEN '10401'
            ELSE ''
        END
    );

-- cet_provider table (elif provider_type_cd)
SELECT DISTINCT
    PROVIDER_BUSINESS_GROUP_NBR,
    PROVIDER_BUSINESS_GROUP_SCORE_NBR,
    PROVIDER_IDENTIFICATION_NBR,
    PRODUCT_CD,
    SERVICE_LOCATION_NBR,
    NETWORK_ID,
    RATING_SYSTEM_CD,
    EPDB_GEOGRAPHIC_AREA_CD
FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 9415884
    AND NETWORK_ID = '00398'
    AND SERVICE_LOCATION_NBR = 2563105
    AND PROVIDER_TYPE_CD = 'PH';

-- standard rate
SELECT MAX(RATE) AS RATE
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    RATE_SYSTEM_CD = ''
    AND SERVICE_CD = '99391'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND GEOGRAPHIC_AREA_CD = ''
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')


-- non standard rate (if specialty_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    SERVICE_CD = '99391'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR =
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
                WHERE
                    SERVICE_CD = '99391'
                    AND SERVICE_TYPE_CD = 'CPT4'
                    AND PLACE_OF_SERVICE_CD = '11'
                    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR =
                    AND SPECIALTY_CD = '10401'
            )
            THEN '10401'
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- default rate (if provider_type_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    SERVICE_CD = '99391'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR =


    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
                WHERE
                    SERVICE_CD = '99391'
                    AND SERVICE_TYPE_CD = 'CPT4'
                    AND PLACE_OF_SERVICE_CD = '11'
                    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR =
                    AND SPECIALTY_CD = 'PH'
            )
            THEN 'PH'
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;



-- Row 554

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM `prv_ps_ce_dec_hcb_dev.CET_CLAIM_BASED_AMOUNTS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7168790
    AND NETWORK_ID = 447
    AND PLACE_OF_SERVICE_CD = '11'
    AND SERVICE_CD = '76830'
    AND SERVICE_TYPE_CD = 'CPT4';

-- cet_provider table (if specialty_cd)
SELECT DISTINCT
    PROVIDER_BUSINESS_GROUP_NBR,
    PROVIDER_BUSINESS_GROUP_SCORE_NBR,
    PROVIDER_IDENTIFICATION_NBR,
    PRODUCT_CD,
    SERVICE_LOCATION_NBR,
    NETWORK_ID,
    RATING_SYSTEM_CD,
    EPDB_GEOGRAPHIC_AREA_CD
FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7168790
    AND NETWORK_ID = '00447'
    AND SERVICE_LOCATION_NBR = 1682595
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
                WHERE
                    PROVIDER_IDENTIFICATION_NBR = 7168790
                    AND NETWORK_ID = '00447'
                    AND SERVICE_LOCATION_NBR = 1682595
                    AND SPECIALTY_CD = ''
            )
            THEN ''
            ELSE ''
        END
    );

-- cet_provider table (elif provider_type_cd)
SELECT DISTINCT
    PROVIDER_BUSINESS_GROUP_NBR,
    PROVIDER_BUSINESS_GROUP_SCORE_NBR,
    PROVIDER_IDENTIFICATION_NBR,
    PRODUCT_CD,
    SERVICE_LOCATION_NBR,
    NETWORK_ID,
    RATING_SYSTEM_CD,
    EPDB_GEOGRAPHIC_AREA_CD
FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7168790
    AND NETWORK_ID = '00447'
    AND SERVICE_LOCATION_NBR = 1682595
    AND PROVIDER_TYPE_CD = 'RC';

-- standard rate
SELECT MAX(RATE) AS RATE
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    RATE_SYSTEM_CD = ''
    AND SERVICE_CD = '76830'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND GEOGRAPHIC_AREA_CD = ''
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')


-- non standard rate (if specialty_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    SERVICE_CD = '76830'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR =
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
                WHERE
                    SERVICE_CD = '76830'
                    AND SERVICE_TYPE_CD = 'CPT4'
                    AND PLACE_OF_SERVICE_CD = '11'
                    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR =
                    AND SPECIALTY_CD = ''
            )
            THEN ''
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- default rate (if provider_type_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    SERVICE_CD = '76830'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR =


    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
                WHERE
                    SERVICE_CD = '76830'
                    AND SERVICE_TYPE_CD = 'CPT4'
                    AND PLACE_OF_SERVICE_CD = '11'
                    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR =
                    AND SPECIALTY_CD = 'RC'
            )
            THEN 'RC'
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;



-- Row 601

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM `prv_ps_ce_dec_hcb_dev.CET_CLAIM_BASED_AMOUNTS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7713675
    AND NETWORK_ID = 437
    AND PLACE_OF_SERVICE_CD = '11'
    AND SERVICE_CD = '90461'
    AND SERVICE_TYPE_CD = 'CPT4';

-- cet_provider table (if specialty_cd)
SELECT DISTINCT
    PROVIDER_BUSINESS_GROUP_NBR,
    PROVIDER_BUSINESS_GROUP_SCORE_NBR,
    PROVIDER_IDENTIFICATION_NBR,
    PRODUCT_CD,
    SERVICE_LOCATION_NBR,
    NETWORK_ID,
    RATING_SYSTEM_CD,
    EPDB_GEOGRAPHIC_AREA_CD
FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7713675
    AND NETWORK_ID = '00437'
    AND SERVICE_LOCATION_NBR = 6956244
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
                WHERE
                    PROVIDER_IDENTIFICATION_NBR = 7713675
                    AND NETWORK_ID = '00437'
                    AND SERVICE_LOCATION_NBR = 6956244
                    AND SPECIALTY_CD = '10401'
            )
            THEN '10401'
            ELSE ''
        END
    );

-- cet_provider table (elif provider_type_cd)
SELECT DISTINCT
    PROVIDER_BUSINESS_GROUP_NBR,
    PROVIDER_BUSINESS_GROUP_SCORE_NBR,
    PROVIDER_IDENTIFICATION_NBR,
    PRODUCT_CD,
    SERVICE_LOCATION_NBR,
    NETWORK_ID,
    RATING_SYSTEM_CD,
    EPDB_GEOGRAPHIC_AREA_CD
FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7713675
    AND NETWORK_ID = '00437'
    AND SERVICE_LOCATION_NBR = 6956244
    AND PROVIDER_TYPE_CD = 'PH';

-- standard rate
SELECT MAX(RATE) AS RATE
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    RATE_SYSTEM_CD = ''
    AND SERVICE_CD = '90461'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND GEOGRAPHIC_AREA_CD = ''
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')


-- non standard rate (if specialty_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    SERVICE_CD = '90461'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR =
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
                WHERE
                    SERVICE_CD = '90461'
                    AND SERVICE_TYPE_CD = 'CPT4'
                    AND PLACE_OF_SERVICE_CD = '11'
                    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR =
                    AND SPECIALTY_CD = '10401'
            )
            THEN '10401'
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- default rate (if provider_type_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    SERVICE_CD = '90461'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR =


    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
                WHERE
                    SERVICE_CD = '90461'
                    AND SERVICE_TYPE_CD = 'CPT4'
                    AND PLACE_OF_SERVICE_CD = '11'
                    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR =
                    AND SPECIALTY_CD = 'PH'
            )
            THEN 'PH'
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;



-- Row 700

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM `prv_ps_ce_dec_hcb_dev.CET_CLAIM_BASED_AMOUNTS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7712368
    AND NETWORK_ID = 385
    AND PLACE_OF_SERVICE_CD = '21'
    AND SERVICE_CD = '99233'
    AND SERVICE_TYPE_CD = 'CPT4';

-- cet_provider table (if specialty_cd)
SELECT DISTINCT
    PROVIDER_BUSINESS_GROUP_NBR,
    PROVIDER_BUSINESS_GROUP_SCORE_NBR,
    PROVIDER_IDENTIFICATION_NBR,
    PRODUCT_CD,
    SERVICE_LOCATION_NBR,
    NETWORK_ID,
    RATING_SYSTEM_CD,
    EPDB_GEOGRAPHIC_AREA_CD
FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7712368
    AND NETWORK_ID = '00385'
    AND SERVICE_LOCATION_NBR = 4836453
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
                WHERE
                    PROVIDER_IDENTIFICATION_NBR = 7712368
                    AND NETWORK_ID = '00385'
                    AND SERVICE_LOCATION_NBR = 4836453
                    AND SPECIALTY_CD = '11001'
            )
            THEN '11001'
            ELSE ''
        END
    );

-- cet_provider table (elif provider_type_cd)
SELECT DISTINCT
    PROVIDER_BUSINESS_GROUP_NBR,
    PROVIDER_BUSINESS_GROUP_SCORE_NBR,
    PROVIDER_IDENTIFICATION_NBR,
    PRODUCT_CD,
    SERVICE_LOCATION_NBR,
    NETWORK_ID,
    RATING_SYSTEM_CD,
    EPDB_GEOGRAPHIC_AREA_CD
FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7712368
    AND NETWORK_ID = '00385'
    AND SERVICE_LOCATION_NBR = 4836453
    AND PROVIDER_TYPE_CD = 'PH';

-- standard rate
SELECT MAX(RATE) AS RATE
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    RATE_SYSTEM_CD = ''
    AND SERVICE_CD = '99233'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND GEOGRAPHIC_AREA_CD = ''
    AND PLACE_OF_SERVICE_CD = '21'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')


-- non standard rate (if specialty_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    SERVICE_CD = '99233'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '21'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR =
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
                WHERE
                    SERVICE_CD = '99233'
                    AND SERVICE_TYPE_CD = 'CPT4'
                    AND PLACE_OF_SERVICE_CD = '21'
                    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR =
                    AND SPECIALTY_CD = '11001'
            )
            THEN '11001'
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- default rate (if provider_type_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    SERVICE_CD = '99233'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '21'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR =


    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
                WHERE
                    SERVICE_CD = '99233'
                    AND SERVICE_TYPE_CD = 'CPT4'
                    AND PLACE_OF_SERVICE_CD = '21'
                    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR =
                    AND SPECIALTY_CD = 'PH'
            )
            THEN 'PH'
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;



-- Row 723

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM `prv_ps_ce_dec_hcb_dev.CET_CLAIM_BASED_AMOUNTS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 8368864
    AND NETWORK_ID = 3780
    AND PLACE_OF_SERVICE_CD = '11'
    AND SERVICE_CD = '99214'
    AND SERVICE_TYPE_CD = 'CPT4';

-- cet_provider table (if specialty_cd)
SELECT DISTINCT
    PROVIDER_BUSINESS_GROUP_NBR,
    PROVIDER_BUSINESS_GROUP_SCORE_NBR,
    PROVIDER_IDENTIFICATION_NBR,
    PRODUCT_CD,
    SERVICE_LOCATION_NBR,
    NETWORK_ID,
    RATING_SYSTEM_CD,
    EPDB_GEOGRAPHIC_AREA_CD
FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 8368864
    AND NETWORK_ID = '03780'
    AND SERVICE_LOCATION_NBR = 4153418
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
                WHERE
                    PROVIDER_IDENTIFICATION_NBR = 8368864
                    AND NETWORK_ID = '03780'
                    AND SERVICE_LOCATION_NBR = 4153418
                    AND SPECIALTY_CD = '10401'
            )
            THEN '10401'
            ELSE ''
        END
    );

-- cet_provider table (elif provider_type_cd)
SELECT DISTINCT
    PROVIDER_BUSINESS_GROUP_NBR,
    PROVIDER_BUSINESS_GROUP_SCORE_NBR,
    PROVIDER_IDENTIFICATION_NBR,
    PRODUCT_CD,
    SERVICE_LOCATION_NBR,
    NETWORK_ID,
    RATING_SYSTEM_CD,
    EPDB_GEOGRAPHIC_AREA_CD
FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 8368864
    AND NETWORK_ID = '03780'
    AND SERVICE_LOCATION_NBR = 4153418
    AND PROVIDER_TYPE_CD = 'PH';

-- standard rate
SELECT MAX(RATE) AS RATE
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    RATE_SYSTEM_CD = ''
    AND SERVICE_CD = '99214'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND GEOGRAPHIC_AREA_CD = ''
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')


-- non standard rate (if specialty_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    SERVICE_CD = '99214'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR =
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
                WHERE
                    SERVICE_CD = '99214'
                    AND SERVICE_TYPE_CD = 'CPT4'
                    AND PLACE_OF_SERVICE_CD = '11'
                    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR =
                    AND SPECIALTY_CD = '10401'
            )
            THEN '10401'
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- default rate (if provider_type_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    SERVICE_CD = '99214'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR =


    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
                WHERE
                    SERVICE_CD = '99214'
                    AND SERVICE_TYPE_CD = 'CPT4'
                    AND PLACE_OF_SERVICE_CD = '11'
                    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR =
                    AND SPECIALTY_CD = 'PH'
            )
            THEN 'PH'
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;



-- Row 728

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM `prv_ps_ce_dec_hcb_dev.CET_CLAIM_BASED_AMOUNTS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7727548
    AND NETWORK_ID = 98
    AND PLACE_OF_SERVICE_CD = '11'
    AND SERVICE_CD = '96160'
    AND SERVICE_TYPE_CD = 'CPT4';

-- cet_provider table (if specialty_cd)
SELECT DISTINCT
    PROVIDER_BUSINESS_GROUP_NBR,
    PROVIDER_BUSINESS_GROUP_SCORE_NBR,
    PROVIDER_IDENTIFICATION_NBR,
    PRODUCT_CD,
    SERVICE_LOCATION_NBR,
    NETWORK_ID,
    RATING_SYSTEM_CD,
    EPDB_GEOGRAPHIC_AREA_CD
FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7727548
    AND NETWORK_ID = '00098'
    AND SERVICE_LOCATION_NBR = 890166
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
                WHERE
                    PROVIDER_IDENTIFICATION_NBR = 7727548
                    AND NETWORK_ID = '00098'
                    AND SERVICE_LOCATION_NBR = 890166
                    AND SPECIALTY_CD = '20101'
            )
            THEN '20101'
            ELSE ''
        END
    );

-- cet_provider table (elif provider_type_cd)
SELECT DISTINCT
    PROVIDER_BUSINESS_GROUP_NBR,
    PROVIDER_BUSINESS_GROUP_SCORE_NBR,
    PROVIDER_IDENTIFICATION_NBR,
    PRODUCT_CD,
    SERVICE_LOCATION_NBR,
    NETWORK_ID,
    RATING_SYSTEM_CD,
    EPDB_GEOGRAPHIC_AREA_CD
FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7727548
    AND NETWORK_ID = '00098'
    AND SERVICE_LOCATION_NBR = 890166
    AND PROVIDER_TYPE_CD = 'PH';

-- standard rate
SELECT MAX(RATE) AS RATE
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    RATE_SYSTEM_CD = ''
    AND SERVICE_CD = '96160'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND GEOGRAPHIC_AREA_CD = ''
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')


-- non standard rate (if specialty_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    SERVICE_CD = '96160'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR =
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
                WHERE
                    SERVICE_CD = '96160'
                    AND SERVICE_TYPE_CD = 'CPT4'
                    AND PLACE_OF_SERVICE_CD = '11'
                    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR =
                    AND SPECIALTY_CD = '20101'
            )
            THEN '20101'
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- default rate (if provider_type_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    SERVICE_CD = '96160'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR =


    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
                WHERE
                    SERVICE_CD = '96160'
                    AND SERVICE_TYPE_CD = 'CPT4'
                    AND PLACE_OF_SERVICE_CD = '11'
                    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR =
                    AND SPECIALTY_CD = 'PH'
            )
            THEN 'PH'
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;



-- Row 742

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM `prv_ps_ce_dec_hcb_dev.CET_CLAIM_BASED_AMOUNTS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7539690
    AND NETWORK_ID = 606
    AND PLACE_OF_SERVICE_CD = '22'
    AND SERVICE_CD = 'H0035'
    AND SERVICE_TYPE_CD = 'HCPC';

-- cet_provider table (if specialty_cd)
SELECT DISTINCT
    PROVIDER_BUSINESS_GROUP_NBR,
    PROVIDER_BUSINESS_GROUP_SCORE_NBR,
    PROVIDER_IDENTIFICATION_NBR,
    PRODUCT_CD,
    SERVICE_LOCATION_NBR,
    NETWORK_ID,
    RATING_SYSTEM_CD,
    EPDB_GEOGRAPHIC_AREA_CD
FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7539690
    AND NETWORK_ID = '00606'
    AND SERVICE_LOCATION_NBR = 158112
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
                WHERE
                    PROVIDER_IDENTIFICATION_NBR = 7539690
                    AND NETWORK_ID = '00606'
                    AND SERVICE_LOCATION_NBR = 158112
                    AND SPECIALTY_CD = ''
            )
            THEN ''
            ELSE ''
        END
    );

-- cet_provider table (elif provider_type_cd)
SELECT DISTINCT
    PROVIDER_BUSINESS_GROUP_NBR,
    PROVIDER_BUSINESS_GROUP_SCORE_NBR,
    PROVIDER_IDENTIFICATION_NBR,
    PRODUCT_CD,
    SERVICE_LOCATION_NBR,
    NETWORK_ID,
    RATING_SYSTEM_CD,
    EPDB_GEOGRAPHIC_AREA_CD
FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7539690
    AND NETWORK_ID = '00606'
    AND SERVICE_LOCATION_NBR = 158112
    AND PROVIDER_TYPE_CD = 'PSH';

-- standard rate
SELECT MAX(RATE) AS RATE
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    RATE_SYSTEM_CD = ''
    AND SERVICE_CD = 'H0035'
    AND SERVICE_TYPE_CD = 'HCPC'
    AND GEOGRAPHIC_AREA_CD = ''
    AND PLACE_OF_SERVICE_CD = '22'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')


-- non standard rate (if specialty_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    SERVICE_CD = 'H0035'
    AND SERVICE_TYPE_CD = 'HCPC'
    AND PLACE_OF_SERVICE_CD = '22'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR =
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
                WHERE
                    SERVICE_CD = 'H0035'
                    AND SERVICE_TYPE_CD = 'HCPC'
                    AND PLACE_OF_SERVICE_CD = '22'
                    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR =
                    AND SPECIALTY_CD = ''
            )
            THEN ''
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- default rate (if provider_type_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    SERVICE_CD = 'H0035'
    AND SERVICE_TYPE_CD = 'HCPC'
    AND PLACE_OF_SERVICE_CD = '22'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR =


    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
                WHERE
                    SERVICE_CD = 'H0035'
                    AND SERVICE_TYPE_CD = 'HCPC'
                    AND PLACE_OF_SERVICE_CD = '22'
                    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR =
                    AND SPECIALTY_CD = 'PSH'
            )
            THEN 'PSH'
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;



-- Row 757

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM `prv_ps_ce_dec_hcb_dev.CET_CLAIM_BASED_AMOUNTS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7333594
    AND NETWORK_ID = 357
    AND PLACE_OF_SERVICE_CD = '11'
    AND SERVICE_CD = '99213'
    AND SERVICE_TYPE_CD = 'CPT4';

-- cet_provider table (if specialty_cd)
SELECT DISTINCT
    PROVIDER_BUSINESS_GROUP_NBR,
    PROVIDER_BUSINESS_GROUP_SCORE_NBR,
    PROVIDER_IDENTIFICATION_NBR,
    PRODUCT_CD,
    SERVICE_LOCATION_NBR,
    NETWORK_ID,
    RATING_SYSTEM_CD,
    EPDB_GEOGRAPHIC_AREA_CD
FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7333594
    AND NETWORK_ID = '00357'
    AND SERVICE_LOCATION_NBR = 4071677
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
                WHERE
                    PROVIDER_IDENTIFICATION_NBR = 7333594
                    AND NETWORK_ID = '00357'
                    AND SERVICE_LOCATION_NBR = 4071677
                    AND SPECIALTY_CD = '11002'
            )
            THEN '11002'
            ELSE ''
        END
    );

-- cet_provider table (elif provider_type_cd)
SELECT DISTINCT
    PROVIDER_BUSINESS_GROUP_NBR,
    PROVIDER_BUSINESS_GROUP_SCORE_NBR,
    PROVIDER_IDENTIFICATION_NBR,
    PRODUCT_CD,
    SERVICE_LOCATION_NBR,
    NETWORK_ID,
    RATING_SYSTEM_CD,
    EPDB_GEOGRAPHIC_AREA_CD
FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7333594
    AND NETWORK_ID = '00357'
    AND SERVICE_LOCATION_NBR = 4071677
    AND PROVIDER_TYPE_CD = 'PH';

-- standard rate
SELECT MAX(RATE) AS RATE
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    RATE_SYSTEM_CD = ''
    AND SERVICE_CD = '99213'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND GEOGRAPHIC_AREA_CD = ''
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')


-- non standard rate (if specialty_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    SERVICE_CD = '99213'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR =
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
                WHERE
                    SERVICE_CD = '99213'
                    AND SERVICE_TYPE_CD = 'CPT4'
                    AND PLACE_OF_SERVICE_CD = '11'
                    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR =
                    AND SPECIALTY_CD = '11002'
            )
            THEN '11002'
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- default rate (if provider_type_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    SERVICE_CD = '99213'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR =


    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
                WHERE
                    SERVICE_CD = '99213'
                    AND SERVICE_TYPE_CD = 'CPT4'
                    AND PLACE_OF_SERVICE_CD = '11'
                    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR =
                    AND SPECIALTY_CD = 'PH'
            )
            THEN 'PH'
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;



-- Row 821

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM `prv_ps_ce_dec_hcb_dev.CET_CLAIM_BASED_AMOUNTS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4998887
    AND NETWORK_ID = 639
    AND PLACE_OF_SERVICE_CD = '11'
    AND SERVICE_CD = '81003'
    AND SERVICE_TYPE_CD = 'CPT4';

-- cet_provider table (if specialty_cd)
SELECT DISTINCT
    PROVIDER_BUSINESS_GROUP_NBR,
    PROVIDER_BUSINESS_GROUP_SCORE_NBR,
    PROVIDER_IDENTIFICATION_NBR,
    PRODUCT_CD,
    SERVICE_LOCATION_NBR,
    NETWORK_ID,
    RATING_SYSTEM_CD,
    EPDB_GEOGRAPHIC_AREA_CD
FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4998887
    AND NETWORK_ID = '00639'
    AND SERVICE_LOCATION_NBR = 2156779
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
                WHERE
                    PROVIDER_IDENTIFICATION_NBR = 4998887
                    AND NETWORK_ID = '00639'
                    AND SERVICE_LOCATION_NBR = 2156779
                    AND SPECIALTY_CD = '20101'
            )
            THEN '20101'
            ELSE ''
        END
    );

-- cet_provider table (elif provider_type_cd)
SELECT DISTINCT
    PROVIDER_BUSINESS_GROUP_NBR,
    PROVIDER_BUSINESS_GROUP_SCORE_NBR,
    PROVIDER_IDENTIFICATION_NBR,
    PRODUCT_CD,
    SERVICE_LOCATION_NBR,
    NETWORK_ID,
    RATING_SYSTEM_CD,
    EPDB_GEOGRAPHIC_AREA_CD
FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4998887
    AND NETWORK_ID = '00639'
    AND SERVICE_LOCATION_NBR = 2156779
    AND PROVIDER_TYPE_CD = 'PH';

-- standard rate
SELECT MAX(RATE) AS RATE
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    RATE_SYSTEM_CD = ''
    AND SERVICE_CD = '81003'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND GEOGRAPHIC_AREA_CD = ''
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')


-- non standard rate (if specialty_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    SERVICE_CD = '81003'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR =
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
                WHERE
                    SERVICE_CD = '81003'
                    AND SERVICE_TYPE_CD = 'CPT4'
                    AND PLACE_OF_SERVICE_CD = '11'
                    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR =
                    AND SPECIALTY_CD = '20101'
            )
            THEN '20101'
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- default rate (if provider_type_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    SERVICE_CD = '81003'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR =


    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
                WHERE
                    SERVICE_CD = '81003'
                    AND SERVICE_TYPE_CD = 'CPT4'
                    AND PLACE_OF_SERVICE_CD = '11'
                    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR =
                    AND SPECIALTY_CD = 'PH'
            )
            THEN 'PH'
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;



-- Row 823

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM `prv_ps_ce_dec_hcb_dev.CET_CLAIM_BASED_AMOUNTS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 9731502
    AND NETWORK_ID = 447
    AND PLACE_OF_SERVICE_CD = '11'
    AND SERVICE_CD = '91321'
    AND SERVICE_TYPE_CD = 'CPT4';

-- cet_provider table (if specialty_cd)
SELECT DISTINCT
    PROVIDER_BUSINESS_GROUP_NBR,
    PROVIDER_BUSINESS_GROUP_SCORE_NBR,
    PROVIDER_IDENTIFICATION_NBR,
    PRODUCT_CD,
    SERVICE_LOCATION_NBR,
    NETWORK_ID,
    RATING_SYSTEM_CD,
    EPDB_GEOGRAPHIC_AREA_CD
FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 9731502
    AND NETWORK_ID = '00447'
    AND SERVICE_LOCATION_NBR = 6605677
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
                WHERE
                    PROVIDER_IDENTIFICATION_NBR = 9731502
                    AND NETWORK_ID = '00447'
                    AND SERVICE_LOCATION_NBR = 6605677
                    AND SPECIALTY_CD = ''
            )
            THEN ''
            ELSE ''
        END
    );

-- cet_provider table (elif provider_type_cd)
SELECT DISTINCT
    PROVIDER_BUSINESS_GROUP_NBR,
    PROVIDER_BUSINESS_GROUP_SCORE_NBR,
    PROVIDER_IDENTIFICATION_NBR,
    PRODUCT_CD,
    SERVICE_LOCATION_NBR,
    NETWORK_ID,
    RATING_SYSTEM_CD,
    EPDB_GEOGRAPHIC_AREA_CD
FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 9731502
    AND NETWORK_ID = '00447'
    AND SERVICE_LOCATION_NBR = 6605677
    AND PROVIDER_TYPE_CD = 'OMP';

-- standard rate
SELECT MAX(RATE) AS RATE
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    RATE_SYSTEM_CD = ''
    AND SERVICE_CD = '91321'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND GEOGRAPHIC_AREA_CD = ''
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')


-- non standard rate (if specialty_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    SERVICE_CD = '91321'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR =
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
                WHERE
                    SERVICE_CD = '91321'
                    AND SERVICE_TYPE_CD = 'CPT4'
                    AND PLACE_OF_SERVICE_CD = '11'
                    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR =
                    AND SPECIALTY_CD = ''
            )
            THEN ''
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- default rate (if provider_type_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    SERVICE_CD = '91321'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR =


    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
                WHERE
                    SERVICE_CD = '91321'
                    AND SERVICE_TYPE_CD = 'CPT4'
                    AND PLACE_OF_SERVICE_CD = '11'
                    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR =
                    AND SPECIALTY_CD = 'OMP'
            )
            THEN 'OMP'
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;



-- Row 855

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM `prv_ps_ce_dec_hcb_dev.CET_CLAIM_BASED_AMOUNTS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 8715650
    AND NETWORK_ID = 190
    AND PLACE_OF_SERVICE_CD = '23'
    AND SERVICE_CD = '99284'
    AND SERVICE_TYPE_CD = 'CPT4';

-- cet_provider table (if specialty_cd)
SELECT DISTINCT
    PROVIDER_BUSINESS_GROUP_NBR,
    PROVIDER_BUSINESS_GROUP_SCORE_NBR,
    PROVIDER_IDENTIFICATION_NBR,
    PRODUCT_CD,
    SERVICE_LOCATION_NBR,
    NETWORK_ID,
    RATING_SYSTEM_CD,
    EPDB_GEOGRAPHIC_AREA_CD
FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 8715650
    AND NETWORK_ID = '00190'
    AND SERVICE_LOCATION_NBR = 8591815
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
                WHERE
                    PROVIDER_IDENTIFICATION_NBR = 8715650
                    AND NETWORK_ID = '00190'
                    AND SERVICE_LOCATION_NBR = 8591815
                    AND SPECIALTY_CD = '10701'
            )
            THEN '10701'
            ELSE ''
        END
    );

-- cet_provider table (elif provider_type_cd)
SELECT DISTINCT
    PROVIDER_BUSINESS_GROUP_NBR,
    PROVIDER_BUSINESS_GROUP_SCORE_NBR,
    PROVIDER_IDENTIFICATION_NBR,
    PRODUCT_CD,
    SERVICE_LOCATION_NBR,
    NETWORK_ID,
    RATING_SYSTEM_CD,
    EPDB_GEOGRAPHIC_AREA_CD
FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 8715650
    AND NETWORK_ID = '00190'
    AND SERVICE_LOCATION_NBR = 8591815
    AND PROVIDER_TYPE_CD = 'PH';

-- standard rate
SELECT MAX(RATE) AS RATE
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    RATE_SYSTEM_CD = ''
    AND SERVICE_CD = '99284'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND GEOGRAPHIC_AREA_CD = ''
    AND PLACE_OF_SERVICE_CD = '23'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')


-- non standard rate (if specialty_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    SERVICE_CD = '99284'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '23'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR =
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
                WHERE
                    SERVICE_CD = '99284'
                    AND SERVICE_TYPE_CD = 'CPT4'
                    AND PLACE_OF_SERVICE_CD = '23'
                    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR =
                    AND SPECIALTY_CD = '10701'
            )
            THEN '10701'
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- default rate (if provider_type_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    SERVICE_CD = '99284'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '23'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR =


    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
                WHERE
                    SERVICE_CD = '99284'
                    AND SERVICE_TYPE_CD = 'CPT4'
                    AND PLACE_OF_SERVICE_CD = '23'
                    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR =
                    AND SPECIALTY_CD = 'PH'
            )
            THEN 'PH'
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;



-- Row 857

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM `prv_ps_ce_dec_hcb_dev.CET_CLAIM_BASED_AMOUNTS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7258128
    AND NETWORK_ID = 357
    AND PLACE_OF_SERVICE_CD = '11'
    AND SERVICE_CD = '93000'
    AND SERVICE_TYPE_CD = 'CPT4';

-- cet_provider table (if specialty_cd)
SELECT DISTINCT
    PROVIDER_BUSINESS_GROUP_NBR,
    PROVIDER_BUSINESS_GROUP_SCORE_NBR,
    PROVIDER_IDENTIFICATION_NBR,
    PRODUCT_CD,
    SERVICE_LOCATION_NBR,
    NETWORK_ID,
    RATING_SYSTEM_CD,
    EPDB_GEOGRAPHIC_AREA_CD
FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7258128
    AND NETWORK_ID = '00357'
    AND SERVICE_LOCATION_NBR = 5394720
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
                WHERE
                    PROVIDER_IDENTIFICATION_NBR = 7258128
                    AND NETWORK_ID = '00357'
                    AND SERVICE_LOCATION_NBR = 5394720
                    AND SPECIALTY_CD = '10301'
            )
            THEN '10301'
            ELSE ''
        END
    );

-- cet_provider table (elif provider_type_cd)
SELECT DISTINCT
    PROVIDER_BUSINESS_GROUP_NBR,
    PROVIDER_BUSINESS_GROUP_SCORE_NBR,
    PROVIDER_IDENTIFICATION_NBR,
    PRODUCT_CD,
    SERVICE_LOCATION_NBR,
    NETWORK_ID,
    RATING_SYSTEM_CD,
    EPDB_GEOGRAPHIC_AREA_CD
FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 7258128
    AND NETWORK_ID = '00357'
    AND SERVICE_LOCATION_NBR = 5394720
    AND PROVIDER_TYPE_CD = 'PH';

-- standard rate
SELECT MAX(RATE) AS RATE
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    RATE_SYSTEM_CD = ''
    AND SERVICE_CD = '93000'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND GEOGRAPHIC_AREA_CD = ''
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')


-- non standard rate (if specialty_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    SERVICE_CD = '93000'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR =
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
                WHERE
                    SERVICE_CD = '93000'
                    AND SERVICE_TYPE_CD = 'CPT4'
                    AND PLACE_OF_SERVICE_CD = '11'
                    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR =
                    AND SPECIALTY_CD = '10301'
            )
            THEN '10301'
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- default rate (if provider_type_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    SERVICE_CD = '93000'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR =


    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
                WHERE
                    SERVICE_CD = '93000'
                    AND SERVICE_TYPE_CD = 'CPT4'
                    AND PLACE_OF_SERVICE_CD = '11'
                    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR =
                    AND SPECIALTY_CD = 'PH'
            )
            THEN 'PH'
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;



-- Row 891

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM `prv_ps_ce_dec_hcb_dev.CET_CLAIM_BASED_AMOUNTS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4720723
    AND NETWORK_ID = 391
    AND PLACE_OF_SERVICE_CD = '11'
    AND SERVICE_CD = '90661'
    AND SERVICE_TYPE_CD = 'CPT4';

-- cet_provider table (if specialty_cd)
SELECT DISTINCT
    PROVIDER_BUSINESS_GROUP_NBR,
    PROVIDER_BUSINESS_GROUP_SCORE_NBR,
    PROVIDER_IDENTIFICATION_NBR,
    PRODUCT_CD,
    SERVICE_LOCATION_NBR,
    NETWORK_ID,
    RATING_SYSTEM_CD,
    EPDB_GEOGRAPHIC_AREA_CD
FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4720723
    AND NETWORK_ID = '00391'
    AND SERVICE_LOCATION_NBR = 48221
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
                WHERE
                    PROVIDER_IDENTIFICATION_NBR = 4720723
                    AND NETWORK_ID = '00391'
                    AND SERVICE_LOCATION_NBR = 48221
                    AND SPECIALTY_CD = '90353'
            )
            THEN '90353'
            ELSE ''
        END
    );

-- cet_provider table (elif provider_type_cd)
SELECT DISTINCT
    PROVIDER_BUSINESS_GROUP_NBR,
    PROVIDER_BUSINESS_GROUP_SCORE_NBR,
    PROVIDER_IDENTIFICATION_NBR,
    PRODUCT_CD,
    SERVICE_LOCATION_NBR,
    NETWORK_ID,
    RATING_SYSTEM_CD,
    EPDB_GEOGRAPHIC_AREA_CD
FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4720723
    AND NETWORK_ID = '00391'
    AND SERVICE_LOCATION_NBR = 48221
    AND PROVIDER_TYPE_CD = 'NP';

-- standard rate
SELECT MAX(RATE) AS RATE
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    RATE_SYSTEM_CD = ''
    AND SERVICE_CD = '90661'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND GEOGRAPHIC_AREA_CD = ''
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')


-- non standard rate (if specialty_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    SERVICE_CD = '90661'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR =
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
                WHERE
                    SERVICE_CD = '90661'
                    AND SERVICE_TYPE_CD = 'CPT4'
                    AND PLACE_OF_SERVICE_CD = '11'
                    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR =
                    AND SPECIALTY_CD = '90353'
            )
            THEN '90353'
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- default rate (if provider_type_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    SERVICE_CD = '90661'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR =


    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
                WHERE
                    SERVICE_CD = '90661'
                    AND SERVICE_TYPE_CD = 'CPT4'
                    AND PLACE_OF_SERVICE_CD = '11'
                    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR =
                    AND SPECIALTY_CD = 'NP'
            )
            THEN 'NP'
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;



-- Row 1023

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM `prv_ps_ce_dec_hcb_dev.CET_CLAIM_BASED_AMOUNTS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 9400970
    AND NETWORK_ID = 385
    AND PLACE_OF_SERVICE_CD = '11'
    AND SERVICE_CD = '99381'
    AND SERVICE_TYPE_CD = 'CPT4';

-- cet_provider table (if specialty_cd)
SELECT DISTINCT
    PROVIDER_BUSINESS_GROUP_NBR,
    PROVIDER_BUSINESS_GROUP_SCORE_NBR,
    PROVIDER_IDENTIFICATION_NBR,
    PRODUCT_CD,
    SERVICE_LOCATION_NBR,
    NETWORK_ID,
    RATING_SYSTEM_CD,
    EPDB_GEOGRAPHIC_AREA_CD
FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 9400970
    AND NETWORK_ID = '00385'
    AND SERVICE_LOCATION_NBR = 712831
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
                WHERE
                    PROVIDER_IDENTIFICATION_NBR = 9400970
                    AND NETWORK_ID = '00385'
                    AND SERVICE_LOCATION_NBR = 712831
                    AND SPECIALTY_CD = '10401'
            )
            THEN '10401'
            ELSE ''
        END
    );

-- cet_provider table (elif provider_type_cd)
SELECT DISTINCT
    PROVIDER_BUSINESS_GROUP_NBR,
    PROVIDER_BUSINESS_GROUP_SCORE_NBR,
    PROVIDER_IDENTIFICATION_NBR,
    PRODUCT_CD,
    SERVICE_LOCATION_NBR,
    NETWORK_ID,
    RATING_SYSTEM_CD,
    EPDB_GEOGRAPHIC_AREA_CD
FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 9400970
    AND NETWORK_ID = '00385'
    AND SERVICE_LOCATION_NBR = 712831
    AND PROVIDER_TYPE_CD = 'PH';

-- standard rate
SELECT MAX(RATE) AS RATE
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    RATE_SYSTEM_CD = ''
    AND SERVICE_CD = '99381'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND GEOGRAPHIC_AREA_CD = ''
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')


-- non standard rate (if specialty_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    SERVICE_CD = '99381'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR =
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
                WHERE
                    SERVICE_CD = '99381'
                    AND SERVICE_TYPE_CD = 'CPT4'
                    AND PLACE_OF_SERVICE_CD = '11'
                    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR =
                    AND SPECIALTY_CD = '10401'
            )
            THEN '10401'
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- default rate (if provider_type_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    SERVICE_CD = '99381'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR =


    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
                WHERE
                    SERVICE_CD = '99381'
                    AND SERVICE_TYPE_CD = 'CPT4'
                    AND PLACE_OF_SERVICE_CD = '11'
                    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR =
                    AND SPECIALTY_CD = 'PH'
            )
            THEN 'PH'
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;



-- Row 1074

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM `prv_ps_ce_dec_hcb_dev.CET_CLAIM_BASED_AMOUNTS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6543355
    AND NETWORK_ID = 248
    AND PLACE_OF_SERVICE_CD = '23'
    AND SERVICE_CD = '99283'
    AND SERVICE_TYPE_CD = 'CPT4';

-- cet_provider table (if specialty_cd)
SELECT DISTINCT
    PROVIDER_BUSINESS_GROUP_NBR,
    PROVIDER_BUSINESS_GROUP_SCORE_NBR,
    PROVIDER_IDENTIFICATION_NBR,
    PRODUCT_CD,
    SERVICE_LOCATION_NBR,
    NETWORK_ID,
    RATING_SYSTEM_CD,
    EPDB_GEOGRAPHIC_AREA_CD
FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6543355
    AND NETWORK_ID = '00248'
    AND SERVICE_LOCATION_NBR = 730117
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
                WHERE
                    PROVIDER_IDENTIFICATION_NBR = 6543355
                    AND NETWORK_ID = '00248'
                    AND SERVICE_LOCATION_NBR = 730117
                    AND SPECIALTY_CD = ''
            )
            THEN ''
            ELSE ''
        END
    );

-- cet_provider table (elif provider_type_cd)
SELECT DISTINCT
    PROVIDER_BUSINESS_GROUP_NBR,
    PROVIDER_BUSINESS_GROUP_SCORE_NBR,
    PROVIDER_IDENTIFICATION_NBR,
    PRODUCT_CD,
    SERVICE_LOCATION_NBR,
    NETWORK_ID,
    RATING_SYSTEM_CD,
    EPDB_GEOGRAPHIC_AREA_CD
FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 6543355
    AND NETWORK_ID = '00248'
    AND SERVICE_LOCATION_NBR = 730117
    AND PROVIDER_TYPE_CD = 'HO';

-- standard rate
SELECT MAX(RATE) AS RATE
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    RATE_SYSTEM_CD = ''
    AND SERVICE_CD = '99283'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND GEOGRAPHIC_AREA_CD = ''
    AND PLACE_OF_SERVICE_CD = '23'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')


-- non standard rate (if specialty_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    SERVICE_CD = '99283'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '23'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR =
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
                WHERE
                    SERVICE_CD = '99283'
                    AND SERVICE_TYPE_CD = 'CPT4'
                    AND PLACE_OF_SERVICE_CD = '23'
                    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR =
                    AND SPECIALTY_CD = ''
            )
            THEN ''
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- default rate (if provider_type_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    SERVICE_CD = '99283'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '23'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR =


    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
                WHERE
                    SERVICE_CD = '99283'
                    AND SERVICE_TYPE_CD = 'CPT4'
                    AND PLACE_OF_SERVICE_CD = '23'
                    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR =
                    AND SPECIALTY_CD = 'HO'
            )
            THEN 'HO'
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;



-- Row 1128

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM `prv_ps_ce_dec_hcb_dev.CET_CLAIM_BASED_AMOUNTS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4252081
    AND NETWORK_ID = 98
    AND PLACE_OF_SERVICE_CD = '11'
    AND SERVICE_CD = '92551'
    AND SERVICE_TYPE_CD = 'CPT4';

-- cet_provider table (if specialty_cd)
SELECT DISTINCT
    PROVIDER_BUSINESS_GROUP_NBR,
    PROVIDER_BUSINESS_GROUP_SCORE_NBR,
    PROVIDER_IDENTIFICATION_NBR,
    PRODUCT_CD,
    SERVICE_LOCATION_NBR,
    NETWORK_ID,
    RATING_SYSTEM_CD,
    EPDB_GEOGRAPHIC_AREA_CD
FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4252081
    AND NETWORK_ID = '00098'
    AND SERVICE_LOCATION_NBR = 2790243
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
                WHERE
                    PROVIDER_IDENTIFICATION_NBR = 4252081
                    AND NETWORK_ID = '00098'
                    AND SERVICE_LOCATION_NBR = 2790243
                    AND SPECIALTY_CD = '10401'
            )
            THEN '10401'
            ELSE ''
        END
    );

-- cet_provider table (elif provider_type_cd)
SELECT DISTINCT
    PROVIDER_BUSINESS_GROUP_NBR,
    PROVIDER_BUSINESS_GROUP_SCORE_NBR,
    PROVIDER_IDENTIFICATION_NBR,
    PRODUCT_CD,
    SERVICE_LOCATION_NBR,
    NETWORK_ID,
    RATING_SYSTEM_CD,
    EPDB_GEOGRAPHIC_AREA_CD
FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4252081
    AND NETWORK_ID = '00098'
    AND SERVICE_LOCATION_NBR = 2790243
    AND PROVIDER_TYPE_CD = 'PH';

-- standard rate
SELECT MAX(RATE) AS RATE
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    RATE_SYSTEM_CD = ''
    AND SERVICE_CD = '92551'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND GEOGRAPHIC_AREA_CD = ''
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')


-- non standard rate (if specialty_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    SERVICE_CD = '92551'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR =
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
                WHERE
                    SERVICE_CD = '92551'
                    AND SERVICE_TYPE_CD = 'CPT4'
                    AND PLACE_OF_SERVICE_CD = '11'
                    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR =
                    AND SPECIALTY_CD = '10401'
            )
            THEN '10401'
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- default rate (if provider_type_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    SERVICE_CD = '92551'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR =


    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
                WHERE
                    SERVICE_CD = '92551'
                    AND SERVICE_TYPE_CD = 'CPT4'
                    AND PLACE_OF_SERVICE_CD = '11'
                    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR =
                    AND SPECIALTY_CD = 'PH'
            )
            THEN 'PH'
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;



-- Row 1176

-- Claim Based
SELECT MAX(RATE) AS RATE
FROM `prv_ps_ce_dec_hcb_dev.CET_CLAIM_BASED_AMOUNTS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4187775
    AND NETWORK_ID = 2152
    AND PLACE_OF_SERVICE_CD = '11'
    AND SERVICE_CD = '99396'
    AND SERVICE_TYPE_CD = 'CPT4';

-- cet_provider table (if specialty_cd)
SELECT DISTINCT
    PROVIDER_BUSINESS_GROUP_NBR,
    PROVIDER_BUSINESS_GROUP_SCORE_NBR,
    PROVIDER_IDENTIFICATION_NBR,
    PRODUCT_CD,
    SERVICE_LOCATION_NBR,
    NETWORK_ID,
    RATING_SYSTEM_CD,
    EPDB_GEOGRAPHIC_AREA_CD
FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4187775
    AND NETWORK_ID = '02152'
    AND SERVICE_LOCATION_NBR = 7830924
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
                WHERE
                    PROVIDER_IDENTIFICATION_NBR = 4187775
                    AND NETWORK_ID = '02152'
                    AND SERVICE_LOCATION_NBR = 7830924
                    AND SPECIALTY_CD = '10201'
            )
            THEN '10201'
            ELSE ''
        END
    );

-- cet_provider table (elif provider_type_cd)
SELECT DISTINCT
    PROVIDER_BUSINESS_GROUP_NBR,
    PROVIDER_BUSINESS_GROUP_SCORE_NBR,
    PROVIDER_IDENTIFICATION_NBR,
    PRODUCT_CD,
    SERVICE_LOCATION_NBR,
    NETWORK_ID,
    RATING_SYSTEM_CD,
    EPDB_GEOGRAPHIC_AREA_CD
FROM `prv_ps_ce_dec_hcb_dev.CET_PROVIDERS`
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4187775
    AND NETWORK_ID = '02152'
    AND SERVICE_LOCATION_NBR = 7830924
    AND PROVIDER_TYPE_CD = 'PH';

-- standard rate
SELECT MAX(RATE) AS RATE
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    RATE_SYSTEM_CD = ''
    AND SERVICE_CD = '99396'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND GEOGRAPHIC_AREA_CD = ''
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')


-- non standard rate (if specialty_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    SERVICE_CD = '99396'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR =
    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
                WHERE
                    SERVICE_CD = '99396'
                    AND SERVICE_TYPE_CD = 'CPT4'
                    AND PLACE_OF_SERVICE_CD = '11'
                    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR =
                    AND SPECIALTY_CD = '10201'
            )
            THEN '10201'
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;

-- default rate (if provider_type_cd)
SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    MAX(rate) AS rate
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    SERVICE_CD = '99396'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR =


    AND SPECIALTY_CD = (
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
                WHERE
                    SERVICE_CD = '99396'
                    AND SERVICE_TYPE_CD = 'CPT4'
                    AND PLACE_OF_SERVICE_CD = '11'
                    AND (PRODUCT_CD = '' OR PRODUCT_CD = 'ALL')
                    AND PROVIDER_BUSINESS_GROUP_NBR =
                    AND SPECIALTY_CD = 'PH'
            )
            THEN 'PH'
            ELSE ''
        END
    )
GROUP BY
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr;