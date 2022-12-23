-- Traffic Source Analysis 
use mavenfuzzyfactory;
-- Website Sessions
SELECT * FROM website_sessions
WHERE website_session_id = 1059;

-- Website Pageviews
SELECT * FROM website_pageviews
WHERE website_session_id = 1059;

-- Orders 
SELECT * FROM orders WHERE website_session_id = 1059;

-- Grouping sessions by utm_content 
SELECT * FROM website_sessions WHERE website_session_id BETWEEN 1000 and 2000;
SELECT 
		utm_content,
        COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE website_session_id BETWEEN 1000 and 2000 
GROUP BY 
utm_content
ORDER BY COUNT(DISTINCT website_session_id) DESC;

-- Adding the orders to this analysis 
SELECT 
	website_sessions.utm_content,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) * 100 AS session_to_order_conv_rate
FROM website_sessions
LEFT JOIN orders 
	ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.website_session_id BETWEEN 1000 AND 2000
GROUP BY 1
ORDER BY 2 DESC;

-- Traffic Source Bid Optimization and Trend Analysis
-- Conversion Rates and Revenue Per Click
-- Mobile Traffic vs Desktop Traffic within channels, bid appropriately
-- Impact of bid changes on ranking in paid auctions, revenue from paid marketing channels to dial up or down bids
-- Pro tip couple date functions with group + COUNT and SUM
SELECT * FROM website_sessions WHERE website_session_id BETWEEN 100000 AND 115000;

SELECT 
	website_session_id,
    created_at,
    MONTH(created_at),
    WEEK(created_at),
    YEAR(created_at)
FROM website_sessions
WHERE website_session_id BETWEEN 100000 and 115000; -- arbitrary


-- Lets do trend analysis of sessions by week by year
SELECT 
	COUNT(DISTINCT website_session_id) as total_sessions,
    WEEK(created_at),
    YEAR(created_at)
FROM website_sessions
WHERE website_session_id BETWEEN 100000 and 115000
GROUP BY  3,2;

-- Clean this up a little bit 
SELECT 
    YEAR(created_at),
	WEEK(created_at),
    MIN(DATE(created_at)) AS week_start,
	COUNT(DISTINCT website_session_id) as total_sessions
FROM website_sessions
WHERE website_session_id BETWEEN 100000 and 115000
GROUP BY  1,2;

-- Case pivoting method
-- Pro tip
SELECT 
	order_id,
    primary_product_id,
    items_purchased,
    created_at
FROM orders
WHERE order_id BETWEEN 31000 AND 32000;

-- Number of Orders purchased for each product
SELECT 
	primary_product_id,
	COUNT(DISTINCT order_id) as Number_of_Orders
FROM orders
WHERE order_id BETWEEN 31000 AND 32000
GROUP BY primary_product_id;

-- Use count and case pivot method to get the number of items purchased for each order ID
SELECT 
	primary_product_id,
    order_id,
    items_purchased,
    CASE WHEN items_purchased = 1 THEN order_id ELSE NULL END AS orders_w_1_item,
    CASE WHEN items_purchased = 2 THEN order_id ELSE NULL END AS orders_w_2_item
FROM orders
WHERE order_id BETWEEN 31000 AND 32000;

-- Find order_id with 1 or 2 orders
SELECT 
	order_id,
    COUNT(DISTINCT CASE WHEN items_purchased = 1 THEN order_id ELSE NULL END) AS orders_w_1_item,
    COUNT(DISTINCT CASE WHEN items_purchased = 2 THEN order_id ELSE NULL END) AS orders_w_2_item
FROM orders
WHERE order_id BETWEEN 31000 AND 32000
GROUP BY 1;

-- Find cases of orders with 1 or 2 items 
SELECT 
	primary_product_id,
    order_id,
    items_purchased,
    COUNT(DISTINCT CASE WHEN items_purchased = 1 THEN order_id ELSE NULL END) AS orders_w_1_item,
    COUNT(DISTINCT CASE WHEN items_purchased = 2 THEN order_id ELSE NULL END) AS orders_w_2_item
FROM orders
WHERE order_id BETWEEN 31000 AND 32000
GROUP BY 1,2,3;

-- Comprehensive case statement with cases of 1 or 2 items purchased for each product ID along witht total orders
SELECT 
	primary_product_id,
    COUNT(DISTINCT CASE WHEN items_purchased = 1 THEN order_id ELSE NULL END) AS orders_w_1_item,
    COUNT(DISTINCT CASE WHEN items_purchased = 2 THEN order_id ELSE NULL END) AS orders_w_2_item,
    COUNT(DISTINCT order_id) AS total_orders
FROM orders
WHERE order_id BETWEEN 31000 AND 32000
GROUP BY 1;

-- Analyzing Top Website Content 
-- CREATE TEMPORARY TABLE
-- Finding Top Pages
SELECT 
	pageview_url,
    COUNT(DISTINCT website_pageviews.website_pageview_id) AS total_number_of_views
    FROM website_pageviews
    WHERE website_pageviews.website_pageview_id < 1000 
    GROUP BY 1
    ORDER BY 2 DESC;

-- 
SELECT * 
FROM website_pageviews
WHERE website_pageview_id < 1000; -- arbitrary

SELECT 
	website_session_id,
    MIN(website_pageview_id) AS min_pv_id
FROM website_pageviews
WHERE website_pageview_id < 1000 
GROUP BY website_session_id;
-- We have one line item for every session and first pageview ID stamped in the website pageviews table, only one part of the multi step query, we will first create temp table


-- 
CREATE TEMPORARY TABLE first_pageview
SELECT 
	website_session_id,
    MIN(website_pageview_id) AS min_pv_id
FROM website_pageviews
WHERE website_pageview_id < 1000 
GROUP BY website_session_id;

SELECT * 
FROM first_pageview;

SELECT 
    website_pageviews.pageview_url AS landing_page,
    COUNT(DISTINCT first_pageview.website_session_id) AS sessions_hitting_this_lander
FROM first_pageview
	LEFT JOIN website_pageviews
		ON first_pageview.min_pv_id = website_pageviews.website_pageview_id
	GROUP BY landing_page;
    
-- Most viewed website_pages ranked by session volume
SELECT 
	pageview_url,
    COUNT(DISTINCT website_pageview_id) AS sessions
FROM website_pageviews
WHERE created_at < '2012-06-09'
GROUP BY pageview_url
ORDER BY sessions DESC;

SELECT 
	website_pageviews.pageview_url AS page_view_url,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions
FROM website_sessions 
LEFT JOIN website_pageviews
	ON website_pageviews.website_session_id = website_sessions.website_session_id
    WHERE website_pageviews.created_at < '2012-06-09'
    GROUP BY page_view_url
    ORDER BY sessions DESC;

-- Entry pages
CREATE TEMPORARY TABLE entry_page
SELECT 
	website_session_id,
    MIN(website_pageview_id) AS min_pv_id
FROM website_pageviews
WHERE created_at < '2012-06-12'
GROUP BY website_session_id;

-- Entry Pages
SELECT * FROM entry_page;

SELECT 
    website_pageviews.pageview_url AS landing_page,
    COUNT(DISTINCT entry_page.website_session_id) AS sessions_hitting_this_landing_page
FROM entry_page
	LEFT JOIN website_pageviews
		ON entry_page.min_pv_id = website_pageviews.website_pageview_id
	GROUP BY landing_page
    ORDER BY sessions_hitting_this_landing_page;

-- First find first website pageview ID for relevant session
-- Identify landing page for each session
--  Counting pageviews for each session, to identify "bounce"
-- summarizing total sessions and bounced sessions, by Landing Page to find out which LP are doing the best


-- Minimum pageview id associated with each session we care about
SELECT 
	website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) as min_pageview_id
    FROM website_pageviews
    INNER JOIN website_sessions
		ON website_sessions.website_session_id = website_pageviews.website_session_id
        AND website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01'
	GROUP BY 
			website_pageviews.website_session_id;
	
-- Create a temporary table doing exact same thing
-- 
CREATE TEMPORARY TABLE first_pageviews_demo
SELECT 
	website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) as min_pageview_id
    FROM website_pageviews
    INNER JOIN website_sessions
		ON website_sessions.website_session_id = website_pageviews.website_session_id
        AND website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01'
	GROUP BY 
			website_pageviews.website_session_id;
            
SELECT * FROM first_pageviews_demo;

-- bring the landing page to each session
CREATE TEMPORARY TABLE sessions_v_landing_page_demo
SELECT 
	first_pageviews_demo.website_session_id,
    website_pageviews.pageview_url AS landing_page
FROM first_pageviews_demo
	LEFT JOIN website_pageviews
		ON website_pageviews.website_pageview_id = first_pageviews_demo.min_pageview_id;
-- Website pageview is the landing page view 

SELECT * FROM sessions_v_landing_page_demo;


-- Create temporary table for bounced sessions only
CREATE TEMPORARY TABLE bounced_sessions_only
SELECT 
	sessions_v_landing_page_demo.website_session_id,
    sessions_v_landing_page_demo.landing_page,
    COUNT(website_pageviews.website_pageview_id) AS count_of_pages_viewed

FROM sessions_v_landing_page_demo
LEFT JOIN website_pageviews
	ON website_pageviews.website_session_id = sessions_v_landing_page_demo.website_session_id
GROUP BY 
	sessions_v_landing_page_demo.website_session_id,
    sessions_v_landing_page_demo.landing_page
HAVING count_of_pages_viewed = 1;

SELECT * FROM bounced_sessions_only;

-- Join sessions with landing page to bounced sessions
SELECT 
	sessions_v_landing_page_demo.landing_page,
    COUNT(DISTINCT sessions_v_landing_page_demo.website_session_id) AS sessions,
    COUNT(DISTINCT bounced_sessions_only.website_session_id) AS bounced_sessions
FROM sessions_v_landing_page_demo
	LEFT JOIN bounced_sessions_only
		ON sessions_v_landing_page_demo.website_session_id = bounced_sessions_only.website_session_id
GROUP BY 1
ORDER BY 2;

-- Bounce rate
SELECT 
	sessions_v_landing_page_demo.landing_page,
    COUNT(DISTINCT sessions_v_landing_page_demo.website_session_id) AS sessions,
    COUNT(DISTINCT bounced_sessions_only.website_session_id) AS bounced_sessions,
    COUNT(DISTINCT bounced_sessions_only.website_session_id)/COUNT(DISTINCT sessions_v_landing_page_demo.website_session_id) * 100 AS bounce_rate
FROM sessions_v_landing_page_demo
	LEFT JOIN bounced_sessions_only
		ON sessions_v_landing_page_demo.website_session_id = bounced_sessions_only.website_session_id
GROUP BY 1
ORDER BY 4;


-- Entry Pages Bounce Rates
SELECT * FROM entry_page;

SELECT 
    website_pageviews.pageview_url AS landing_page,
    COUNT(DISTINCT entry_page.website_session_id) AS sessions_hitting_this_landing_page
FROM entry_page
	LEFT JOIN website_pageviews
		ON entry_page.min_pv_id = website_pageviews.website_pageview_id
	GROUP BY landing_page
    ORDER BY sessions_hitting_this_landing_page;

-- Calculate bounce rate for landing page
CREATE TEMPORARY TABLE first_page_views_1
SELECT 
	website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS pvs
FROM website_pageviews
INNER JOIN website_sessions
		ON website_sessions.website_session_id = website_pageviews.website_session_id
AND website_sessions.created_at < '2012-06-14'
GROUP BY 1;

SELECT * FROM first_page_views_1;

CREATE TEMPORARY TABLE session_w_first_landing_page
SELECT
	first_page_views_1.website_session_id,
    website_pageviews.pageview_url AS landing_page
FROM first_page_views_1
LEFT JOIN website_pageviews
	ON website_pageviews.website_pageview_id = first_page_views_1.pvs
    AND website_pageviews.pageview_url = '/home';

SELECT * FROM session_w_first_landing_page;

CREATE TEMPORARY TABLE home_page_bounced_sessions
SELECT
	session_w_first_landing_page.website_session_id,
    session_w_first_landing_page.landing_page AS landing_page,
    COUNT(website_pageviews.website_pageview_id) as count_of_views
FROM session_w_first_landing_page
LEFT JOIN website_pageviews
ON website_pageviews.website_session_id = session_w_first_landing_page.website_session_id
GROUP BY 
	1,
    2
HAVING count_of_views = 1;
	
SELECT * FROM home_page_bounced_sessions;

SELECT 
	session_w_first_landing_page.landing_page,
	COUNT(DISTINCT session_w_first_landing_page.website_session_id) as sessions,
    COUNT(DISTINCT home_page_bounced_sessions.website_session_id) as bounced_sessions,
    COUNT(DISTINCT home_page_bounced_sessions.website_session_id)/COUNT(DISTINCT session_w_first_landing_page.website_session_id) AS bounce_rate
FROM session_w_first_landing_page
LEFT JOIN home_page_bounced_sessions
	ON home_page_bounced_sessions.website_session_id = session_w_first_landing_page.website_session_id
GROUP BY 1
ORDER BY 4;
    

-- Find the initial created at, initial pageview for lander 1, 
-- Use that to isolate your results 
-- landing page, total sessions, bounced sessions, bounce rate

-- Pageview for lander
-- Find out when the new page/lander launched
-- first website pageview id for relevant sessions
-- identifying the landing page for each session
-- counting the pageview for each session to identify bounces
-- summarizing total sessions and bounce sessions, by LP

use mavenfuzzyfactory;

SELECT 
	MIN(created_at) AS first_created_at,
    MIN(website_pageview_id) AS first_pageview
FROM website_pageviews
WHERE pageview_url = '/lander-1'
	AND created_at IS NOT NULL;
    
-- first_created_at = '2012-06-19 00:35:54'
-- first_pageview_id = 23504
CREATE TEMPORARY TABLE first_test_pageviews
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
    
SELECT * FROM first_test_pageviews;    

-- next create temporary table 
CREATE TEMPORARY TABLE nonbrand_test_sessions_w_landing_page
SELECT 
	first_test_pageviews.website_session_id,
    first_test_pageviews.min_pageview_id,
    website_pageviews.pageview_url AS landing_page
FROM first_test_pageviews
LEFT JOIN website_pageviews
		ON website_pageviews.website_pageview_id = first_test_pageviews.min_pageview_id
WHERE website_pageviews.pageview_url IN ('/home','/lander-1');

SELECT * FROM nonbrand_test_sessions_w_landing_page;

CREATE TEMPORARY TABLE nonbrand_test_bounced_sessions
SELECT 
	nonbrand_test_sessions_w_landing_page.website_session_id,
	nonbrand_test_sessions_w_landing_page.landing_page,
    COUNT(website_pageviews.website_pageview_id) AS count_of_pages_viewed
FROM nonbrand_test_sessions_w_landing_page
LEFT JOIN website_pageviews
	ON website_pageviews.website_session_id = nonbrand_test_sessions_w_landing_page.website_session_id
GROUP BY
	nonbrand_test_sessions_w_landing_page.website_session_id,
	nonbrand_test_sessions_w_landing_page.landing_page
    HAVING COUNT(website_pageviews.website_pageview_id) = 1;
    
SELECT * FROM nonbrand_test_bounced_sessions;

SELECT 
	nonbrand_test_sessions_w_landing_page.landing_page,
    COUNT(DISTINCT nonbrand_test_sessions_w_landing_page.website_session_id) as sessions,
    COUNT(DISTINCT nonbrand_test_bounced_sessions.website_session_id) AS bounced_sessions,
    COUNT(DISTINCT nonbrand_test_bounced_sessions.website_session_id)/COUNT(DISTINCT nonbrand_test_sessions_w_landing_page.website_session_id) AS bounce_rate
FROM nonbrand_test_sessions_w_landing_page
LEFT JOIN nonbrand_test_bounced_sessions
ON nonbrand_test_sessions_w_landing_page.website_session_id = nonbrand_test_bounced_sessions.website_session_id
GROUP BY nonbrand_test_sessions_w_landing_page.landing_page;

-- Direct all campaigns to the new lander as it has lower bounce rate in order to optimize performance of the business


-- Follow up on previous work
-- Based on previous analysis that all previous traffic has been shifted to lander 1
-- Paid Search Non brand traffoc landing on /home and /lander-1, trended weekly since June 1st 
-- Pull overall paid search bounce rate trended weekly since June 1st
CREATE TEMPORARY TABLE paid_search_nonbrand_analysis
SELECT
		MIN(DATE(website_sessions.created_at)) AS week_start,
		website_pageviews.website_session_id,
        MIN(website_pageviews.website_pageview_id) AS min_pageview_id
FROM website_pageviews
INNER JOIN website_sessions
	ON website_sessions.website_session_id = website_pageviews.website_session_id
AND website_sessions.created_at BETWEEN '2012-06-01' AND '2012-08-31'
AND utm_source = 'gsearch'
AND utm_campaign = 'nonbrand'
GROUP BY 
	website_pageviews.website_session_id,
	WEEK(website_sessions.created_at);

CREATE TEMPORARY TABLE nonbrand_traffic_home_and_lander
SELECT 
	paid_search_nonbrand_analysis.week_start,
	paid_search_nonbrand_analysis.website_session_id,
    paid_search_nonbrand_analysis.min_pageview_id,
    website_pageviews.pageview_url AS landing_page
FROM paid_search_nonbrand_analysis
LEFT JOIN website_pageviews
		ON website_pageviews.website_pageview_id = paid_search_nonbrand_analysis.min_pageview_id
WHERE website_pageviews.pageview_url IN ('/home','/lander-1');

SELECT * FROM nonbrand_traffic_home_and_lander;

CREATE TEMPORARY TABLE nonbrand_HL_weekly_bounce
SELECT 
	nonbrand_traffic_home_and_lander.week_start,
	nonbrand_traffic_home_and_lander.website_session_id,
	nonbrand_traffic_home_and_lander.landing_page,
    COUNT(website_pageviews.website_pageview_id) AS count_of_pages_viewed
FROM nonbrand_traffic_home_and_lander
LEFT JOIN website_pageviews
	ON website_pageviews.website_session_id = nonbrand_traffic_home_and_lander.website_session_id
GROUP BY
	nonbrand_traffic_home_and_lander.week_start,
	nonbrand_traffic_home_and_lander.website_session_id,
	nonbrand_traffic_home_and_lander.landing_page
    HAVING COUNT(website_pageviews.website_pageview_id) = 1;

-- Bounced Sessions as a result of switch from home to lander
SELECT 
    MIN(DATE(nonbrand_traffic_home_and_lander.week_start)) AS week_start_date,
    COUNT(DISTINCT nonbrand_HL_weekly_bounce.website_session_id)/COUNT(DISTINCT nonbrand_traffic_home_and_lander.website_session_id) AS bounce_rate,
	COUNT(DISTINCT CASE WHEN nonbrand_traffic_home_and_lander.landing_page = '/home' THEN nonbrand_traffic_home_and_lander.website_session_id ELSE NULL END) AS home_sessions,
	COUNT(DISTINCT CASE WHEN nonbrand_traffic_home_and_lander.landing_page = '/lander-1' THEN nonbrand_traffic_home_and_lander.website_session_id ELSE NULL END) AS lander_sessions
FROM nonbrand_traffic_home_and_lander
LEFT JOIN nonbrand_HL_weekly_bounce
ON nonbrand_traffic_home_and_lander.website_session_id = nonbrand_HL_weekly_bounce.website_session_id
GROUP BY YEARWEEK(nonbrand_traffic_home_and_lander.week_start);

-- Conversion Funnel & Path Analysis
SELECT * FROM website_pageviews WHERE website_session_id = 1059;

-- Demo Conversion Funnel
-- we want to build a mini conversion funnel from lander-2 to cart
-- how many people reach each step and then drop out rates
-- only lander-2 traffic and only customers who like Mr. Fuzzy

-- Step 1: select all pageviews for relevant sessions
-- Step 2: identify each relevant pageview as specific funnel step
-- Step 3: create session level conversion funnel view
-- Step 4: aggregate the data to assess funnel performance

SELECT 
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    website_pageviews.created_at AS pageview_created_at,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
	CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mr_fuzzy_page,
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page
FROM website_sessions
	LEFT JOIN website_pageviews
	ON website_sessions.website_session_id = website_pageviews.website_session_id
    WHERE website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01'
    AND website_pageviews.pageview_url IN ('/lander-2','/products','/the-original-mr-fuzzy','/cart')
ORDER BY 
	website_sessions.website_session_id,
    website_pageviews.created_at;
    
-- Put previous query inside a subquery
CREATE TEMPORARY TABLE session_level_made_it_flag_demo
SELECT 
	website_session_id,
    MAX(products_page) AS product_made_it,
    MAX(mr_fuzzy_page) AS mrfuzzy_made_it,
    MAX(cart_page) AS cart_made_it
FROM (

SELECT 
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    website_pageviews.created_at AS pageview_created_at,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
	CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mr_fuzzy_page,
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page
FROM website_sessions
	LEFT JOIN website_pageviews
	ON website_sessions.website_session_id = website_pageviews.website_session_id
    WHERE website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01'
    AND website_pageviews.pageview_url IN ('/lander-2','/products','/the-original-mr-fuzzy','/cart')
ORDER BY 
	website_sessions.website_session_id) AS pageview_level
    
GROUP BY 
	website_session_id;
    
SELECT * FROM session_level_made_it_flag_demo;

-- Final output 
SELECT 
	COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) AS to_products,
    COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS mr_fuzzy,
    COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS to_cart
FROM session_level_made_it_flag_demo;

-- Translate these numbers into click rates 
SELECT 
	COUNT(DISTINCT website_session_id) AS sessions,
	COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS lander_clickthrough_rate,
	COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS products_clickthrough_rate,
	COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS mr_fuzzy_clickthrough_rate
FROM session_level_made_it_flag_demo;

-- Building Conversion Funnels and Conversion Paths
SELECT 
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    website_pageviews.created_at AS pageview_created_at,
	CASE WHEN website_pageviews.pageview_url = '/lander-1' THEN 1 ELSE 0 END AS lander_page,
	CASE WHEN website_pageviews.pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
	CASE WHEN website_pageviews.pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS original_mr_fuzzy,
	CASE WHEN website_pageviews.pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
	CASE WHEN website_pageviews.pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
	CASE WHEN website_pageviews.pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
	CASE WHEN website_pageviews.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thank_you_page
FROM website_sessions
	LEFT JOIN website_pageviews
    ON website_pageviews.website_session_id = website_pageviews.website_session_id
	WHERE website_pageviews.created_at BETWEEN '2012-08-05' AND '2012-09-05'
    AND website_sessions.utm_source = 'gsearch'
    AND website_pageviews.pageview_url IN ('/lander-1','/products','/the-original-mr-fuzzy', '/cart','/shipping','/billing','/thank-you-for-your-order')
    ORDER BY website_sessions.website_session_id, website_pageviews.created_at;
    