-- Mid Course Project 
/* Maven Fuzzy Factory has been live for 8 months and your CEO is due to present to the company performance metrics to the board, please 
website traffic and performance data to quantify the company's growth up to November 27, 2012 and tell a story of how the company has been able to generate this growth */


-- Gsearch seems to be the biggest driver for the business, pull monthly trends for gsearch sessions and orders to showcase the growth
-- Created at before 2012-11-27
-- Join with orders table
SELECT * 
FROM website_sessions
WHERE created_at < '2012-11-27';

SELECT *
FROM orders;

SELECT 
    MONTH(website_sessions.created_at) AS Month_of_the_year,
    MIN(DATE(website_sessions.created_at)) AS Month_start,
    COUNT(DISTINCT orders.order_id) AS orders,
	COUNT(DISTINCT website_sessions.website_session_id) AS total_sessions
FROM website_sessions
LEFT JOIN orders
ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
AND website_sessions.utm_source = 'gsearch'
GROUP BY 1;

-- Monthly trend but splitting it between brand and nonbrand
SELECT 
	COUNT(DISTINCT website_sessions.website_session_id) AS total_sessions,
    MONTH(website_sessions.created_at) AS Month_of_the_year,
    MIN(DATE(website_sessions.created_at)) AS Month_start,
    COUNT(DISTINCT orders.order_id) AS orders,
	COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END) AS total_nonbrand_sessions,
    COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN website_sessions.website_session_id ELSE NULL END) AS total_brand_sessions,
	COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) AS non_brand_orders,
    COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN orders.order_id ELSE NULL END) AS brand_orders
FROM website_sessions
LEFT JOIN orders
ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
AND website_sessions.utm_source = 'gsearch'
GROUP BY 2;

-- Non brand orders by device type
SELECT 
    MONTH(website_sessions.created_at) AS Month_of_the_year,
    MIN(DATE(website_sessions.created_at)) AS Month_start,
 	COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_sessions.website_session_id ELSE NULL END) AS mobile_sessions,
 	COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN website_sessions.website_session_id ELSE NULL END) AS desktop_sessions,
    COUNT(DISTINCT website_sessions.website_session_id) AS total_nonbrand_sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN orders.order_id ELSE NULL END) AS mobile_orders,
 	COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN orders.order_id ELSE NULL END) AS desktop_orders,
    COUNT(DISTINCT orders.order_id) AS total_orders
FROM website_sessions
LEFT JOIN orders
ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
AND website_sessions.utm_source = 'gsearch'
AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY 1;

-- Large percentage of traffic from gsearch
SELECT 
	COUNT(DISTINCT website_sessions.website_session_id) AS total_sessions,
    MONTH(website_sessions.created_at) AS Month_of_the_year,
    MIN(DATE(website_sessions.created_at)) AS Month_start,
    website_sessions.utm_source
FROM website_sessions
WHERE website_sessions.created_at < '2012-11-27'
GROUP BY 2,4
ORDER BY 4 DESC;

-- Session to Order Conversion Rate by Month
SELECT
	MONTH(website_sessions.created_at) AS Month_of_the_year,
    MIN(DATE(website_sessions.created_at)) AS Month_start,
	COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) * 100 AS session_to_order_conv_rate
FROM website_sessions
LEFT JOIN orders
ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
GROUP BY 1;

-- Gsearch lander test, please estimate revenue the test earned us
SELECT 
	MIN(created_at) AS first_created_at,
    MIN(website_pageview_id) AS first_pageview
FROM website_pageviews
WHERE pageview_url = '/lander-1'
	AND created_at IS NOT NULL;
 
 -- 23504 first pageview
    
CREATE TEMPORARY TABLE lander_analysis_entry_pageview
SELECT
		website_pageviews.website_session_id,
        MIN(website_pageviews.website_pageview_id) AS min_pageview_id
FROM website_pageviews
INNER JOIN website_sessions
	ON website_sessions.website_session_id = website_pageviews.website_session_id
AND website_sessions.created_at < '2012-07-28'
AND website_pageviews.website_pageview_id > 23504
AND utm_source = 'gsearch'
AND utm_campaign = 'nonbrand'
GROUP BY 
	website_pageviews.website_session_id;
    
SELECT * FROM lander_analysis_entry_pageview;

-- Next bring in landing page to each session
CREATE TEMPORARY TABLE lander_analysis_step_1
SELECT	
	lander_analysis_entry_pageview.website_session_id,
	website_pageviews.pageview_url AS landing_page
FROM lander_analysis_entry_pageview
LEFT JOIN website_pageviews
ON website_pageviews.website_pageview_id = lander_analysis_entry_pageview.min_pageview_id
WHERE website_pageviews.pageview_url IN ('/home','/lander-1');

SELECT * FROM lander_analysis_step_1;

-- next, join from nonbrandtestsession with landing pages with ordrs
CREATE TEMPORARY TABLE nonbrand_test_session_w_orders
SELECT 
	lander_analysis_step_1.website_session_id,
    lander_analysis_step_1.landing_page,
    orders.order_id AS order_id
FROM lander_analysis_step_1
LEFT JOIN orders
ON lander_analysis_step_1.website_session_id = orders.website_session_id;

SELECT * FROM nonbrand_test_session_w_orders;

-- to find difference between conversion rates
SELECT 
	landing_page, 
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT order_id)/COUNT(DISTINCT website_session_id) AS conv_rate
FROM nonbrand_test_session_w_orders
GROUP BY 1;

-- Finding the most recent pageview for gsearch nonbrand where the traffic was sent to /home
SELECT 
	MAX(website_sessions.website_session_id) AS most_recent_gsearch_nonbrand_pageview
FROM website_sessions
LEFT JOIN website_pageviews
ON website_pageviews.website_session_id = website_sessions.website_session_id
WHERE utm_source = "gsearch"
AND utm_campaign = "nonbrand"
AND pageview_url = '/home'
AND website_sessions.created_at < '2012-11-27';

-- max website_session_id is 17145

SELECT 
	COUNT(website_session_id) AS sessions_since_test
FROM website_sessions
WHERE created_at <'2012-11-27'
AND website_session_id > 17145
AND utm_source = 'gsearch'
AND utm_campaign = 'nonbrand';

-- There were 22972 sessions since the test 
-- As a result you multiply 22972 by the incremental conversion rate
-- i.e. 0.0406-0.0318 = 0.0088 * 22972 around 202
-- this happened for another 4 months since we test ended at end of July
-- So an extra 202 orders over a 4 month period as a result of this change

-- From previous landing page show full conversion funnel for each of two pages to orders
SELECT * FROM website_pageviews;

SELECT 
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    website_pageviews.created_at AS pageview_created_at,
    CASE WHEN pageview_url = '/lander-1' THEN 1 ELSE 0 END AS lander_page,    
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
    CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mr_fuzzy_page,
	CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
	CASE WHEN pageview_url = 'shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM website_sessions
LEFT JOIN website_pageviews
ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at BETWEEN '2012-06-19' AND '2012-07-28'
AND website_sessions.utm_source = 'gsearch'
AND website_sessions.utm_campaign = 'nonbrand'
AND website_pageviews.pageview_url IN ('/lander-1','/products','/the-original-mr-fuzzy','/cart','/shipping','/billing','/thank-you-for-your-order')
ORDER BY 
	website_sessions.website_session_id,
    website_pageviews.created_at;

-- Put previous query inside subquery
CREATE TEMPORARY TABLE home_vs_lander
SELECT 
	website_session_id,
    MAX(home_page) AS home_made_it,
    MAX(lander_page) AS lander_1_made_it,
    MAX(products_page) AS product_made_it,
    MAX(mr_fuzzy_page) AS mrfuzzy_made_it,
    MAX(cart_page) AS cart_made_it,
    MAX(shipping_page) AS shipping_made_it,
    MAX(billing_page) AS billing_made_it,
    MAX(thankyou_page) AS thankyou_made_it
FROM (
SELECT 
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    website_pageviews.created_at AS pageview_created_at,
    CASE WHEN pageview_url = '/home' THEN 1 ELSE 0 END AS home_page,
	CASE WHEN pageview_url = '/lander-1' THEN 1 ELSE 0 END AS lander_page,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
    CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mr_fuzzy_page,
	CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
	CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM website_sessions
LEFT JOIN website_pageviews
ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at BETWEEN '2012-06-19' AND '2012-07-28'
AND website_sessions.utm_source = 'gsearch'
AND website_sessions.utm_campaign = 'nonbrand'
ORDER BY 
	website_sessions.website_session_id,
    website_pageviews.created_at) AS pageview_level

GROUP BY website_session_id;


SELECT * FROM home_vs_lander;

-- Final output lander1
SELECT
CASE 
	WHEN home_made_it = 1 THEN 'saw_homepage'
    WHEN lander_1_made_it = 1 THEN 'saw_lander'
END AS segment,
	COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) AS to_products,
    COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS to_cart,
    COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS to_shipping,
    COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS to_billing,
    COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END) AS to_thankyou
FROM home_vs_lander
GROUP BY 1;

-- Conversion Rates 
SELECT
CASE 
	WHEN home_made_it = 1 THEN 'saw_homepage'
    WHEN lander_1_made_it = 1 THEN 'saw_lander'
END AS segment,
	COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS product_clickthrough,
    COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) AS to_mrfuzzy_clickthrough,
    COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END)/ COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS cart_clickthrough,
    COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS shipping_clickthrough,
    COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS billing_clickthrough,
    COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) to_thankyou_clickthrough
FROM home_vs_lander
GROUP BY 1;

-- Quantify the impact of our billing test. The lift generated from the test (Sept 10 to Nov 10), in terms of revenue per billing session
-- then pull number of billing page sessions for the past month to understand the impact
-- Essentially the incremental changes as the result of the billing test and then billing sessions afterwards to understand monthly billing impact
-- Orders, Billing, Past month billing page sessioms to understand monthly impact
-- First we join orders and billing
-- First instance of billing 
SELECT 
	MIN(website_pageviews.website_pageview_id) AS first_pageview_billing2,
    MIN(website_pageviews.created_at) AS first_date_billing2
FROM website_pageviews
WHERE website_pageviews.pageview_url = '/billing-2';

SELECT 
	billing_version_seen,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT order_id) AS orders,
    SUM(price_usd) AS total_revenue,
    SUM(price_usd)/COUNT(DISTINCT website_session_id) AS revenue_per_billing_session
FROM (
SELECT 
	website_pageviews.website_session_id,
    website_pageviews.pageview_url AS billing_version_seen,
	orders.order_id,
    orders.price_usd
FROM website_pageviews
LEFT JOIN orders
ON website_pageviews.website_session_id = orders.website_session_id
WHERE website_pageviews.website_pageview_id >= 53550
AND website_pageviews.created_at BETWEEN '2012-09-10' AND '2012-11-10'
AND website_pageviews.pageview_url IN ('/billing','/billing-2')
) AS orders_and_billing
GROUP BY 1;

-- Monthly Billing Sessions
SELECT 
	MIN(website_pageviews.website_pageview_id),
    MIN(website_pageviews.created_at)
FROM website_pageviews
WHERE website_pageviews.pageview_url = '/billing-2';

-- Revenue per Billing Session
SELECT 
	billing_version_seen,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT order_id) AS orders,
    SUM(price_usd) AS total_revenue,
    SUM(price_usd)/COUNT(DISTINCT website_session_id) AS revenue_per_billing_session
FROM (
SELECT 
	website_pageviews.website_session_id,
    website_pageviews.created_at AS created_date,
    website_pageviews.pageview_url AS billing_version_seen,
	orders.order_id,
    orders.price_usd
FROM website_pageviews
LEFT JOIN orders
ON website_pageviews.website_session_id = orders.website_session_id
WHERE website_pageviews.website_pageview_id >= 53550
AND website_pageviews.created_at BETWEEN '2012-09-10' AND '2012-11-10'
AND website_pageviews.pageview_url IN ('/billing','/billing-2')
) AS orders_and_billing
GROUP BY 1;

-- Lift is 8.50
-- Number of billing sessions this past month
SELECT 
	COUNT(website_session_id) AS billing_sessions_past_month
FROM website_pageviews
WHERE website_pageviews.pageview_url IN ('/billing','/billing-2')
	AND created_at BETWEEN '2012-10-27' AND '2012-11-27'; -- past month
    
    -- 1193 * 850

-- Revenue per billing session by month
SELECT 
	billing_version_seen,
    MONTH(created_date) AS monthly_billing_page_sessions,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT order_id) AS orders,
    SUM(price_usd) AS total_revenue,
    SUM(price_usd)/COUNT(DISTINCT website_session_id) AS revenue_per_billing_session
FROM (
SELECT 
	website_pageviews.website_session_id,
    website_pageviews.created_at AS created_date,
    website_pageviews.pageview_url AS billing_version_seen,
	orders.order_id,
    orders.price_usd
FROM website_pageviews
LEFT JOIN orders
ON website_pageviews.website_session_id = orders.website_session_id
WHERE website_pageviews.website_pageview_id >= 53550
AND website_pageviews.created_at BETWEEN '2012-09-10' AND '2012-11-10'
AND website_pageviews.pageview_url IN ('/billing','/billing-2')
) AS orders_and_billing
GROUP BY 1,2;

