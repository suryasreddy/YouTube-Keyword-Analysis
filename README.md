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

#### Query Result

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
