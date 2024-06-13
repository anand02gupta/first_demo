---Q.1: Who is the senior most employee based on job title?
	
select * from employee
order by levels desc
limit 1;

--Q.2: Which countries have the most invoices?

select count(*) as c , billing_country
from invoice
group by billing_country
order by c desc
limit 1;

--Q.3: What are top 3 values of total invoice?

select total from invoice
order by total desc
limit 3;

--Q.4: Which city has the best custmors? We would like to throw a Promotional Music Fastival in 
--the city we made the most money.Write a query that returns one city that has the highest sum of 
--invoice totals. Return both the city name and sum of all invoice totals.
select billing_city, sum(total) as total
from invoice
group by billing_city
order by total desc
limit 1;

--Q.5: Who is the best custmer? The custmer who has spent the most money will be declared the 
--best custmer. Write a query that returns the person who has spent the most money.

select customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) as total
from customer
join invoice on customer.customer_id = invoice.customer_id
group by customer.customer_id
order by total desc
limit 1;

--Q.6:Write query to return the mail, first name, last name, & Genre of all Rock Music
--listerners. Return your list orderd alphabetically by email starting with A.

select distinct email, first_name, last_name
from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id in(
	select track_id from track
	join genre on track.genre_id = genre.genre_id
	where genre.name like 'Rock')
order by email;

--Q.7: Let's invite the artists who have written the most rock music in our dataset. Write a 
--query that returns the artist name and total track count of the top 10 rock bands.
select artist.artist_id, artist.name, count(artist.artist_id) as number_of_songs
from track
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id
join genre on genre.genre_id = track.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by number_of_songs desc
limit 10;

--Q.8: Return all the track names that have a song length longer than the average song length.
--Return the name and Milliseconds for each track. Order by the song length with the longest song listed first.

select name, milliseconds 
from track 
where milliseconds >(
	select avg(milliseconds) from track)
order by milliseconds desc;

--Q.9: Find how much amount spent by each customer on artists? Write a query to return customer 
--name, artist name and total spent.

with best_selling_artist as(
    select artist.artist_id as artist_id, artist.name as artist_name, sum(invoice_line.quantity * invoice_line.unit_price) as total_sales
    from invoice_line
    join track on track.track_id = invoice_line.track_id
    join album on track.album_id = album.album_id
    join artist on artist.artist_id  = album.artist_id
    group by 1
    order by total_sales desc
	limit 1
)
select customer.customer_id, customer.first_name, customer.last_name, bsa.artist_name, 
sum(invoice_line.quantity * invoice_line.unit_price) as amouont_spent
from invoice 
join customer on customer.customer_id = invoice.customer_id
join invoice_line on invoice_line.invoice_id = invoice.invoice_id
join track on track.track_id = invoice_line.track_id
join album on album.album_id = track.album_id
join best_selling_artist bsa on bsa.artist_id = album.artist_id
group by 1,2,3,4
order by 5 desc;

--Q.10: We want to find out most popular music Genre for each country. We determine the most 
--popular genre as the genre with the highest amount of purchases. Write a query that returns 
--each country along with the top Genre. For countries where the maximum number of purchases 
--is shared return all Genre.

with popular_genre as(
	select count(invoice_line.quantity) as purchases, customer.country, genre.name, genre.genre_id,
	row_number() Over(partition by customer.country order by count(invoice_line.invoice_id) desc) as row_no
	from invoice_line
	join invoice on invoice.invoice_id = invoice_line.invoice_id
	join customer on customer.customer_id = invoice.customer_id
	join track on track.track_id = invoice_line.track_id

	join genre on genre.genre_id = track.genre_id
	group by 2,3,4
	order by 2 asc, 1 desc
)
select * from popular_genre where row_no <= 1;

--Q.11: Write a query that determines the customer that has spent the most on music for each 
--country. Write a query that returns the country along with the top customer and how much 
--they spent. For countries where the top amount spent is shared, provide all customers who 
--spent this amoount.

--By recussive method--
with recursive
    customer_with_country as (
	select customer.customer_id, first_name, last_name, billing_country, sum(total) as total_spending
	from invoice 
	join customer on customer.customer_id = invoice.customer_id
	group by 1,2,3,4
	order by 1,5 desc),
	
	country_max_spending as (
	select billing_country, max(total_spending) as max_spending
	from customer_with_country 
	group by billing_country)
	
select cc.billing_country, cc.total_spending, cc.first_name, cc.last_name
from customer_with_country cc
join country_max_spending ms
on cc.billing_country = ms.billing_country
where cc.total_spending = ms.max_spending
order by 1;

--By CTE method--
with customer_with_country as (
	select customer.customer_id, first_name, last_name, billing_country, sum(total) as total_spending,
    row_number() over(partition by billing_country order by sum(total) DESC) AS row_no
	from invoice
	join customer on customer.customer_id = invoice.customer_id
	group by 1,2,3,4
	order by 4 asc, 5 desc)
select * from customer_with_country where row_no <= 1;





