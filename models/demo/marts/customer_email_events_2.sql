{% set event_types = ["SEND", "OPEN", "CLICK"] -%}

with active_customers as (
    
    select * from {{ ref('active_customers') }}

),

email_events as (
    
    select 
        email_campaign_name,
        event_type,
        contact_id as customer_id,
        TOTAL,

        sum(TOTAL) as total_events_customer

    from {{ ref('stg_email_events') }}

    group by 1,2,3,4
),
    
customer_email_events as (

    select 
        email_campaign_name,
        customer_region,
        customer_industry,
        event_type,
        total_events_customer,
        sum(total_events_customer) as total_events,
        sum(total_events_customer) over (partition by email_campaign_name, customer_region, event_type) as total_events_region,
        sum(total_events_customer) over (partition by email_campaign_name, customer_industry, event_type) as total_events_industry,
        sum(total_events_customer) over (partition by email_campaign_name, event_type) as total_events_campaign

    from active_customers
    left join email_events using (customer_id)

    group by 1,2,3,4,5
)

select 
    email_campaign_name,
    customer_region,
    customer_industry,

    case when event_type = 'SEND' then 

from customer_email_events