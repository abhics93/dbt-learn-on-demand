-- campaign (industry segment) having greater than average click rates
select 

  email_campaign_name,
  customer_industry,
  click_rate_industry,
  sum(clicked)/sum(opened) as campaign_click_rate

from email_campaign_metrics
group by 1,2,3
having(campaign_click_rate > click_rate_industry);

-- click through rates among industries for a given campaign
 select 

  email_campaign_name,
  customer_industry,
  sum(clicked)/sum(sent) as campaign_click_through_rate

from email_campaign_metrics
where email_campaign_name = 'Welcome Series'
group by 1,2;

-- open rates in all regions, for an industry
select 

  customer_region,
sum(opened)/sum(sent) as open_rate

from email_campaign_metrics
where customer_industry = 'Consumer Goods'
group by 1 ;