/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
-- 2. How many days has each customer visited the restaurant?
-- 3. What was the first item from the menu purchased by each customer?
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
-- 5. Which item was the most popular for each customer?
-- 6. Which item was purchased first by the customer after they became a member?
-- 7. Which item was purchased just before the customer became a member?
-- 8. What is the total items and amount spent for each member before they became a member?
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
-- 11. Recreate the table with: customer_id, order_date, product_name, price, member (Y/N)
-- 12. Rank All The Things



Solution

select * from dannys_diner.sales;
select * from dannys_diner.menu;
select * from dannys_diner.members;

-- 1. What is the total amount each customer spent at the restaurant?

select s.customer_id "CUSTOMER",sum(m.price) "EXPENDITURE(IN DOLLARS)"
from dannys_diner.sales s
left join dannys_diner.menu m
on s.product_id = m.product_id
group by s.customer_id
order by s.customer_id;


-- 2. How many days has each customer visited the restaurant?

select customer_id "CUSTOMER", count(distinct order_date) "CUSTOMER VISIT"
from dannys_diner.sales
group by customer_id
order by customer_id;


-- 3. What was the first item from the menu purchased by each customer?

select x."CUSTOMER", x."DATE", x."PRODUCT" from
(select s.customer_id "CUSTOMER",s.order_date "DATE",m.product_name "PRODUCT", dense_rank() over(partition by customer_id order by order_date) "D_RANK"
from dannys_diner.sales s
left join dannys_diner.menu m 
on s.product_id=m.product_id) x
where x."D_RANK"=1
group by x."CUSTOMER",x."DATE",x."PRODUCT";


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

select product_name "PRODUCT", count (product_name) "ORDER COUNT"
from dannys_diner.sales s
left join dannys_diner.menu m
on s.product_id=m.product_id
group by product_name
limit 1;

select s.customer_id "CUSTOMER", m.product_name "PRODUCT", count(m.product_name) "ORDER COUNT"
from dannys_diner.sales s
left join dannys_diner.menu m
on s.product_id=m.product_id
where m.product_name='ramen'
group by s.customer_id,m.product_name
order by s.customer_id;


-- 5. Which item was the most popular for each customer?

select X."CUSTOMER", X."PRODUCT" from
(select s.customer_id "CUSTOMER", m.product_name "PRODUCT", dense_rank() over(partition by s.customer_id order by count(s.customer_id) desc) "D_RANK"
from dannys_diner.sales s
left join dannys_diner.menu m
on s.product_id=m.product_id
group by s.customer_id,m.product_name) x
where x."D_RANK"=1;


-- 6. Which item was purchased first by the customer after they became a member?

select * from (select s.customer_id "CUSTOMER",s.order_date "ORDER_DATE",mm.join_date "MEMBERSHIP_DATE",m.product_name "PRODUCT",dense_rank() over(partition by s.customer_id order by s.order_date)
from dannys_diner.sales s
inner join dannys_diner.menu m
on s.product_id=m.product_id
inner join dannys_diner.members mm
on mm.customer_id=s.customer_id
where s.order_date>=mm.join_date) x
where dense_rank=1;


-- 7. Which item was purchased just before the customer became a member?

select * from (select s.customer_id "CUSTOMER", s.order_date "ORDER_DATE", mm.join_date "MEMBERSHIP_DATE", m.product_name "PRODUCT", dense_rank()over(partition by s.customer_id order by s.order_date desc) "D_RANK"
from dannys_diner.sales s
join dannys_diner.menu m
on s.product_id=m.product_id
join dannys_diner.members mm
on s.customer_id=mm.customer_id
where s.order_date<mm.join_date) x
where x."D_RANK"=1;


-- 8. What is the total items and amount spent for each member before they became a member?

select s.customer_id "CUSTOMER",count(m.product_name) "TOTAL ITEM",sum(m.price) "AMOUNT SPENT (IN DOLLAR)"
from dannys_diner.sales s
join dannys_diner.menu m
on s.product_id=m.product_id
join dannys_diner.members mm
on s.customer_id=mm.customer_id
where s.order_date<mm.join_date
group by s.customer_id
order by s.customer_id;


-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

select x.customer_id "CUSTOMER",sum(x.points) "POINTS"
from
(select s.customer_id, case when s.product_id=1 then price*10*2 else price*10 end points
from dannys_diner.sales s
left join dannys_diner.menu m
on s.product_id=m.product_id) x
group by x.customer_id
order by x.customer_id;


-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

select y.customer_id "CUSTOMER",sum(y.points) "POINTS" 
from 
    (select x.*,
    case when x.product_id=1 then x.price*10*2
    when x.order_date between x.join_date and x.valid_date then x.price*10*2
    else x.price*10 end points
    from 
             (select s.customer_id,s.order_date,s.product_id,m.price,mm.join_date,(date_trunc('month',mm.join_date)+ interval '1 month -1 day')::date last_date, join_date+6 valid_date
            from dannys_diner.sales s
            left join dannys_diner.menu m
            on s.product_id=m.product_id
            join dannys_diner.members mm
            on s.customer_id=mm.customer_id) x
    where x.order_date<x.last_date) y
group by y.customer_id
order by y.customer_id;


-- 11. Recreate the table with: customer_id, order_date, product_name, price, member (Y/N)

select s.customer_id "CUSTOMER", s.order_date "ORDER DATE", m.product_name "PRODUCT", m.price "PRICE",case when join_date is null then 'N' else 'Y' end "MEMBER"
from dannys_diner.sales s
join dannys_diner.menu m
on s.product_id=m.product_id
left join dannys_diner.members mm
on mm.customer_id=s.customer_id;


-- 12. Rank All The Things

select *, case- when member = 'N' then NULL
 else rank() over(partition by customer_id, member order by order_date) end ranking
from (select s.customer_id, s.order_date, m.product_name, m.price,
  case
  when mm.join_date > s.order_date then 'N'
  when mm.join_date <= s.order_date then 'Y'
  else 'N' end member
 from dannys_diner.sales s
 left join dannys_diner.menu m
  on s.product_id = m.product_id
 left join dannys_diner.members mm
  on s.customer_id = mm.customer_id)rank_all; 
