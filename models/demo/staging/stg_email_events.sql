with email_events as (

    select
    event_id,
    event_type, -- SEND, OPEN, CLICK, STATUSCHANGE (UNSUBSCRIBE_CAMPAIGN, UNSUBSCRIBE_ALL, SOURCE_KNOWN_SPAM_TRAP), SPAMREPORT
    event_time,
    contact_id,
    email_campaign_id,
    email_campaign_name,
    1.0 "TOTAL" --numeric value assigned to each row to preserve decimals for percentage calculations in final table
    
    
    from {{ source('dbt_achandrasekaran','email_events') }}
    left join {{ source('dbt_achandrasekaran','email_campaigns') }} using (email_campaign_id)

    where event_deleted = FALSE --exclude deleted events 
)

select * from email_events

