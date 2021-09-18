with email_campaigns as (

    select

    email_campaign_id,
    email_campaign_name,
    email_campaign_created_date
    
    from {{ source('dbt_achandrasekaran','email_campaigns') }}

--  where active = TRUE
)

select * from email_campaigns