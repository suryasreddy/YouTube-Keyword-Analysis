# Unlocking YouTube Success: Analyzing the Impact of Title Keywords and Length on Video Performance

## Introduction
### Background and Problem Statement
YouTube has evolved into one of the most influential platforms for content creation, where videos from a vast range of genres can reach millions of viewers worldwide. As a long-time YouTube viewer, I've witnessed how certain trends and content styles gain viral traction, often driven by compelling video titles and thumbnails. This personal experience has sparked my curiosity about what makes a YouTube video successful, particularly the role that video titles play in attracting viewers.

In this project, I aim to explore the relationship between YouTube title keywords, title lengths, and video performance. Specifically, I will analyze how certain keywords might correlate with higher view counts and likes, and whether the length of a title influences engagement. Understanding these patterns could provide valuable insights for content creators looking to optimize their titles to attract more viewers. My ultimate goal is to not only uncover actionable data but also to apply these insights toward potentially starting my own YouTube channel in the future.

### Tools Used
- **Python**: Youtube Data Scraping
- **Excel**: Data Cleaning
- **SQLite**: Advanced Queries for Data Analysis 
- **Tableau**: Building Dashboard

## Web Scraping
I used Python and the YouTube Data API to scrape video metadata, specifically focusing on keywords like "challenge," "reaction," and "vlog." These three genres are among the most popular on YouTube, making them ideal for analyzing title keyword effectiveness. The googleapiclient.discovery library was utilized to interact with the YouTube API, allowing me to pull essential data such as video titles, view counts, like counts, and publication dates. I built a custom function to retrieve video details by making two API calls: one to search for videos using specific keywords, and another to fetch detailed statistics for those videos. The process included gathering video IDs from the search results and then fetching the full details (title, views, likes, and dates) for each video in batches of 50. By compiling this data into a structured format using pandas, I was able to efficiently export it into Excel for further analysis. This approach ensured I collected relevant and up-to-date data directly from YouTube, forming the foundation for my analysis on title keywords and performance.

Below is the Python function used for scraping video data from YouTube using the YouTube Data API. This function searches for videos based on specified keywords, fetches video details, and aggregates them into a list that includes the video title, view count, like count, keyword, and published date.

```python
def fetch_videos_data(keyword):
    # Search for videos with the given keyword
    search_request = youtube.search().list(
        part="snippet",
        q=keyword,
        type="video",
        maxResults=50  # Fetch top 50 videos
    )

    search_response = search_request.execute()

    # Collect video IDs
    video_ids = [item['id']['videoId'] for item in search_response['items']]

    # Fetch video details
    videos_request = youtube.videos().list(
        part="snippet,statistics",
        id=",".join(video_ids)
    )

    videos_response = videos_request.execute()

    # Extract required data
    videos_data = []
    for item in videos_response['items']:
        title = item['snippet']['title']  # Get video title
        view_count = item['statistics'].get('viewCount', 0) # Get the view count
        like_count = item['statistics'].get('likeCount', 0) # Get the like count
        published_at = item['snippet']['publishedAt']  # Get the published date

        videos_data.append([
            title,
            view_count,
            like_count,
            keyword,  
            published_at  
        ])

    return videos_data

# Fetch top 50 videos for "challenge," "reaction," and "vlog"
challenge_videos = fetch_videos_data("challenge")
reaction_videos = fetch_videos_data("reaction")
vlog_videos = fetch_videos_data("vlog")

# Combine the data
all_videos = challenge_videos + reaction_videos + vlog_videos
```

## Dataset Overview
The dataset compiled from YouTube features a selection of videos filtered by the top-performing keywords "challenge," "reaction," and "vlog." These keywords are chosen due to their widespread popularity and potential for high user engagement, which makes them particularly relevant for studying trends and success factors in video content.

### Fields Included
- **Title**: The title of the video. This field is crucial as it allows us to analyze the impact of keywords and title length on the video's performance.
- **View Count**: The number of times the video has been viewed. This metric serves as a primary indicator of the video's popularity and reach.
- **Like Count**: The number of likes a video has received. It is a direct measure of viewer engagement and approval.
- **Keyword**: The search keyword used to find this video. This field helps categorize the data based on the type of content and allows for segmented analysis.
- **Published At**: The publication date of the video. This information is useful for understanding trends over time and the lifecycle of video popularity.

The objective of analyzing these fields is to uncover actionable insights into what makes a YouTube video successful. By focusing on how specific title keywords and their lengths influence views and likes, we can derive strategies that content creators might use to optimize their video titles to maximize viewer engagement. Moreover, examining the publication date allows us to explore whether the timing of video releases impacts performance. This analysis will not only enhance our understanding of content strategy on YouTube but also inform potential approaches for those looking to launch or optimize their own YouTube channels. The ultimate goal is to leverage these insights to craft content that resonates with audiences and performs well in terms of both visibility and engagement on the platform.

## Data Cleaning
In preparing the YouTube dataset for analysis, several crucial data cleaning steps were undertaken in Excel to ensure accuracy and usability. Initially, the viewCount, likeCount, and publishedAt columns were converted from text format to numeric values to facilitate numerical operations and analyses. This conversion was essential for accurate calculations and comparisons across data points.

Additionally, for enhanced readability and ease of use, the column titles were simplified: view_count was renamed to views, like_count to likes, and published_at to year. The year column initially contained full timestamps (e.g., "2022-09-13T19:00:17Z"). I decided to split this into two columns containing “month” and “year” respectively. This simplification was made by extracting the month and year from each timestamp, allowing for a more focused analysis of annual trends and removing unnecessary details like time, which were not pertinent to the scope of this analysis. (=LEFT(C2, 4)) These adjustments made the dataset more manageable and tailored for examining trends over the years, setting the stage for a clear and structured analysis.
### Missing Values
During the cleaning process, it was noted that there were three missing values in the likeCount column. To address this, the median like count from each video category—challenges, vlogs, and reactions—was calculated. (Ex: =MEDIAN(C2:C51)) Each missing value was then replaced with the respective category's median to maintain consistency and reliability in the dataset without skewing the data distribution.

## Data Analysis

### 1. Keyword Performance Analysis

#### Question
How do different keywords (challenge, reaction, vlog) correlate with average views and likes?

#### Objective
Identify which keywords are currently more effective at driving higher engagement and viewership. This analysis can help understand which content genres are resonating with the audience.

#### Query
```sql
SELECT keyword, 
       ROUND(AVG(view_count)) AS avg_views, 
       ROUND(AVG(like_count)) AS avg_likes
FROM youtube_data
GROUP BY keyword
ORDER BY avg_views DESC, avg_likes DESC;
```

#### Result

| Keyword   | Avg Views | Avg Likes |
|-----------|-----------|-----------|
| challenge | 30,089,906| 609,112   |
| reaction  | 6,064,429 | 232,337   |
| vlog      | 4,330,133 | 167,306   |

#### Insights
Challenge videos dominate in both viewer engagement and popularity, averaging 30 million views and over 609,000 likes, significantly outperforming other categories. Reaction videos, while also popular, attract a far smaller audience with an average of 6 million views and approximately 232,000 likes. Vlogs are the least engaging, with around 4.3 million views and 167,000 likes, suggesting a more niche appeal compared to the widespread interest in challenge videos.

### 2. Title Length Impact

#### Question
What is the relationship between title length and video performance metrics (views and likes)?

#### Objective
Determine if shorter or longer titles have a significant impact on video performance. This can guide content creators on optimal title lengths for maximizing engagement.

#### Analysis Method
To address the question, I categorized title lengths into three groups: Short, Medium, and Long. Within our dataset, title lengths ranged from 12 to 99 characters. The categories were defined as follows:
- **Short**: 12-40 characters
- **Medium**: 41-70 characters
- **Long**: 71-99 characters

#### Query
```sql
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
```

#### Result

| Title Length | Avg Views  | Avg Likes |
|--------------|------------|-----------|
| Long         | 10,575,263 | 266,038   |
| Medium       | 8,609,431  | 202,251   |
| Short        | 26,850,825 | 689,060   |

#### Insights
The distribution of video performance by title length reveals that:
- **Short titles** (0-41 characters) significantly outperform the other categories, achieving an average of approximately 26,850,825 views and 689,060 likes. This suggests a strong viewer preference for concise titles.
- **Medium-length titles** (42-70 characters) garner around 8,609,431 views and 202,251 likes, indicating moderate success.
- **Long titles** (>71 characters) show lower but still substantial engagement, with about 10,575,263 views and 266,038 likes, demonstrating that while lengthier titles attract fewer viewers on average, they still maintain a solid base of engagement.

### 3. Trend Analysis Over Time

#### Question
How has the popularity of the keywords changed over the years?

#### Objective
Analyze trends over time to see if the popularity of these video types is increasing, decreasing, or remains stable. This analysis can help in predicting future trends and planning content accordingly.

#### Example Query for "Challenge" Keyword
```sql
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
```

#### Results

| Keyword    | Year Group      | Average Views | Average Likes |
|------------|-----------------|---------------|---------------|
| Challenge  | 2022 and before | 29,330,295    | 404,523       |
| Challenge  | 2023            | 13,049,976    | 171,595       |
| Challenge  | 2024            | 41,416,886    | 1,017,726     |

| Keyword   | Year Group      | Average Views | Average Likes |
|-----------|-----------------|---------------|---------------|
| Reaction  | 2022 and before | 11,727,306    | 573,591       |
| Reaction  | 2023            | 14,970,773    | 273,677       |
| Reaction  | 2024            | 1,316,137     | 94,808        |

| Keyword   | Year Group      | Average Views | Average Likes |
|-----------|-----------------|---------------|---------------|
| Vlog      | 2022 and before | 11,202,682    | 264,382       |
| Vlog      | 2023            | 4,107,526     | 299,157       |
| Vlog      | 2024            | 2,016,390     | 105,093       |

#### Insights
- **Challenge Videos**: Show a growing trend in popularity, peaking at 41.4 million views in 2024 after a slight dip in 2023. Likes also surged to over 1 million in 2024, indicating robust engagement.
- **Reaction Videos**: Experienced an initial rise in views through 2023 but saw a drastic decline in 2024, with a corresponding decrease in likes, suggesting a significant fall in popularity.
- **Vlog Videos**: Display a consistent downward trend, with views and likes steadily decreasing each year, culminating in only 2.0 million views in 2024, reflecting decreased viewer interest.

#### Key Takeaways
While challenge videos are gaining traction, reaction videos and vlogs are witnessing a decline, indicating shifts in viewer preferences on YouTube. These insights can guide content strategies, suggesting a focus on challenge-themed content for potential growth.

### 4. Engagement Rate Analysis

#### Question
What is the engagement rate (likes/views ratio) for each keyword, and how does it vary?

#### Objective
Assess which types of videos not only attract views but also engage users to interact by liking. High engagement rates are crucial for channel growth.

#### Query
```sql
SELECT keyword, 
       SUM(view_count) AS total_views, 
       SUM(like_count) AS total_likes, 
       ROUND((SUM(like_count) * 100.0 / SUM(view_count)), 2) AS engagement_rate
FROM youtube_data
GROUP BY keyword
ORDER BY engagement_rate DESC;
```

#### Results

| Keyword   | Total Views  | Total Likes | Engagement Rate (%) |
|-----------|--------------|-------------|---------------------|
| Vlog      | 216,506,662  | 8,365,284   | 3.86                |
| Reaction  | 303,221,439  | 11,616,846.5| 3.83                |
| Challenge | 1,504,495,305| 30,455,610  | 2.02                |

#### Insights
- **Challenge Videos**: Although they have the highest total views (1,504,495,305) and likes (30,455,610), they exhibit the lowest engagement rate at 2.02%. This suggests that while challenge videos are extensively viewed, they generate relatively fewer likes per view.
- **Reaction Videos**: They attract a considerable number of views (303,221,439) and likes (11,616,846.5), achieving an engagement rate of 3.83%. This rate is slightly below that of vlogs, indicating moderate viewer interaction relative to their viewership.
- **Vlog Videos**: Despite having fewer total views (216,506,662) compared to reaction videos, vlogs have the highest engagement rate at 3.86%. This indicates that vlogs, while attracting fewer views, tend to engage viewers more effectively, leading to a higher proportion of likes per view.

#### Key Takeaways
Vlogs, though less viewed, engage their audience most effectively, suggesting a high quality of interaction. Challenges, while popular, could potentially increase their interactive engagement strategies to match their high viewership.

### 5. Seasonal Trends Analysis

#### Question
Is there a seasonal pattern in video views or likes for different keywords?

#### Objective
Identify any seasonal effects on video performance. This analysis can inform the best times to release certain types of content.

#### Query
```sql
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
```

#### Results

| Keyword   | Season | Total Views | Total Likes |
|-----------|--------|-------------|-------------|
| Challenge | Fall   | 251,831,762 | 4,712,911   |
| Challenge | Spring | 618,385,992 | 12,762,597  |
| Challenge | Summer | 75,362,433  | 1,046,026   |
| Challenge | Winter | 558,915,118 | 11,934,076  |
| Reaction  | Fall   | 63,778,234  | 1,854,092.5 |
| Reaction  | Spring | 145,133,479 | 3,973,115   |
| Reaction  | Summer | 79,848,350  | 5,082,396   |
| Reaction  | Winter | 14,461,376  | 707,243     |
| Vlog      | Fall   | 63,768,384  | 4,243,748   |
| Vlog      | Spring | 29,794,939  | 1,083,255   |
| Vlog      | Summer | 120,290,398 | 2,877,668   |
| Vlog      | Winter | 2,652,941   | 160,613     |

#### Insights
- **Challenge Videos**: Show the highest engagement during Spring with approximately 618 million views and 12.8 million likes. Winter also sees high engagement, closely following Spring. Fall and Summer have lower engagement, with Summer being the least engaged.
- **Reaction Videos**: Peak during Summer with about 80 million views and 5.1 million likes. Spring follows with strong engagement, whereas Fall and Winter see less interaction.
- **Vlog Videos**: Summer is the top season, with the highest views (120 million) and likes (2.88 million). Fall also shows strong engagement. Spring and Winter experience less engagement, with Winter having the lowest.

#### Key Takeaways
- **Challenge Videos**: Perform best in Spring and Winter, suggesting seasonal planning around these times could maximize viewer engagement.
- **Reaction Videos**: Peak in Summer, which may be due to increased leisure time allowing viewers to engage more with entertainment content.
- **Vlog Videos**: Show significant interaction in Summer, indicating that seasonal activities and travels could boost viewer interest in lifestyle content during this time.

## Summary and Conclusion

This analysis has provided valuable insights into how different factors like keyword choice, title length, and seasonality impact the success of YouTube videos.

### Key Findings and Recommendations

- **Keyword Strategy**:
  - **Challenge Videos**: Are the most popular, drawing an immense number of views and likes. Content creators should focus on crafting compelling challenges, particularly during the Spring and Winter when engagement peaks.
  - **Reaction and Vlog Content**: While less popular than challenges, these categories also show substantial engagement. Reaction videos perform best in Summer, suggesting a strategic release during this season could maximize visibility.

- **Title Length**:
  - Videos with short titles (12-40 characters) perform best, indicating that concise titles may enhance the click-through rate. Content creators should aim to create short, intriguing titles to attract more views.

- **Seasonal Trends**:
  - Seasonality plays a crucial role in content engagement. For challenge videos, targeting Spring and Winter releases may yield the best results. Vlogs and reaction videos show heightened activity in Summer, aligning with periods when audiences might have more leisure time to engage with content.

- **Strategies for New Creators**:
  - Consider launching content that aligns with proven successful themes like challenges during peak seasons.
  - Keep titles concise to boost click-through rates.
  - Leverage detailed data analytics to refine content strategies continually.

### Caveats and Future Improvements

- **Dataset Limitations**: The data covers only three keywords and might not represent all YouTube content. Future analyses could expand to more keywords and content types to better understand diverse audience preferences.
- **Analytical Limitations**: Current findings are based on averages and sums, which might overlook nuanced trends. Further statistical methods could provide more detailed insights.
- **Improvements**: Expanding the dataset to include more variables like comments or shares could enhance understanding of engagement. Continuously updating the data will also help keep strategies aligned with evolving viewer behaviors.

In essence, success on YouTube hinges on strategically timed, well-titled content that resonates with current viewer trends. For new creators, focusing on proven successful themes and optimal posting times could greatly enhance visibility and viewer engagement. As YouTube continues to evolve, so should the strategies for content creation, using ongoing analysis to adapt to the changing landscape.

