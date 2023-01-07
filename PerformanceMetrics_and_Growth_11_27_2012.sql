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
	COUNT(DISTINCT website_sessions.website_session_id) AS total_sessions,
    MONTH(website_sessions.created_at) AS Month_of_the_year,
    MIN(DATE(website_sessions.created_at)) AS Month_start,
    COUNT(DISTINCT orders.order_id) AS orders
FROM website_sessions
LEFT JOIN orders
ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
AND website_sessions.utm_source = 'gsearch'
GROUP BY 2;

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


