SELECT keyword, ROUND(AVG(view_count)) AS avg_views, ROUND(AVG(like_count)) AS avg_likes
FROM youtube_data
GROUP BY keyword
ORDER BY avg_views DESC, avg_likes DESC;

SELECT 
    CASE 
        WHEN LENGTH(title) BETWEEN 0 AND 41 THEN 'Short'
        WHEN LENGTH(title) BETWEEN 42 AND 70 THEN 'Medium'
        WHEN LENGTH(title) >= 71 THEN 'Long'
    END AS title_length,
    ROUND(AVG(view_count)) AS avg_views,
    ROUND(AVG(like_count)) AS avg_likes
FROM youtube_data
GROUP BY title_length;

SELECT 
    'challenge' AS keyword,
    CASE 
        WHEN year = 2024 THEN '2024'
        WHEN year = 2023 THEN '2023'
        ELSE '2022 and before'
    END AS year_group,
    ROUND(AVG(view_count)) AS average_views,
    ROUND(AVG(like_count)) AS average_likes
FROM youtube_data
WHERE keyword = 'challenge'
GROUP BY year_group
ORDER BY year_group;
    
SELECT 
    'reaction' AS keyword,
    CASE 
        WHEN year = 2024 THEN '2024'
        WHEN year = 2023 THEN '2023'
        ELSE '2022 and before'
    END AS year_group,
    ROUND(AVG(view_count)) AS total_views,
    ROUND(AVG(like_count)) AS total_likes
FROM youtube_data
WHERE keyword = 'reaction'
GROUP BY year_group
ORDER BY year_group;

SELECT 
    'vlog' AS keyword,
    CASE 
        WHEN year = 2024 THEN '2024'
        WHEN year = 2023 THEN '2023'
        ELSE '2022 and before'
    END AS year_group,
    ROUND(AVG(view_count)) AS total_views,
    ROUND(AVG(like_count)) AS total_likes
FROM youtube_data
WHERE keyword = 'vlog'
GROUP BY year_group
ORDER BY year_group;

SELECT keyword, SUM(view_count) AS total_views, SUM(like_count) AS total_likes, ROUND((SUM(like_count) * 100.0 / SUM(view_count)), 2) AS engagement_rate
FROM youtube_data
GROUP BY keyword
ORDER BY engagement_rate DESC;

SELECT 
    keyword,
    CASE 
        WHEN month IN (3, 4, 5) THEN 'Spring'
        WHEN month IN (6, 7, 8) THEN 'Summer'
        WHEN month IN (9, 10, 11) THEN 'Fall'
        WHEN month IN (12, 1, 2) THEN 'Winter'
    END AS season,
    SUM(view_count) AS total_views,
    SUM(like_count) AS total_likes
FROM youtube_data
GROUP BY keyword, season
ORDER BY keyword, season;
