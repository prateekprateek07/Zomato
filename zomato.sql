use zomato;
-- 1.what is total amount each customer spent on zomato?

select s.userid, sum(p.price) as price  from product p join sales s on p.product_id = s.product_id
group by 1
order by 2 desc;

-- 2.How many days has each customer visited zomato?

select userid, count(distinct(created_date)) from sales 
group by 1;

-- 3.what was the first product purchased by each customer?

with mycte as ( select s.userid,p.product_name, row_number() over (partition by userid order by created_date asc) as first_product
from sales s join product p on s.product_id = p.product_id)
select * from mycte where first_product = 1;

-- 4.what is most purchased item on menu & how many times was it purchased by all customers ?

with mycte as (select *, row_number() over (partition by product_id order by product_id asc) as numm
from sales)
select product_id, count(numm) as count from mycte 
group by 1
order by 2 desc
limit 1;

-- or 
select userid, count(product_id) as count,product_id from sales where product_id = 
(select product_id from sales group by product_id order by count(product_id) desc limit 1)
group by 1,3;



-- 5.which item was most popular for each customer?

select * from
(select userid, product_id, countt, row_number() over (partition by userid order by countt desc) as roww from
(select *, count(product_id) over (partition by userid,product_id) as countt from sales) as t) as g
where roww = 1;

-- or 

with mycte as (select userid, product_id, countt, row_number() over (partition by userid order by countt desc) as roww from
(select *, count(product_id) over (partition by userid,product_id) as countt from sales) as t)
select * from mycte where roww = 1;


-- which item was purchased first by customer after they become a member

with mycte as (select s.userid,s.created_date, s.product_id,row_number() over(partition by s.userid order by s.created_date) as numm
 from users u join sales s on u.userid = s.userid and u.signup_date <= s.created_date)
 select * from mycte where numm = 1;
 
 -- which item was purchased just before the customer became a member?
 
 with mycte as (select s.userid, s.created_date,s.product_id, row_number() over (partition by s.userid order by s.created_date desc) as numm 
 from sales s join users u on u.userid = s.userid and s.created_date <= u.signup_date)
 select * from mycte where numm = 1;
 
 -- what is total orders and amount spent for each member after they become a member?
 
 
 with mycte as (select s.userid as userid, p.price as price, count(s.product_id) over (partition by s.userid) as countt from product p join 
 sales s on p.product_id = s.product_id 
 join users u on s.userid = u.userid 
 and s.created_date >= u.signup_date)
 select userid, concat(sum(price)," ","rs") as total_amount,countt from mycte
 group by 3,1;
 
 -- If buying each product generates points for eg 5rs=2 zomato point 
 -- and each product has different purchasing points for eg for p1 5rs=1 zomato point,for p2 10rs= 1 zomato
 -- point and p3 5rs=1 zomato point  2rs = 1zomato point, 1.calculate points collected by each customer and 2.for
 -- which product most points have been given till now. p1 5rs = 1, p2 10rs = 1 zp, p3 5rs = 1.
 
 select s.userid,
 sum(case 
  when s.product_id = 1 then (((p.price/5) * 1) *2.5)
  when s.product_id = 2 then (((p.price/2) *1) * 2.5)
  when s.product_id = 3 then (((p.price/5)*1) * 2.5)
  else "nil"
end) as points
  from sales s join product p on s.product_id = p.product_id
group by 1;

 
 -- for
 -- which product most points have been given till now
 
 select p.product_id,
 sum(case 
  when s.product_id = 1 then ((p.price/5) * 1) 
  when s.product_id = 2 then ((p.price/2) *1) 
  when s.product_id = 3 then ((p.price/5)*1) 
  else "nil"
end) as points
  from sales s join product p on s.product_id = p.product_id
group by 1
order by points desc
limit 1;
 
 
 -- In the first year after a customer joins the gold program (including the join date ) irrespective of what customer has purchased 
 -- earn 5 zomato points for every 10rs spent who earned more more 1 or 3 what int earning in first yr ? 1zp = 2rs
 
 
 with mycte as (select s.userid as userid, s.product_id as product_id, p.price as price , g.gold_signup_date as gold,
 s.created_date as created,
 case 
  when s.product_id = 1 or 2 or 3 then ((p.price/2))
  else 0
end as zomato_point
 from goldusers_signup g join sales s on g.userid = s.userid join product p on s.product_id = p.product_id
 where s.created_date >= g.gold_signup_date and s.created_date <= date_add(g.gold_signup_date, interval 1 year))
 select  userid, sum(zomato_point) as zomato_point from mycte
 group by 1
 order by 2 desc
 limit 1;
 
 -- rnk all transaction of the customers
 
 select userid, product_id, dense_rank() over (partition by userid) as dense_ranks, 
 row_number() over (partition by userid) as  row_numbers, rank() over ( partition by userid) as rankk from sales;
 
 -- rank all transaction for each member whenever they are zomato gold member for every non gold member transaction mark as na
 
 select *, 
case 
  when g.gold_signup_date is null then 'na' 
  else (row_number() over (partition by g.userid) ) 
end  as rnk
 from  sales s left join goldusers_signup g on g.userid = s.userid and s.created_date >= g.gold_signup_date;
 
 
 
 
 

 
 
 
 
 
 
 
 
 
 
 
 
 
 

