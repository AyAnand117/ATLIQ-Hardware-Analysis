CREATE DEFINER=`root`@`localhost` PROCEDURE `get_monthly_gross_sales`(
in_customer_code text
)
BEGIN

select s.date, sum(g.gross_price*s.sold_quantity) as gross_price_total
from fact_sales_monthly s
join fact_gross_price g
on g.product_code = s.product_code and g.fiscal_year = get_fiscal_year(s.date)
where find_in_set(customer_code , in_customer_code)>0
group by s.date;

END