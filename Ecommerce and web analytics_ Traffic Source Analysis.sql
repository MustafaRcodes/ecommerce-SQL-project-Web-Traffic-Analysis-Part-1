-- Analyzing Traffic source OR TRAFFIC SOURCE ANALYSIS
-- We use the utm parameters stored in the database to identify paid website sessions
-- From our session data, we link to our order data to undertand how much revenue our paid campaigns are driving.
-- Paid marketing campaigns: UTM Tracking Parameters

-- Website sessions that traffics more volume or orders
SELECT
   utm_content,
   COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
   COUNT(DISTINCT orders.order_id) AS orders
FROM website_sessions
   LEFT JOIN orders
	 ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.website_session_id BETWEEN 1000 AND 2000 -- arbitrary
GROUP BY 
   utm_content -- Can also use 1 because the position of above column is 1 after SELECT
ORDER BY COUNT(DISTINCT website_sessions.website_session_id) DESC; -- Can also 2 because the position of above column is 2 after SELECT

-- Checking and calculating conversion rates from each session
SELECT
   utm_content,
   COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
   COUNT(DISTINCT orders.order_id) AS orders,
   COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_conv_rate
FROM website_sessions
   LEFT JOIN orders
	 ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.website_session_id BETWEEN 1000 AND 2000 
GROUP BY 
   utm_content 
ORDER BY COUNT(DISTINCT website_sessions.website_session_id) DESC; 

-- Business problem : CEO would like to understand where the bulk of website sessions are coming from
-- breakdown by UTM source, campaign, and referring domain. 
SELECT
    utm_source,
    utm_campaign,
    http_referer,
    COUNT(website_session_id) AS number_of_sessions
FROM website_sessions
WHERE created_at <= '2012-04-12'
    GROUP BY 
    utm_source,
    utm_campaign,
    http_referer
ORDER BY 
    number_of_sessions DESC;
    
 -- Calculating and analyzing conversion rate from session order, based on wwhat we are paying 
 -- for clicks, need CVR of at least 4% to make number works. if lower, we need to reduce bid 
 -- if higher, we can increase bid to drive more volume.
SELECT
   COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
   COUNT(DISTINCT orders.order_id) AS orders,
   COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_conv_rate
FROM website_sessions
   LEFT JOIN orders
	 ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at <= '2012-04-14'
   AND utm_source = 'gsearch'
   AND utm_campaign = 'nonbrand';

-- Bid Optimization & Trend Analysis
-- Using date funstions with GROUP BY and aggregate function like COUNT() and SUM() to show trend.alter
-- We will be using YEAR(), QUARTER(), MONTH(), WEEK(), DATE(), NOW() with GROUP BY

-- Checking number of session by YEAR, WEEK AND week date on which session started in the week
SELECT
    YEAR (created_at),
    WEEK (created_at),
    MIN(DATE(created_at)) AS week_start,
    COUNT(DISTINCT website_session_id) AS sessions
FROM 
    website_sessions
WHERE YEAR (created_at) = '2015'
    GROUP BY 1,2;
    
-- From orders table checking number of items purchased orders with 1 product and how many orders with 2 product.
-- Pivoting by 1 and 2 ( number of item purchased)
SELECT
    primary_product_id,
    order_id,
    items_purchased,
    COUNT(  DISTINCT CASE WHEN items_purchased = 1 THEN 1 END) AS '1_one_item_purchase',
    COUNT(  DISTINCT CASE WHEN items_purchased = 2 THEN 2 END) AS '2_two_item_purchase'
FROM
   orders
WHERE order_id BETWEEN 31000 AND 32000
GROUP BY 
   primary_product_id,
    order_id
ORDER BY 
         1,2,3;
-- Another way of writing above code is as per below.
    SELECT
    primary_product_id,
    order_id,
    items_purchased,
  COUNT(DISTINCT CASE WHEN items_purchased = 1 THEN order_id ELSE NULL END) AS '1_one_item_order',
  COUNT(DISTINCT CASE WHEN items_purchased = 2 THEN order_id ELSE NULL END) AS '2_two_item_order'
FROM
   orders
WHERE order_id BETWEEN 31000 AND 32000
GROUP BY 
   primary_product_id,
    order_id,
    items_purchased;
    
-- Checking total count of 1 and 2 product order 
SELECT
    COUNT(CASE WHEN items_purchased = 1 THEN 1 END) AS '1_one_item_purchase',
    COUNT(CASE WHEN items_purchased = 2 THEN 2 END) AS '2_two_item_purchase'
FROM
   orders
   WHERE order_id BETWEEN 31000 AND 32000;
   
-- Checking it by primary product ID 
SELECT
    primary_product_id,
  COUNT(DISTINCT CASE WHEN items_purchased = 1 THEN order_id ELSE NULL END) AS '1_one_item_order',
  COUNT(DISTINCT CASE WHEN items_purchased = 2 THEN order_id ELSE NULL END) AS '2_two_item_order'
FROM
   orders
WHERE order_id BETWEEN 31000 AND 32000
GROUP BY 
      1;
-- Traffic source Trending. Pulling gsearch trended session volume, by week to see if the bid changes have caused volume to drop. 
SELECT 
-- YEAR(created_at) AS year,
-- WEEK(created_at) AS week,
MIN(DATE(created_at)) AS week_start_date,
COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE created_at <'2012-05-12'
AND utm_source = 'gsearch'
AND utm_campaign = 'nonbrand'
GROUP BY 
      YEAR(created_at),
      WEEK(created_at);
      -- Does look like there is an impact on session volume from April. From 800 range down to in between 500 - 600
      
   -- Bid optimization for paid traffic.
  SELECT
  website_sessions.device_type,
  COUNT( DISTINCT website_sessions.website_session_id) AS sessions,
  COUNT( DISTINCT orders.order_id) AS orders,
  COUNT( DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_conv_rate
  FROM website_sessions
     LEFT JOIN orders
     ON orders.website_session_id = website_sessions.website_session_id
  WHERE website_sessions.created_at <'2012-05-11'
AND website_sessions.utm_source = 'gsearch'
AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY
     1;
   -- Key take away is desktop session are performing way better than mobile due to high conversion rate
   -- Management is going to increase bids on desktop. When bid higher, will rank higher in the auction
   -- This insights should lead to a sales boost.
  
-- pulling weekly trend for both desktop and mobile 
SELECT
  YEAR(website_sessions.created_at) AS year,
  WEEK(website_sessions.created_at) AS weekly,
  MIN(DATE(website_sessions.created_at)) AS Session_start_date,
  website_sessions.device_type,
  COUNT( DISTINCT website_sessions.website_session_id) AS sessions,
  COUNT( DISTINCT orders.order_id) AS orders,
  COUNT( DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_conv_rate
  FROM website_sessions
     LEFT JOIN orders
     ON orders.website_session_id = website_sessions.website_session_id
  WHERE website_sessions.created_at BETWEEN '2012-04-15' AND '2012-05-19'
AND website_sessions.utm_source = 'gsearch'
AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY
    YEAR(website_sessions.created_at),
    WEEK(website_sessions.created_at),
    website_sessions.device_type
ORDER BY
    website_sessions.device_type;
    
-- one hot encoding to check count by week to check device type used for sessions.
SELECT
  MIN(DATE(created_at)) AS week_start_date,
  SUM(   CASE WHEN device_type = 'mobile' THEN 1 ELSE 0 END) AS mob_sessions,
  SUM(   CASE WHEN device_type = 'desktop'THEN 1 ELSE 0 END) AS dtop_sessions
FROM website_sessions
  WHERE  created_at < '2012-06-09' 
AND created_at > '2012-04-15'
AND utm_source = 'gsearch'
AND utm_campaign = 'nonbrand'
GROUP BY
    YEAR(created_at),
    WEEK(created_at);

-- Another way of writing same code.
SELECT
  MIN(DATE(created_at)) AS week_start_date,
  COUNT(   DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id  ELSE NULL END) AS mob_sessions,
  COUNT(   DISTINCT CASE WHEN device_type = 'desktop'THEN website_session_id  ELSE NULL END) AS dtop_sessions
FROM website_sessions
  WHERE  created_at < '2012-06-09' 
AND created_at > '2012-04-15'
AND utm_source = 'gsearch'
AND utm_campaign = 'nonbrand'
GROUP BY
    YEAR(created_at),
    WEEK(created_at);
    
-- Looks like mobile has been pretty flat or little down however desktop is looking strong. 
-- Thats really great, bid changes we made based on our previuos conversion analysis. We are in the right direction.
