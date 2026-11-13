CREATE DEFINER=`root`@`localhost` PROCEDURE `get_market_badge`(
in in_market varchar(45),
in in_fiscal_year year,
out out_badge varchar(45)
)
BEGIN
declare tot_sold_qty int default 0;
# Set default market to India
if in_market ="" then 
set in_market ="India";
end if;

# retrieve total qty for a given market+fyear
select  sum(s.sold_quantity) into tot_sold_qty 
from fact_sales_monthly s 
join dim_customer c
on c.customer_code = s.customer_code
where get_fiscal_year(s.date)= in_fiscal_year and c.market = in_market
group by c.market
;

# determine market badge
if tot_sold_qty > 5000000 then set out_badge = "GOLD";
else set out_badge = "SILVER";
end if ;
END