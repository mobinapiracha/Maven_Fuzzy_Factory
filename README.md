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
#### Monthly Gsearch Website Sessions
![This is a alt text.](/images/Monthly_trends_gsearch.png)
* The analysis above illustrates gsearch performance this year, we see a steady increase in sessions and orders increasing from 3574 sessions and 92 orders in the month of April to 5534 sessions and 234 orders in the month of October, we see a large increase of 373 orders and 8889 sessions in the month of November, which we suspect is the result of Black Friday, Cyber Monday and the beginning of Holiday shopping season. The analysis illustrates steady healthy growth in both website traffic and revenue from orders 

#### Monthly Sessions and Orders for Gsearch Brand and Nonbrand 
![This is a alt text.](/images/Brand_nonbrand_monthlysessions.png)
* The results from Nonbrand vs Brand Monthly trends shows a steady increase in both brand and nonbrand orders, this is a positive indication as a steady increase in brand orders and sessions indicates growing reputation of Fuzzy Factory, while the nonbrand sessions rise indicates that the company revenue and traffic is steadily increasing

### Nonbrand Orders by Device Type 
![This is a alt text.](/images/Monthly_trends_by_device.png)
* Monthly trends by device type show steady rise in nonbrand desktop orders, however, we see a mixed bag for mobile orders, in some cases only being in single digits, however exibiting strong Black Friday and Cyber Monday performance. We may ask the Marketing Director Tom Parmesan to bid down on nonbrand mobile and focus more on Desktop sessions. 
* It may also be feasible to check out and possibly modify the mobile website as a bad mobile user experience may be the reason for slow orders. 

### Overall Business Performance

#### Overall Session to Order Conversion Rate 
![This is a alt text.](/images/session_to_order_cov_rate.png)
* When analyzing the session to order conversion rate by month, we see a similar positive upward trend, an increase from 3.19% in April of 2012 to 4.53% in October of 2012. The board should be pleased to see this steady growth and healthy performance as it is indicative of both growing business reputation through organic search & type in but also steady conversions through paid advertising sources. 

### A/B Test Results 
# Lander-1 Analysis 
![This is a alt text.](/images/first_instance_of_lander1.png)
* * In order to estimate the revenue from our test, we first need to find the first instance of lander-1, From the query above we see that lander-1 is pageview 23504 on June 19th

![This is a alt text.](/images/website_session_and_pageviewids_lander1.png)
* Now we find all the sessions and pageviews after 23504 for gsearch nonbrand as that will be the starting point of our analysis

![This is a alt text.](/images/website_session_and_pageviewids_lander1.png)
![This is a alt text.](/images/nonbrand_sessionsandorders.png)
* By joining website sessions and pageviews table by session id filtering for only home and lander-1 we now get only sessions for both home and lander-1
* Now we simply add the orders table to see which of these sessions converted to orders

![This is a alt text.](/images/conversion_rate_diff_home_vs_lander.png)
![This is a alt text.](/images/most_recent_gsearch_nonbrand_pageview.png)
* Now that we have both our sessions and orders we do a simple aggregation to get our total sessions, orders and conversion rate for both our landing pages and we find a difference of 0.0088 in conversion rates 
* We find the most recent pageview where the traffic was sent to home and we simply leverage the 17145 website session to create another query to calculate the total number of sessions since the test was created, we find that we had 22972 sessions since we started the test
* As a result our increase in revenue from the test is the difference in conversion rates i.e. 0.0088 by 22972 
