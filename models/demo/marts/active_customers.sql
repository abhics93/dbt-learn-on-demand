with active_customers as (

    select
    contact_id as customer_id,
    contact_email as customer_email,
    customer_signup_date,
    region as customer_region,
    industry as customer_industry
    
    from {{ ref('stg_contact_properties')}} 
    
    where contact_is_customer = TRUE -- select current customers only
)

select * from active_customers

