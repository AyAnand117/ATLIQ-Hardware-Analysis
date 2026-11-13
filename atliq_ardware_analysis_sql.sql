SELECT * FROM gdb0041.fact_sales_monthly
where customer_code = 90002002
and year(date) = 2021
order by date desc;

-- 09-2020 -> 01-2021 

select date_add("2020-09-01", interval 4 month);


select * from fact_sales_monthly
where customer_code = 90002002
and year(date_add(date, interval 4 month)) = 2021
order by date desc;

-- Deterministic means that o/p will always be the same for a given i/p
-- Not Deterministic means that o/p will differ depending upon the time of execution even with the same i/p

-- What if the business manager comes and says I want a report for fiscal year = 2021 and Quarter 4
/*
9,10,11 -- Q1
12,1,2 -- Q2
3,4,5 -- Q3
6,7,8 -- Q4
*/
select * from fact_sales_monthly
where customer_code = 90002002
and get_fiscal_year(date) = 2021
and month(date) in (6,7,8)
order by date desc;

select * from fact_sales_monthly
where customer_code = 90002002
and get_fiscal_year(date) = 2021
and get_fiscal_quarter(date) = "Q4"
order by date desc;

select s.date, s.product_code, p.product, p.variant, s.sold_quantity 
from fact_sales_monthly s
join dim_product p 
on p.product_code = s.product_code
where customer_code = 90002002
and get_fiscal_year(date) = 2021
and get_fiscal_quarter(date) = "Q4"
order by date desc;



select s.date, s.product_code, p.product, p.variant, s.sold_quantity , g.gross_price
from fact_sales_monthly s
join dim_product p 
on p.product_code = s.product_code
join fact_gross_price g
on g.product_code = s.product_code 
and g.fiscal_year = get_fiscal_year(s.date)
where customer_code = 90002002
and get_fiscal_year(date) = 2021
and get_fiscal_quarter(date) = "Q4"
order by date desc;



select s.date, s.product_code, p.product, p.variant, s.sold_quantity , g.gross_price, 
g.gross_price*s.sold_quantity as gross_price_total
from fact_sales_monthly s
join dim_product p 
on p.product_code = s.product_code
join fact_gross_price g
on g.product_code = s.product_code 
and g.fiscal_year = get_fiscal_year(s.date)
where customer_code = 90002002
and get_fiscal_year(date) = 2021
and get_fiscal_quarter(date) = "Q4"
order by date asc;

-- Aggregate monthly gross sales report for croma india customer with 2 fields month and total gross sales amount to croma india in this month

select s.date, sum(g.gross_price*s.sold_quantity) as gross_price_total
from fact_sales_monthly s
join fact_gross_price g
on g.product_code = s.product_code and g.fiscal_year = get_fiscal_year(s.date)
where customer_code = 90002002
group by s.date
order by s.date asc;

/*
Generate a yearly report for Croma India where there are two columns
1. Fiscal Year
2. Total Gross Sales amount In that year from Croma
*/
select get_fiscal_year(s.date) as years, sum(g.gross_price*s.sold_quantity) as gross_price_total
from fact_sales_monthly s
join fact_gross_price g
on g.product_code = s.product_code and g.fiscal_year = get_fiscal_year(s.date)
where customer_code = 90002002
group by years
order by years asc; 

/*
Create stored procedure that can determine the market badge based on :
tot_sold_qty > 5mil Gold, else Silver
i/p Market and fiscal_year
o/p market badge
*/
select sum(s.sold_quantity) as tot_sold_qty , c.market
from fact_sales_monthly s 
join dim_customer c
on c.customer_code = s.customer_code
where get_fiscal_year(s.date)=2021 and c.market ="India"
group by c.market
order by tot_sold_qty desc
; 


-- STORED PROCEDURE BENEFITS
-- Convenience
-- Security , limited access to users , prevents accidental data corruption 
-- Maintainability
-- Performance
-- Developer Productivity

-- -------------------------------------------------------- --
-- explain analyze
select s.date, s.product_code, p.product, p.variant, s.sold_quantity , g.gross_price, 
g.gross_price*s.sold_quantity as gross_price_total, pre.pre_invoice_discount_pct
from fact_sales_monthly s
join dim_product p 
on p.product_code = s.product_code
join fact_gross_price g
on g.product_code = s.product_code 
and g.fiscal_year = get_fiscal_year(s.date)
join fact_pre_invoice_deductions pre
on pre.customer_code = s.customer_code
and pre.fiscal_year = get_fiscal_year(s.date)
where s.customer_code = 90002002
and get_fiscal_year(date) = 2021
and get_fiscal_quarter(date) = "Q4"
order by date asc;
-- ----------------------------------------------------------- --
-- explain analyze
select s.date, s.product_code, p.product, p.variant, s.sold_quantity , g.gross_price, 
g.gross_price*s.sold_quantity as gross_price_total, pre.pre_invoice_discount_pct
from fact_sales_monthly s
join dim_product p 
on p.product_code = s.product_code
join fact_gross_price g
on g.product_code = s.product_code 
join dim_date dt
on dt.calendar_date = s.date
join fact_pre_invoice_deductions pre
on pre.customer_code = s.customer_code
and pre.fiscal_year = dt.fiscal_year
where s.customer_code = 90002002
and get_fiscal_year(date) = 2021
and get_fiscal_quarter(date) = "Q4"
order by date asc;

-- ---------------------------------------------------------- --
explain analyze
select s.date, s.product_code, p.product, p.variant, s.sold_quantity , g.gross_price, 
g.gross_price*s.sold_quantity as gross_price_total, pre.pre_invoice_discount_pct
from fact_sales_monthly s
join dim_product p 
on p.product_code = s.product_code
join fact_gross_price g
on g.product_code = s.product_code 
join fact_pre_invoice_deductions pre
on pre.customer_code = s.customer_code
and pre.fiscal_year = s.fiscal_year
where s.customer_code = 90002002
and get_fiscal_year(date) = 2021
and get_fiscal_quarter(date) = "Q4"
order by date asc;

# Net Invoice Sales
with cte1 as (select s.date, s.product_code, p.product, p.variant, s.sold_quantity , g.gross_price, 
g.gross_price*s.sold_quantity as gross_price_total, pre.pre_invoice_discount_pct
from fact_sales_monthly s
join dim_product p 
on p.product_code = s.product_code
join fact_gross_price g
on g.product_code = s.product_code 
join fact_pre_invoice_deductions pre
on pre.customer_code = s.customer_code
and pre.fiscal_year = s.fiscal_year
where s.customer_code = 90002002
and get_fiscal_year(date) = 2021
and get_fiscal_quarter(date) = "Q4"
order by date asc)
select * , (cte1.gross_price_total - cte1.gross_price_total*cte1.pre_invoice_discount_pct) as net_invoice_sales from cte1;

-- Created a view for pre-invoice discounts
select * , (gross_price_total - gross_price_total*pre_invoice_discount_pct) as net_invoice_sales, 
(discounts_pct + other_deductions_pct) as post_invoice_discount_pct
from sales_preinv_discount;

/*
JOIN `fact_post_invoice_deductions` `po` ON (((`s`.`date` = `po`.`date`)
            AND (`s`.`customer_code` = `po`.`customer_code`)
            AND (`s`.`product_code` = `po`.`product_code`)))
            
`po`.`discounts_pct` AS `discounts_pct`,
        `po`.`other_deductions_pct` AS `other_deductions_pct`
*/
/*
select *, (1-pre_invoice_discount_pct)*gross_price_total as net_invoice_sales, (po.discounts_pct + po.other_deductions_pct) as post_invoice_discount_pct
from sales_preinv_discount s
join fact_post_invoice_deductions po 
on s.date = po.date
and s.product_code = po.product_code
and s.customer_code = po.customer_code;
*/

select *, (1-post_invoice_discount_pct)*net_invoice_sales as net_sales
from gdb0041.sales_postinv_discounts_new;

select * from sales_postinv_discounts_new;

SELECT * FROM gdb0041.net_sales;

/*
SELECT s.date, s.fiscal_year, s.customer_code, 
c.customer_code, c.market, s.product_code, p.product,
p.variant, s.sold_quantity, g.gross_price as gross_price_per_item,
round(s.sold_quantity*g.gross_price,2) as gross_price_total
from fact_sales_monthly s
join dim_product p
on s.product_code = p.product_code
join dim_customer c
on s.customer_code = c.customer_code
join fact_gross_price g
on g.fiscal_year = s.fiscal_year
and g.product_code = s.product_code;
*/

select * from gross_sales;

-- Which are my top markets by net sales?

select c.customer
, round(sum(net_sales)/1000000,2) as net_sales_mln from net_sales ns
join dim_customer c
on ns.customer_code = c.customer_code
where fiscal_year = 2021
group by c.customer
order by net_sales_mln
limit 5;























