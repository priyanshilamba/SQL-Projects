# Instagram Clone Database




## OVERVIEW
This project contains the SQL script (Instagram_clone.sql) necessary for setting up a comprehensive database schema for an Instagram-like social media platform. The schema includes all the essential tables and relationships required to support users, posts, comments, likes, followers, messaging, and notifications, enabling a fully functional social media experience.
## FILE DESCRIPTION
1. Filename: Instagram_clone.sql

2. Purpose: Defines the entire relational database schema and its relationships to simulate core Instagram features.

3. Format: SQL script, compatible with MySQL, PostgreSQL, and other relational database management systems.

4. Contents: Table creation statements, primary and foreign key constraints, and sample data insertion commands.
## DATABASE SCHEMA BREAKDOWN
The database schema consists of multiple tables, each playing a vital role in the functionality of the platform:
1. Users Table

Stores user information, including:

id (Primary Key)

username (Unique Identifier)

email

password_hash

profile_picture

bio

created_at

2. Posts Table

Manages user-generated content:

id (Primary Key)

user_id (Foreign Key referencing Users)

caption

image_url

created_at

updated_at

3️. Comments Table

Stores comments on posts:

id (Primary Key)

post_id (Foreign Key referencing Posts)

user_id (Foreign Key referencing Users)

content

created_at

4️. Likes Table

Tracks likes on posts:

id (Primary Key)

post_id (Foreign Key referencing Posts)

user_id (Foreign Key referencing Users)

created_at

5️. Followers Table

Stores user relationships (followers/following):

id (Primary Key)

follower_id (User who follows)

followed_id (User being followed)

created_at

6️. Messages Table

Enables direct messaging between users:

id (Primary Key)

sender_id (Foreign Key referencing Users)

receiver_id (Foreign Key referencing Users)

content

created_at

is_read (Boolean to track read status)

7️. Notifications Table

Handles user notifications:

id (Primary Key)

user_id (Foreign Key referencing Users)

message

is_read

created_at
## INSTALLATION AND SETUP
To set up the database, follow these steps:

1️⃣ Ensure you have a MySQL or PostgreSQL database server installed.
2️⃣ Open a SQL client such as MySQL Workbench, pgAdmin, or a command-line SQL interface.
3️⃣ Run the SQL script to create the necessary tables and relationships:
SOURCE path/to/Instagram_clone.sql;
4️⃣ Verify the tables were created successfully using:
SHOW TABLES;
5️⃣ Insert sample data if needed and test queries to ensure correct functionality.
## FUTURE ENHANCEMENTS
1. To improve efficiency and functionality, consider implementing:

2. Stored Procedures: Automate repetitive database tasks.

3. Indexes: Improve query performance on frequently accessed tables.

4. Stories & Reels: Extend post functionality to include expiring content.

5. Hashtags & Explore Page: Implement a searchable tagging system.
## LICENSE
This project is open-source and free to use and modify. Contributions are welcome!
## AUTHOR
Developed by Priyanshi Lamba. Feel free to reach out for suggestions, contributions, or collaborations!
