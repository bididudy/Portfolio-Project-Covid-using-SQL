-- 1. Create an ER diagram or draw a schema for the given database.
-- Ans. ER Diagram file is added to zip file

-- 2.We want to reward the user who has been around the longest, Find the 5 oldest users. 
-- Answer - from the year created_at colum this answer is derived. 
--          answering table is in descending order and only first five id's are kept
SELECT year(created_at), id, username 
FROM users
order by created_at limit 5;


-- 3.To understand when to run the ad campaign, figure out the day of the week most users register on?
-- Answer - In this query there are two parts. In one part we calculated date of the id creation and in second part those days counted. 
--          From the calculation Sunday and Thursday are the days on which max id's are generated. 
with campaign as 
(select dayname(created_at) day_name, id, username FROM users)

select count(day_name), day_name from campaign group by day_name order by count(day_name) desc;

-- 4. To target inactive users in an email ad campaign, find the users who have never posted a photo.
-- Answer - Here I found problem in data set as user id of user named as 'id' in users table whereas it's named 'user_id' in other table.
--          it's confusing for work bench so this query can't be solved until changes are done in mentioned tables. 

ALTER TABLE users
RENAME COLUMN id to user_id; -- column name in users table has been changed.

-- Here left join is used because we need all the records from left table which is users but need only common from right table which is photos. 
SELECT users.user_id, username
FROM users
LEFT JOIN photos 
ON users.user_id = photos.user_id
WHERE photos.user_id IS NULL
order by users.user_id asc;

-- 5. Suppose you are running a contest to find out who got the most likes on a photo. Find out who won?
-- Answer - Here I found problem in data set as photo id of photos named as 'id' in photos table whereas it's named 'photo_id' in other tables.
--          it's confusing for work bench so this query can't be solved until changes are done in mentioned tables.
ALTER TABLE photos
RENAME COLUMN id to photo_id; -- column name in photos table has been changed.

-- here we found number of likes to each photo and selected photo id which got most likes.
with most_likes as
(SELECT count(photo_id) like_number, photo_id 
FROM ig_clone.likes 
group by photo_id 
order by count(photo_id) desc limit 1)

-- from above cte we got photo id and from photo id we derived used id and username from users table
select u.user_id, u.username, m.photo_id, m.like_number
from most_likes m
join photos p
on m.photo_id=p.photo_id
join users u
on p.user_id=u.user_id;

-- 6.The investors want to know how many times does the average user post.
-- first we counted number of posts every user has done
with average_post
as
(SELECT count(user_id) post_count, user_id 
FROM photos 
group by user_id)

-- then we calculted average from above cte
select avg(post_count) avg_ from average_post;

-- 7.A brand wants to know which hashtag to use on a post, and find the top 5 most used hashtags.
-- Answer: Here I found problem in data set as tag id of photos named as 'id' in tags table whereas it's named 'tag_id' in other tables.
--         it's confusing for work bench so this query can't be solved until changes are done in mentioned tables.
ALTER TABLE tags
RENAME COLUMN id to tag_id; -- column name in photos table has been changed.

-- Here we have to count top 5 hashtags mostly used meaans we need the count of every hashtags whenever it's been used.
select count(p.tag_id) tag_count, p.tag_id, t.tag_name
from tags t
join photo_tags p
on t.tag_id=p.tag_id
group by p.tag_id
order by count(p.tag_id) desc limit 5;

-- 8. To find out if there are bots, find users who have liked every single photo on the site.
create view bot1 
as 
SELECT count(user_id) final_likes, user_id 
FROM ig_clone.likes 
group by user_id 
order by count(user_id) desc;

select u.user_id, b.final_likes
from bot1 b
join likes l
on b.user_id = l.user_id
join photos p
on l.photo_id = p.photo_id
join users u
on b.user_id=u.user_id
where b.final_likes = '257'
group by u.user_id;

-- 9. To know who the celebrities are, find users who have never commented on a photo.
create view celebrity
as
select user_id
from comments 
group by user_id;

SELECT u.user_id, u.username
FROM users u
LEFT JOIN celebrity c
ON u.user_id=c.user_id
WHERE c.user_id IS NULL
order by u.user_id asc;

-- 10. Now it's time to find both of them together, find the users who have never commented on any photo or have commented on every photo.

create view final1
as
select u.user_id, u.username
from bot1 b
join likes l
on b.user_id = l.user_id
join photos p
on l.photo_id = p.photo_id
join users u
on b.user_id=u.user_id
where b.final_likes = '257'
group by u.user_id;

create view final2
as
SELECT users.user_id, users.username
FROM users 
LEFT JOIN celebrity c
ON users.user_id=c.user_id
WHERE c.user_id IS NULL
order by users.user_id asc;

select * 
from final1
union
select *
from final2




