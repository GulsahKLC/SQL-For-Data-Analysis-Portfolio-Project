/*  pizza_project isimli bir database oluşturalım */ 
create database pizza_project;

use DOSYA
/* DOSYA adlı veritabanını aktif olarak kullanıyorsunuz.*/ 

select * from order_details;
select * from pizzas
select * from orders
select * from pizza_types


select count(distinct order_id) as 'Total Orders' from orders;

select order_details.pizza_id, order_details.quantity, pizzas.price
from order_details
join pizzas on pizzas.pizza_id = order_details.pizza_id


/* En yüksek pizza fiyatı ve kategorisi nedir? */
SELECT pt.category as kategori, p.price as fiyat
FROM pizzas p
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
ORDER BY p.price DESC

/* Sipariş edilen en yaygın pizza boyutu nedir ? */

SELECT 
    p.size AS boyutu,
    COUNT(*) AS sipariş_sayısı
FROM 
    pizzas p
GROUP BY 
    p.size
ORDER BY 
    sipariş_sayısı DESC

/* answ:
S	32
L	31
M	31
XL	1
XXL	1
*/

/* en çok hangi tür ingredients tercih edilmiştir? */
SELECT 
    pt.ingredients AS içindekiler,
    COUNT(p.pizza_id) AS tercih_sayısı
FROM 
    pizza_types pt 
JOIN 
    pizzas p ON pt.pizza_type_id = p.pizza_type_id  
GROUP BY 
    pt.ingredients
ORDER BY 
    tercih_sayısı DESC;  

/*  
en çok 
Kalamata Olives, Feta Cheese, Tomatoes, Garlic, Beef Chuck Roast, Red Onions	5
tür ingredients tercih edilmiştir
*/ 


/* Sipariş edilen her pizza kategorisinin toplam miktarı nedir? */
select top 5 pizza_types.category, sum(quantity) as 'Total Quantity Ordered'
from order_details
join pizzas on pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.category 
order by sum(quantity)  desc

/* Günün saatine göre siparişlerin dağılımını belirleyin.*/

select 
datepart(hour, time) as 'Hour of the day',
count(distinct order_id) as 'orders'
from orders
group by datepart(hour, time) 
order by [orders] desc


/* Her pizza türünün toplam gelire olan yüzdesel katkısını hesaplayın*/

select pizza_types.category, 
concat(cast((sum(order_details.quantity*pizzas.price) /
(select sum(order_details.quantity*pizzas.price) 
from order_details 
join pizzas on pizzas.pizza_id = order_details.pizza_id 
))*100 as decimal(10,2)), '%')
as 'Revenue contribution from pizza'
from order_details 
join pizzas on pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.category


/* Pizza adıyla her pizzadan elde edilen gelir katkısı % lik */
select pizza_types.name, 
concat(cast((sum(order_details.quantity*pizzas.price) /
(select sum(order_details.quantity*pizzas.price) 
from order_details 
join pizzas on pizzas.pizza_id = order_details.pizza_id 
))*100 as decimal(10,2)), '%')
as 'Revenue contribution from pizza'
from order_details 
join pizzas on pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.name
order by [Revenue contribution from pizza] desc


/* Zamanla oluşturulan toplam geliri analiz edin.
 Toplam değeri elde etmek için kümülatif toplama pencere fonksiyonu kullanın.*/
with cte as (
select date as 'Date', cast(sum(quantity*price) as decimal(10,2)) as Revenue
from order_details 
join orders on order_details.order_id = orders.order_id
join pizzas on pizzas.pizza_id = order_details.pizza_id
group by date
-- order by [Revenue] desc
)
select Date, Revenue, sum(Revenue) over (order by date) as 'Cumulative Sum'
from cte 
group by date, Revenue

/* Her pizza kategorisi için gelire göre en çok sipariş edilen ilk 3 pizza türünü belirleyin.*/
with cte as (
select category, name, cast(sum(quantity*price) as decimal(10,2)) as Revenue
from order_details 
join pizzas on pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by category, name

)
, cte1 as (
select category, name, Revenue,
rank() over (partition by category order by Revenue desc) as rnk
from cte 
)
select category, name, Revenue
from cte1 
where rnk in (1,2,3)
order by category, name, Revenue
