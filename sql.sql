DROP TABLE IF EXISTS health_app_raw;

CREATE TABLE health_app_raw(
user_id INTEGER,
age INTEGER,
gender VARCHAR(10),
region VARCHAR(50),
bmi NUMERIC(5,2),
plan_type VARCHAR(20),
monthly_fee NUMERIC(8,2),
discount_rate NUMERIC(5,2),
tenure_days INTEGER,
auto_renew BOOLEAN,
last_payment_success BOOLEAN,
weekly_sessions NUMERIC(5,1),
avg_session_minutes NUMERIC(6,1),
workout_completion_rate NUMERIC(5,2),
diet_log_adherence NUMERIC(5,2),
sleep_tracking_usage NUMERIC(5,2),
coaching_messages_per_week NUMERIC(5,1),
community_posts_per_month NUMERIC(6,1),
device_type VARCHAR(50),
wearable_connected BOOLEAN,
push_enabled BOOLEAN,
churn_within_6m BOOLEAN
);

SELECT *
FROM engagement

CREATE TABLE users(
user_id INTEGER PRIMARY KEY,
age INTEGER,
gender VARCHAR(10),
region VARCHAR(50),
bmi NUMERIC(5,2)
);

INSERT INTO users(user_id,age,gender,region,bmi)
SELECT user_id,age,gender,region,bmi
FROM health_app_raw;

CREATE TABLE subscription(
subscription_id VARCHAR(9) PRIMARY KEY,
user_id INTEGER UNIQUE,
plan_type VARCHAR(20),
monthly_fee NUMERIC(8,2),
discount_rate NUMERIC(5,2),
tenure_days INTEGER,
auto_renew BOOLEAN,
last_payment_success BOOLEAN,
FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE SEQUENCE subscription_seq START 1;

INSERT INTO subscription(subscription_id,user_id,plan_type,monthly_fee,discount_rate,tenure_days,auto_renew,last_payment_success)

SELECT
'S'||LPAD(nextval('subscription_seq')::text,8,'0'),
user_id,
plan_type,
monthly_fee,
discount_rate,
tenure_days,
auto_renew,
last_payment_success
FROM health_app_raw;

CREATE TABLE engagement(
engagement_id VARCHAR(9) PRIMARY KEY,
user_id INTEGER UNIQUE,
weekly_sessions NUMERIC(5,1),
avg_session_minutes NUMERIC(6,1),
workout_completion_rate NUMERIC(5,2),
diet_log_adherence NUMERIC(5,2),
sleep_tracking_usage NUMERIC(5,2),
coaching_messages_per_week NUMERIC(5,1),
community_posts_per_month NUMERIC(6,1),
device_type VARCHAR(50),
wearable_connected BOOLEAN,
push_enabled BOOLEAN,
FOREIGN KEY(user_id) REFERENCES users(user_id)
);

DESCRIBE engagement
SHOW COLUMNS FROM engagement;

CREATE SEQUENCE engagement_seq START 1;
ALTER TABLE engagement
RENAME COLUMN community_posts_per_month TO community_posts_per_month;

INSERT INTO engagement(engagement_id,user_id,weekly_sessions,avg_session_minutes,workout_completion_rate,diet_log_adherence,sleep_tracking_usage,coaching_messages_per_week,community_posts_per_month,device_type,wearable_connected,push_enabled)

SELECT
'E'||LPAD(nextval('engagement_seq')::text,8,'0'),
user_id,
weekly_sessions,
avg_session_minutes,
workout_completion_rate,
diet_log_adherence,
sleep_tracking_usage,
coaching_messages_per_week,
community_posts_per_month,
device_type,
wearable_connected,
push_enabled
FROM health_app_raw;

CREATE TABLE churn_status(
churn_id VARCHAR(9) PRIMARY KEY,
user_id INTEGER UNIQUE,
churn_within_6m BOOLEAN,
FOREIGN KEY(user_id) REFERENCES users(user_id)
);

CREATE SEQUENCE churn_seq START 1;

INSERT INTO churn_status(churn_id,user_id,churn_within_6m)
SELECT
'C'||LPAD(nextval('churn_seq')::text,8,'0'),
user_id,
churn_within_6m
FROM health_app_raw;

SELECT COUNT(DISTINCT user_id) AS unique_users
FROM health_app_raw;

SELECT
plan_type,
COUNT(*) AS total_users,
ROUND(COUNT(*)* 100.0/(SELECT COUNT(*)FROM health_app_raw),2) AS pct
FROM health_app_raw
GROUP BY plan_type
ORDER BY total_users DESC;

SELECT
MIN(age) AS min_age,
MAX(age) AS max_age,
ROUND(AVG(age),1) AS avg_age,
MIN(bmi) AS min_bmi,
    MAX(bmi) AS max_bmi,
    ROUND(AVG(bmi),2) AS avg_bmi,
    MIN(weekly_sessions) AS min_sessions,
    MAX(weekly_sessions) AS max_sessions,
    ROUND(AVG(weekly_sessions), 1) AS avg_sessions,
    MIN(tenure_days) AS min_tenure,
    MAX(tenure_days) AS max_tenure
FROM health_app_raw;

SELECT
    COUNT(*) FILTER (WHERE user_id IS NULL)                  AS missing_user_id,
    COUNT(*) FILTER (WHERE age IS NULL)                      AS missing_age,
    COUNT(*) FILTER (WHERE gender IS NULL)                   AS missing_gender,
    COUNT(*) FILTER (WHERE region IS NULL)                   AS missing_region,
    COUNT(*) FILTER (WHERE bmi IS NULL)                      AS missing_bmi,
    COUNT(*) FILTER (WHERE plan_type IS NULL)                AS missing_plan_type,
    COUNT(*) FILTER (WHERE monthly_fee IS NULL)              AS missing_monthly_fee,
    COUNT(*) FILTER (WHERE discount_rate IS NULL)            AS missing_discount_rate,
    COUNT(*) FILTER (WHERE tenure_days IS NULL)              AS missing_tenure_days,
    COUNT(*) FILTER (WHERE auto_renew IS NULL)               AS missing_auto_renew,
    COUNT(*) FILTER (WHERE last_payment_success IS NULL)     AS missing_last_payment,
    COUNT(*) FILTER (WHERE weekly_sessions IS NULL)          AS missing_weekly_sessions,
    COUNT(*) FILTER (WHERE avg_session_minutes IS NULL)      AS missing_avg_session_min,
    COUNT(*) FILTER (WHERE workout_completion_rate IS NULL)  AS missing_workout_rate,
    COUNT(*) FILTER (WHERE diet_log_adherence IS NULL)       AS missing_diet_log,
    COUNT(*) FILTER (WHERE sleep_tracking_usage IS NULL)     AS missing_sleep_tracking,
    COUNT(*) FILTER (WHERE coaching_messages_per_week IS NULL) AS missing_coaching,
    COUNT(*) FILTER (WHERE community_posts_per_month IS NULL)  AS missing_community,
    COUNT(*) FILTER (WHERE device_type IS NULL)              AS missing_device_type,
    COUNT(*) FILTER (WHERE wearable_connected IS NULL)       AS missing_wearable,
    COUNT(*) FILTER (WHERE push_enabled IS NULL)             AS missing_push,
    COUNT(*) FILTER (WHERE churn_within_6m IS NULL)          AS missing_churn
FROM health_app_raw;


UPDATE health_app_raw
SET bmi = (
    SELECT ROUND(AVG(bmi), 2)
    FROM health_app_raw
    WHERE bmi IS NOT NULL
)
WHERE bmi IS NULL;

UPDATE engagement
SET community_posts_per_month = (
    SELECT ROUND(AVG(community_posts_per_month), 1)
    FROM engagement
    WHERE community_posts_per_month IS NOT NULL
)
WHERE community_posts_per_month IS NULL;

SELECT COUNT(*) FILTER (WHERE bmi IS NULL) AS remaining_null_bmi
FROM health_app_raw;

SELECT 
    COUNT(*) FILTER (WHERE community_posts_per_month IS NULL) AS remaining_nulls
FROM engagement;

SELECT gender, COUNT(*) AS total FROM health_app_raw GROUP BY gender ORDER BY total DESC;

SELECT * FROM health_app_raw;

SELECT auto_renew,          COUNT(*) FROM health_app_raw GROUP BY auto_renew;
SELECT last_payment_success, COUNT(*) FROM health_app_raw GROUP BY last_payment_success;
SELECT wearable_connected,  COUNT(*) FROM health_app_raw GROUP BY wearable_connected;
SELECT push_enabled,        COUNT(*) FROM health_app_raw GROUP BY push_enabled;
SELECT churn_within_6m,     COUNT(*) FROM health_app_raw GROUP BY churn_within_6m;

SELECT MIN(workout_completion_rate), MAX(workout_completion_rate)
FROM health_app_raw;

SELECT MIN(diet_log_adherence), MAX(diet_log_adherence)
FROM health_app_raw;

SELECT MIN(sleep_tracking_usage), MAX(sleep_tracking_usage)
FROM health_app_raw;

SELECT 'users'        AS table_name, COUNT(*) AS row_count FROM users
UNION ALL
SELECT 'subscription',                COUNT(*) FROM subscription
UNION ALL
SELECT 'engagement',                  COUNT(*) FROM engagement
UNION ALL
SELECT 'churn_status',                COUNT(*) FROM churn_status;

SELECT COUNT(*) AS orphaned_subscription
FROM subscription s
LEFT JOIN users u ON s.user_id = u.user_id
WHERE u.user_id IS NULL;

SELECT COUNT(*) AS orphaned_engagement
FROM engagement e
LEFT JOIN users u ON e.user_id = u.user_id
WHERE u.user_id IS NULL;

SELECT COUNT(*) AS orphaned_churn
FROM churn_status c
LEFT JOIN users u ON c.user_id = u.user_id
WHERE u.user_id IS NULL;

SELECT
    u.user_id,
    u.age,
    u.gender,
    u.region,
    s.plan_type,
    s.monthly_fee,
    s.auto_renew,
    e.weekly_sessions,
    e.workout_completion_rate,
    e.device_type,
    c.churn_within_6m
FROM users u
JOIN subscription  s ON u.user_id = s.user_id
JOIN engagement    e ON u.user_id = e.user_id
JOIN churn_status  c ON u.user_id = c.user_id
LIMIT 5;

--What is the overall churn rate?
SELECT
    COUNT(*) AS total_users,
    SUM(CASE WHEN c.churn_within_6m THEN 1 ELSE 0 END) AS churned_users,
    SUM(CASE WHEN NOT c.churn_within_6m THEN 1 ELSE 0 END) AS retained_users,
    ROUND(
        SUM(CASE WHEN c.churn_within_6m THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
    2) AS churn_rate_pct
FROM users u
JOIN churn_status c ON u.user_id = c.user_id;

--Which subscription plan has the highest churn rate?
SELECT
    s.plan_type,
    COUNT(*) AS total_users,
    SUM(CASE WHEN c.churn_within_6m THEN 1 ELSE 0 END)  AS churned_users,
    ROUND(
        SUM(CASE WHEN c.churn_within_6m THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
    2) AS churn_rate_pct
FROM subscription s
JOIN churn_status c ON s.user_id = c.user_id
GROUP BY s.plan_type
ORDER BY churn_rate_pct DESC;

--How does churn differ by geographic region?
SELECT
    u.region,
    COUNT(*) AS total_users,
    SUM(CASE WHEN c.churn_within_6m THEN 1 ELSE 0 END)  AS churned_users,
    ROUND(
        SUM(CASE WHEN c.churn_within_6m THEN 1 ELSE 0 END) * 100.0 / COUNT(*),2)                                                    AS churn_rate_pct
FROM users u
JOIN churn_status c ON u.user_id = c.user_id
GROUP BY u.region
ORDER BY churn_rate_pct DESC;

--Does auto-renewal status affect churn?
SELECT
    s.auto_renew,
    COUNT(*) AS total_users,
    SUM(CASE WHEN c.churn_within_6m THEN 1 ELSE 0 END)  AS churned_users,
    SUM(CASE WHEN NOT c.churn_within_6m THEN 1 ELSE 0 END) AS retained_users,
    ROUND(
        SUM(CASE WHEN c.churn_within_6m THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
    2) AS churn_rate_pct
FROM subscription s
JOIN churn_status c ON s.user_id = c.user_id
GROUP BY s.auto_renew
ORDER BY s.auto_renew DESC;

--Are churned users less engaged than retained users?
SELECT
    c.churn_within_6m,
    ROUND(AVG(e.weekly_sessions), 2) AS avg_weekly_sessions,
    ROUND(AVG(e.avg_session_minutes), 2) AS avg_session_minutes,
    ROUND(AVG(e.workout_completion_rate), 2)  AS avg_workout_completion,
    ROUND(AVG(e.diet_log_adherence), 2) AS avg_diet_adherence,
    ROUND(AVG(e.sleep_tracking_usage), 2) AS avg_sleep_tracking,
    ROUND(AVG(e.coaching_messages_per_week), 2) AS avg_coaching_msgs
FROM engagement e
JOIN churn_status c ON e.user_id = c.user_id
GROUP BY c.churn_within_6m;

--How is churn distributed across device types?
SELECT
    e.device_type,
    COUNT(*)                                              AS total_users,
    SUM(CASE WHEN c.churn_within_6m THEN 1 ELSE 0 END)  AS churned_users,
    ROUND(
        SUM(CASE WHEN c.churn_within_6m THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
    2)                                                    AS churn_rate_pct
FROM engagement e
JOIN churn_status c ON e.user_id = c.user_id
GROUP BY e.device_type
ORDER BY churn_rate_pct DESC;

--Do users who complete more workouts churn less?
SELECT
    CASE
        WHEN e.workout_completion_rate < 0.3 THEN 'Low'
        WHEN e.workout_completion_rate BETWEEN 0.3 AND 0.74 THEN 'Mid'
        ELSE 'High'
    END AS completion_band,
    COUNT(*) AS total_users,
    SUM(CASE WHEN c.churn_within_6m THEN 1 ELSE 0 END)  AS churned_users,
    ROUND(
      SUM(CASE WHEN c.churn_within_6m THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
    2) AS churn_rate_pct
FROM engagement e
JOIN churn_status c ON e.user_id = c.user_id
GROUP BY completion_band
ORDER BY churn_rate_pct DESC;

CREATE OR REPLACE VIEW vw_analysis_base AS
SELECT
    u.user_id,
    u.age,
    u.gender,
    u.region,
    s.plan_type,
    s.auto_renew,
    s.tenure_days,
    e.weekly_sessions,
    e.avg_session_minutes,
    e.workout_completion_rate,
    e.diet_log_adherence,
    e.sleep_tracking_usage,
    e.device_type,
    c.churn_within_6m
FROM users u
JOIN subscription  s ON u.user_id = s.user_id
JOIN engagement    e ON u.user_id = e.user_id
JOIN churn_status  c ON u.user_id = c.user_id;

CREATE OR REPLACE VIEW vw_kpi_base AS
SELECT
    COUNT(*)                                                        AS total_users,
    SUM(CASE WHEN c.churn_within_6m = TRUE  THEN 1 ELSE 0 END)    AS total_churned,
    SUM(CASE WHEN c.churn_within_6m = FALSE THEN 1 ELSE 0 END)    AS total_retained,
    ROUND(
        SUM(CASE WHEN c.churn_within_6m = TRUE THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
    2)                                                              AS churn_rate_pct
FROM users u
JOIN churn_status c ON u.user_id = c.user_id;


