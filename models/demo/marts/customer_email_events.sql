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

        -- calculates total events per type per customer
        sum(TOTAL) over(partition by email_campaign_name, event_type, contact_id) as total_events_customer
        -- calculates total events per type per campaign
        -- sum(TOTAL) over(partition by email_campaign_name, event_type) as total_events_campaign

    from {{ ref('stg_email_events') }}

    group by 1,2,3,4
),
    
customer_email_events as (

    select 
        email_campaign_name,
        customer_region,
        customer_industry,
        event_type,
        -- total_events_campaign,

        {% for event_type in event_types -%}

            ifnull(sum(case when event_type = '{{event_type}}' then coalesce(total_events_customer,0) end),0) as "{{event_type}}_EVENTS_CUSTOMER",

       {% endfor %}

       {% for event_type in event_types -%}

            sum("{{event_type}}_EVENTS_CUSTOMER") over(partition by email_campaign_name, customer_region, customer_industry) as "{{event_type}}_EVENTS",
 
       {% endfor %}

       {% for event_type in event_types -%}

            sum("{{event_type}}_EVENTS_CUSTOMER") over(partition by email_campaign_name) as "{{event_type}}_EVENTS_CAMPAIGN",
 
       {% endfor %}

       {% for event_type in event_types -%}

            sum("{{event_type}}_EVENTS_CUSTOMER") over(partition by customer_region) as "{{event_type}}_EVENTS_REGION",
 
       {% endfor %}

       {% for event_type in event_types -%}

            sum("{{event_type}}_EVENTS_CUSTOMER") over(partition by customer_industry) as "{{event_type}}_EVENTS_INDUSTRY"

        {%- if not loop.last -%}
         ,
       {%- endif %}
 
       {% endfor -%}

    from active_customers
    left join email_events using (customer_id)

    group by 1,2,3,4
)

select 
    email_campaign_name,
    customer_region,
    customer_industry,
    
    {% for event_type in event_types -%}
    
    {{event_type}}_EVENTS,
    
    {%- endfor %}

    {% for event_type in event_types -%}
    
    {{event_type}}_EVENTS_CAMPAIGN,
    
    {%- endfor %}

    {% for event_type in event_types -%}
    
    {{event_type}}_EVENTS_REGION,
    
    {%- endfor %}

    {% for event_type in event_types -%}
    
    {{event_type}}_EVENTS_INDUSTRY

    {%- if not loop.last -%}
         ,
       {% endif -%}
    {%- endfor %}


from customer_email_events

order by email_campaign_name