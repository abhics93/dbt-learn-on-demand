with segments as (
    select 
    email_campaign_name,
    customer_region,
    customer_industry,

    open_events_industry/send_events_industry as open_rate_industry,    -- avg open_rate for industry among all active campaigns
    open_events_region/send_events_region as open_rate_region,          -- avg open_rate for region among all active campaigns
    open_events_campaign/send_events_campaign as open_rate_campaign,    -- avg open_rate for a campaign

    click_events_industry/open_events_industry as click_rate_industry,  --avg click_rate for industry among all active campaigns
    click_events_region/open_events_region as click_rate_region,        --avg click_rate for region among all active campaigns
    click_events_campaign/open_events_campaign as click_rate_campaign   --avg click_rate for a campaign

--    round(sum(unsubscribe)/sum(send),4) as unsubscribe_rate,
--    round(sum(spam_report)/sum(send),4) as complaint_rate
    
    
from {{ ref('customer_email_events') }} 
),

aggregates as (
    select 
    email_campaign_name,
    customer_region,
    customer_industry,

    coalesce(sum(send_events),0) as sent,           -- total emails sent, grouped by campaign, region and industry
    coalesce(sum(open_events),0) as opened,         -- total emails opened, grouped by campaign, region and industry
    coalesce(sum(click_events),0) as clicked,       -- total emails clicked, grouped by campaign, region and industry
    
    round(sum(open_events)/sum(send_events),4) as open_rate,    -- open_rate, grouped by campaign, region and industry
    round(sum(click_events)/sum(open_events),4) as click_rate   -- click_rate, grouped by campaign, region and industry

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
    segments.open_rate_industry,
    segments.open_rate_campaign,
    aggregates.click_rate,
    segments.click_rate_industry,
    segments.click_rate_campaign

from segments
left join aggregates using(email_campaign_name, customer_region, customer_industry)