 Sql-project
 
A SQL project based on lecturer exercises, including table creation, relationships, queries, and answers to practical questions.
 SQL Database Project

 Description
This project is based on a set of SQL exercises provided by my lecturer. It demonstrates designing a relational database, creating multiple tables, splitting data into normalized structures, and writing queries to solve practical problems.

# Tables Created
- **User**: Stores information about users  
- **Subscription**: Tracks subscription plans for users  
- **Engagement**: Records user activity and engagement  
- **Churn**: Tracks users who have cancelled or stopped using the service  

# What I Did
- Designed and created relational tables with proper structure  
- Applied Primary and Foreign Key constraints for relationships  
- Split data into multiple tables (normalization) to avoid redundancy  
- Wrote SQL queries to answer all lecturer-provided questions  
- Used JOIN operations to combine tables and retrieve meaningful data  
- Handled NULL values and ensured data integrity  

 #Tools Used
- PostgreSQL (pgAdmin)

# Purpose
To showcase practical skills in database design, normalization, and SQL query problem-solving.

# Sample queries 
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

