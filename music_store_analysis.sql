---Who is the senior most employee based on job title ?
select * from employee
order by levels desc
limit 1

---Which countries have the most invoices?
 select count(*) as total_invoices,billing_country from invoice
 group by billing_country 
 order by total_invoices desc

---What are the top 3 values of total invoice?
select total as top_values from invoice
order by 1 desc
limit 3

---Which city has the best customers? we would like to throw a promotional music festival in the city
---we made the money.Write a query that returns one city that has the highest sum of invoice totals.
---Returns both the city name & sum of all invoice totals

select billing_city as city_name, sum(total) as total from invoice
group by city_name
order by total desc
limit 1

--- who is the best customer? The customer who has spent the most money will be declared the best customer.
---Write a query that returns the person who has spent the most money

select customer.customer_id,customer.first_name,customer.last_name,sum(invoice.total) as total_spent
from customer
join invoice
on customer.customer_id= invoice.customer_id
group by customer.customer_id
order by total_spent desc
limit 1

 
---Write query to return the email,first name, last name, & Genre of all Rock Music listeners.
---Return your list ordered alphabetically by email starting with A

select distinct email,first_name,last_name
from customer as c
join invoice as i 
on c.customer_id=i.customer_id
join invoice_line as il
on i.invoice_id=il.invoice_id
where track_id in( 
                 select track_id from track
                   join genre
					on track.genre_id=genre.genre_id
					where genre.name like 'Rock' 
)
order by email

---Let's invite the artist who have written the most  rock music in our dataset.
---Write a query that returns the Artist name and total track count of the top  10 rock bands

select a.artist_id,a.name ,count(a.artist_id)from artist as a
join album as ab on a.artist_id= ab.artist_id
join track as t on ab.album_id=t.album_id
join genre as g on t.genre_id = g.genre_id
where g.name = 'Rock'
group by a.artist_id 
order by 3 desc   
limit 10

---Return  all the track names that have a  song length longer than the average song length.
---Return the Name and milliseconds for each track.
---Order by the song length with the longest songs listed first

select name , milliseconds from track
where milliseconds > (select avg(milliseconds) as average_track_length from track)
order by milliseconds desc

---Find how much amount spent by each customer on artists? 
---Write a  query to return customer name,artist name and total spent

with total_sell as (
     select artist.artist_id,artist.name, sum(invoice_line.unit_price*invoice_line.quantity) as total_sell
	 from invoice_line
	 join track on invoice_line.track_id=track.track_id
	 join album on track.album_id = album.album_id
	 join artist on album.artist_id =artist.artist_id
	 group by 1 
	 order by 3 desc
	 limit 1
)

select customer.customer_id,customer.first_name,customer.last_name,tls.name, sum(il.unit_price * il.quantity) as total_spent
from invoice as i
join customer  on customer.customer_id = i.customer_id
join invoice_line as il on i.invoice_id=il.invoice_Id
join track as tr on il.track_id= tr.track_id
join album as al on tr.album_id = al.album_id
join total_sell as tls on al.artist_id = tls.artist_id
group by 1,2,3,4
order by 5 desc

---We want to find out the most popular music genre for each country.
---We determine the most  popular genre as the  genre with the highest amount of puschases.
---Write a query that returns each country aling with the top Genre.
---For countries where the maximum number of purhchases is shared return all Genres.

with popular_genre as (
     select count(invoice_line.quantity) as purchases , customer.country, genre.name, genre.genre_id,
	 row_number() over (partition by customer.country order by count(invoice_line.quantity)desc) as row_num
	 from invoice_line 
	 join invoice on invoice_line.invoice_id=invoice.invoice_id
	 join customer on invoice.customer_id=customer.customer_id
	 join track on invoice_line.track_id= track.track_id
	 join genre on track.genre_id = genre.genre_id
	 group by 2,3,4
	 order by customer.country asc,1 desc
	 
)

select * from popular_genre 
where row_num  <= 1

---Write a query that determines the customer that has spent the most on music for each country.
---Write a query that returns the country 
---along with the top  customer  and how  much they spent.
---For countries where the top customer and how much they spent.For countries where 
---the top amount spent is shared , provide  all customers who spent this amount 
with total_spending as (
     select cs.customer_id,cs.first_name,cs.last_name,iv.billing_country,sum(iv.total) as total_spent
	 from invoice as iv
	 join customer as cs
	 on iv.customer_id = cs.customer_id
	 group by 1,2,3,4
	 order by 1, 5 desc
	 
), 
 
     country_max_spending as(
             select billing_country, max(total_spent)as max_spending
			 from total_spending
	         group by billing_country
			 )

select ts.customer_id,ts.first_name, ts.last_name, ts.billing_country,ts.total_spent
from total_spending as ts
join country_max_spending as cms
on ts.billing_country = cms.billing_country
where ts.total_spent = cms.max_spending
order by 4