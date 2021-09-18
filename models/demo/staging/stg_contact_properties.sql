with contact_properties as ( -- a subset of the properties of a contact

    select
        contact_id,
        contact_email,
        contact_is_customer,
        customer_signup_date,
        ifnull(region, 'Other') as region, --resolve any missing data in form fillouts
        ifnull(industry, 'Other') as industry
    
    from {{ source('dbt_achandrasekaran','contact_properties') }}
)

select * from contact_properties

