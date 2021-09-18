with segments as (
    select 
    email_campaign_name,
    customer_region,
    customer_industry,

    open_events_industry/send_events_industry as open_rate_industry,
    open_events_region/send_events_region as open_rate_region,
    
    click_events_region/open_events_region as click_rate_region,
    click_events_industry/open_events_industry as click_rate_industry

--    round(sum(unsubscribe)/sum(send),4) as unsubscribe_rate,
--    round(sum(spam_report)/sum(send),4) as complaint_rate
    
    
from {{ ref('customer_email_events') }} 
),

aggregates as (
    select 
    email_campaign_name,
    customer_region,
    customer_industry,

    coalesce(sum(send_events),0) as sent,
    coalesce(sum(open_events),0) as opened,
    coalesce(sum(click_events),0) as clicked,
    
    round(sum(open_events)/sum(send_events),4) as open_rate, 
    round(sum(click_events)/sum(open_events),4) as click_rate

    from {{ ref('customer_email_events') }} 

group by 1,2,3
)

select distinct
    segments.email_campaign_name,
    segments.customer_region,
    segments.customer_industry,
    
    aggregates.sent,
    aggregates.opened,
    aggregates.clicked,
    aggregates.open_rate,
    aggregates.click_rate
from segments
left join aggregates using(email_campaign_name, customer_region, customer_industry)