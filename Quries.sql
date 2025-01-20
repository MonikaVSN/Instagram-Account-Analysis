/*1. How many unique post types are found in the 'fact_content' table? */
select distinct post_type
from fact_content

  
/*2. What are the highest and lowest recorded impressions for each post type? */
select post_type,
	    max(impressions) as highest_impressions,
      min(impressions) as lowest_impressions
from fact_content
group by post_type;


/*3.Filter all the posts that were published on a weekend in the month of March and April and export them to a separate csv file.*/
select f.*
from fact_content f
join dim_dates d using(date)
where month_name in("March","April") and weekday_or_weekend="Weekend"


/*4Create a report to get the statistics for the account. The final output includes the following fields: 
• month_name • total_profile_visits • total_new_followers*/
select  monthname(date) as month_name,
		sum(profile_visits) as total_profile_visits,
		sum(new_followers) as total_new_followers
from fact_account
group by month_name


/*5 Write a CTE that calculates the total number of 'likes’ for each 'post_category' during the month of 'July' and subsequently, arrange the 
'post_category' values in descending order according to their total likes. */
with cte as 
   (select post_category,
		    sum(likes) as total_likes
   from fact_content
   where monthname(date) ='July'
   group by post_category)

select * from cte
order by total_likes desc


/*6.Create a report that displays the unique post_category names alongside their respective counts for each month. 
The output should have month_name • post_category_names  • post_category_count*/
select  monthname(date) as month_name,
		    group_concat(distinct post_category separator ' , ')   as post_category_names,
        count(distinct post_category) as post_category_count
from fact_content
group by  month_name
order by month(date)


/*7.What is the percentage breakdown of total reach by post type?  The final output includes the following fields: • post_type • total_reach • reach_percentage */
select  post_type,
		    sum(reach) as total_reach,
        round((sum(reach)/(select sum(reach) from fact_content))*100,2) as reach_percentage
from fact_content
group by post_type
order by reach_percentage desc;



/*8.Create a report that includes the quarter, total comments, and total saves recorded for each post category. Assign the following quarter groupings: 
(January, February, March) → “Q1” (April, May, June) → “Q2” (July, August, September) → “Q3” 
The final output columns should consist of: • post_category • quarter • total_comments • total_saves */
select  post_category,
		case
			when monthname(date) in("January", "February", "March") then "Q1"
            when monthname(date) in("April", "May", "June") then "Q2"
            when monthname(date) in("July", "August", "September") then "Q3"
        end as quarter,
        sum(comments) as total_comments,
        sum(saves) as total_saves
from fact_content
group by post_category,quarter



/*9. List the top three dates in each month with the highest number of new followers. The final output should include the following columns: 
• month • date • new_followers */
with cte as 
   (select  monthname(date) as month,
		    date,
         row_number() over (partition by monthname(date) order by new_followers desc) as rank_new_followers,
         new_followers
    from fact_account)
select month,
       date,
       new_followers
from cte
where rank_new_followers<=3
order by month(date)



/*10.Create a stored procedure that takes the 'Week_no' as input and generates a report displaying the total shares for each 'Post_type'. The 
output of the procedure should consist of two columns: • post_type • total_shares*/
CREATE DEFINER=`root`@`localhost` PROCEDURE `weekly_shares_for_each_post_type`(IN week_no varchar(255))
BEGIN
select  post_type,
        sum(shares) as total_shares
from fact_content f
join dim_dates d using(date)
where d.week_no = week_no
group by post_type, week_no
order by total_shares desc;
END
