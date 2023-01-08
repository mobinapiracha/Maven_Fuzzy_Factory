# Fuzzy Factory

## Overview 
Fuzzy Factory is a newly launched ecommerce startup looking to break into the market with its new product Mr. Fuzzy. The company has a SQL database with a number of tables from website sessions, website pageviews, orders and a number of other tables (order items refund, order items, products). As a database analyst, they've hired you to utilize the SQL tables provided in order to analyze business performance and provide recommendations regarding avenues for business growth. 


## Performance Metrics and Growth 
As a new platform,Fuzzy Factory has been live for 8 months now, and the CEO Cindy Sharp has an upcoming presentation for the board regarding indicators related to performance and growth of the business up to November 27, 2012 to maintain the board's confidence in the business. As a result she has asked you to answer some questions that the board may be interested in. Cindy is interested in: 

Cindy noticed that gsearch seems to be the biggest driver of growth for the business and would like to you to: 
* Provide monthly trends for gsearch website sessions to showcase business growth
* Split monthly trends for gsearch website sessions by brand and nonbrand 
* Within nonbrand, provide monthly trends for gsearch nonbrand website sessions by device type

In order to understand how many of our website sessions converted to revenue, Cindy would like us to provide
* Monthly trends for session, orders and session to order conversion rate

We conducted two A/B tests, one by testing a new lander page titled "lander-1" within gsearch nonbrand, and the other by testing a new billing page called "billing-2" in order to better understand how this new page impacted business performance Cindy would like:
* Estimate the revenue the test earned us between test dates i.e. 19th June to 28th July
* Create a full conversion funnel for both the standard landing page and lander 1 to see the conversion rates for both pages
* Quantify the impact of the billing test by analyzing the lift generated from the test (September 10 to November 10th) in terms of revenue per billing page session
* Pull the number of billing page sessions in the past month to understand the monthly impact of the test

The metrics Cindy is requesting would play an important role in helping the board understand the growth, performance and overall health of the new business and ensure investor confidence moving forward. 

## Results 

The following are the results providing the growth, performance and health for the first 8 months of its inception (for detailed queries please refer to PerformanceMetrics_and_Growth_11_27_2012.sql)

### Gsearch Performance Metrics 
#### Monthly gsearch website sessions
![This is a alt text.](/images/Monthly_trends_gsearch.png)
