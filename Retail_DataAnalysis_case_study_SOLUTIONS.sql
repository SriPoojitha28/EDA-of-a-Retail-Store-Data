/*						
					For the current "RETAIL_DATA_ANALYSIS" case study, 
	"RETURNS" are considered as, the NEGATIVE values with respect to 'Total_amount' column in 'Transactions1' table
	"SALES" are considered as, the POSITIVE values with respect to 'Total_amount' column in 'Transactions1' table
  "NET REVENUE" is considered as, combining both POSITIVE AND NEGATIVE values wrt 'Total_amount' column in 'Transactions1' table
*/
	

---------Creating a database named "retail_data_copy", to perform all the quires in RETAIL_DATA_ANALYSIS case study------------

create database retail_data_copy


-------Using the created "retail_data_copy" case study--------------------------------------

use retail_data_copy


---------Creating a of table name "customer1" in retail_data_copy database-------------------

create table customer1(
Customer_ID int not null,
DOB date not null,
Gender nvarchar(20) not null,
City_code int not null
constraint pk_cust_id primary key(Customer_ID)
);


------------Creating a table of name "Transactions1" in retail_data_copy database--------------------

create table Transactions1(
Transaction_ID bigint not null,
Cust_ID int not null,
Trans_date date not null,
Prod_sub_cat_code int not null,
Prod_cat_code int not null,
Qty int not null,
Rate int not null,
Tax float not null,
Total_amount float not null,
Store_type nvarchar(50) not null,
constraint fk_custt_id foreign key (Cust_ID)
references customer1(Customer_ID)
)


-------Creating a table of name "Prod_cat_info1" in retail_data_copy database--------------

create table Prod_cat_info1 (
Prod_cat_code_1 int not null,
Prod_cat_1 nvarchar(50) not null,
Prod_sub_cat_code_1 int not null,
Prod_sub_cat_1 nvarchar(50) not null
);


--Excel tables of names "customer", "transactions" and"prod_cat_info" have been imported to retail_data_copy using import_wizard---

-------Viewing the records of imported Excel tables "customer","transactions" and "prod_cat_info"----------------
select * from customer
select * from transactions
select * from prod_cat_info


--------Inserting values from imported excel table "customer" to created table "customer1" in the retail_data_copy database--------
                                                  ---&---
---Date variables from the imported table "customer", are being converted to valid Date format while inserting into "customer1"----

insert into customer1(Customer_ID,DOB,Gender,City_code)
select customer_id,convert(date, DOB,105),gender,city_code from customer


----Inserting values from imported excel table "transactions" to created table "Transactions1" in the retail_data_copy database-----
											     ---&---
--Date variables from the imported table "transactions",are being converted to valid Date format while inserting into "Transactions1"---

insert into Transactions1(Transaction_ID,Cust_ID,Trans_date,Prod_sub_cat_code,Prod_cat_code,Qty,Rate,Tax,Total_amount,Store_type)
select transaction_id,cust_id,convert(date, tran_date, 105),prod_subcat_code,prod_cat_code,qty,rate,tax,total_amt,store_type from transactions


---Inserting values from imported excel table "prod_cat_info" to created table "Prod_cat_info1" in the retail_data_copy database---

insert into Prod_cat_info1(Prod_cat_code_1,Prod_cat_1,Prod_sub_cat_code_1,Prod_sub_cat_1)
select prod_cat_code,prod_cat,prod_sub_cat_code,prod_subcat from prod_cat_info


----View of records of the tables "customer1","Transactions1" and "Prod_cat_info1" after inserting values from imported tables-------

select * from customer1
select * from Transactions1
select * from Prod_cat_info1

--------------------------------------------------- PART - 1 ---------------------------------------------------------------------

/*****************************************************************************************************************************************
										DATA PREPARATION AND UNDERSTANDING 
******************************************************************************************************************************************/

/*	1. What is the total number of rows in each of the 3 tables in the database? */

select * from (
select count(*) as [Number of rows in Customer1] from customer1) as a
full outer join 
(select count(*) as [Number of rows in Transactions1] from Transactions1) as b on 1=1
full outer join
(select count(*) as [Number of Prod_cat_info1] from Prod_cat_info1) as c on 1=1

/*	2. What is the total number of transactions that have a return? */

select count(*) as [Total No. of transactions that have a return] from Transactions1
where Total_amount like '[-]%'

/*	3. As you would have noticed, the dates provided across the datasets are not in a correct format. 
	   As first steps, pls convert the date variables into valid date formats before proceeding ahead.  */

---Date formatting of Date variables have been done while inserting the values to the tables, can find it above---

/*	4. What is the time range of the transaction data available for analysis? 
	Show the output in number of days, months and years simultaneously in different columns. */

select DATEDIFF(year,min(trans_date),max(trans_date)) [Time range of transaction_data in No. of YEARS],
DATEDIFF(month,min(trans_date),max(trans_date)) [Time range of transaction_data in No. of MONTHS],
DATEDIFF(day,min(trans_date),max(trans_date)) [Time range of transaction_data in No. of DAYS]
from Transactions1

/*	5. Which product category does the sub-category “DIY” belong to? */

select distinct Prod_cat_1 as [Product category of 'DIY'] from Prod_cat_info1
where Prod_sub_cat_1='DIY'


-------------------------------------------------------- PART-2 ------------------------------------------------------------------------

/****************************************************************************************************************************************************
													  DATA ANALYSIS 
****************************************************************************************************************************************************/

/*	1. Which channel is most frequently used for transactions? */

select store_type as [Most frequently used channel for transactions] from(
select top 1 store_type, count(store_type) as [count of store_type] from Transactions1
group by Store_type
order by [count of store_type] desc) as a

/*	2. What is the count of Male and Female customers in the database? */

select * from (
select count(gender) as [Count of FEMALE customers] from customer1
where gender='F'
group by Gender) as a
full outer join
(
select count(gender) as [Count of MALE customers] from customer1
where gender='M'
group by Gender) as b on 1=1

/*	3. From which city do we have the maximum number of customers and how many? */

select top 1 city_code as [City_code with MAX customers], count(city_code) as [MAX No. of customers] from customer1
group by City_code
order by [Max no. of customers] desc

/*	4. How many sub-categories are there under the Books category? */

select count(prod_sub_cat_1) as [No. of sub-categories under "Books" category] from Prod_cat_info1
where Prod_cat_1='books'

/*	5. What is the maximum quantity of products ever ordered? */

select max(abs(qty)) as [MAX Quantity of products ever ordered] from Transactions1


/*	Creating a sub-query, as View of name "Transaction_details_wrt_Prod_cat_and_prod_Sub_cat" and this VIEW (sub-query)
			"Transaction_details_wrt_Prod_cat_and_prod_Sub_cat"	is used in questions 6,8,9,10,12,14,15					 */

create view Transaction_details_wrt_Prod_cat_and_prod_Sub_cat as
(select Transaction_ID,Cust_ID,Gender,Trans_date,Prod_cat_code,Prod_cat_1,Prod_sub_cat_code,Prod_sub_cat_1,Total_amount,Store_type,
concat(prod_cat_code,' - ',Prod_sub_cat_code)  as [Prod_Cat_Code - with - Prod_Sub_Cat_Code],
concat(prod_cat_1,' - ',Prod_sub_cat_1) as [Prod_Cat - with - Prod_Sub_Cat]
from Transactions1
left join customer1 on Transactions1.Cust_ID=customer1.Customer_ID
left join Prod_cat_info1 on
Transactions1.Prod_cat_code=Prod_cat_info1.Prod_cat_code_1 and 
Transactions1.Prod_sub_cat_code=Prod_cat_info1.Prod_sub_cat_code_1 
)


------------Viewing the created view (sub-query) "Transaction_details_wrt_Prod_cat_and_prod_Sub_cat"---------

select * from Transaction_details_wrt_Prod_cat_and_prod_Sub_cat

/*	6. What is the net total revenue generated in categories Electronics and Books? */

---------Q(6)---Using the (sub-query) view "Transaction_details_wrt_Prod_cat_and_prod_Sub_cat" to solve Q6 --------------------

select Prod_cat_1 as [Product Category],sum(total_amount) as [Total Revenue of Product category] 
from transaction_details_wrt_prod_cat_and_prod_sub_cat
where prod_cat_1 in ('Electronics','books')
group by Prod_cat_1

/*	7. How many customers have >10 transactions with us, excluding returns? */

select Cust_ID as [Customers with more than 10 transactions excluding returns],
count(transaction_id) [No. of transactions of the customer] from Transactions1
where Total_amount not like '[-]%'
group by Cust_ID
having count(Transaction_ID)>10

/*	8. What is the combined revenue earned from the “Electronics” & “Clothing” categories, from “Flagship stores”? */

------------Using the (sub-query) view "Transaction_details_wrt_Prod_cat_and_prod_Sub_cat" to solve Q8 --------------------

select Store_type,sum(total_amount) as [Combined total revenue earned from "Electronics" and "Clothing"] 
from Transaction_details_wrt_Prod_cat_and_prod_Sub_cat
where Prod_cat_1 in ('Electronics','Clothing') and Store_type='Flagship store'
group by Store_type

/*	9. What is the total revenue generated from "Male" customers in "Electronics” category? 
		Output should display total revenue by prod sub-cat. */

------------Using the (sub-query) view "Transaction_details_wrt_Prod_cat_and_prod_Sub_cat" to solve Q9 -------------------

select Prod_sub_cat_1 as [Product Sub-Category],sum(total_amount) as [Net Revenue of Male customers in "Electronics" category] 
from Transaction_details_wrt_Prod_cat_and_prod_Sub_cat
where Gender='M' and Prod_cat_1='Electronics'
group by Prod_sub_cat_1
order by [Net Revenue of Male customers in "Electronics" category] desc

/*	10. What is percentage of sales and returns by product sub category; 
	display only top 5 sub categories in terms of sales? */

/*	Using the (sub-query) view "Transaction_details_wrt_Prod_cat_and_prod_Sub_cat" to create another sub-queries (as VIEW)
						of names "Total_Returns_by_Prod_Sub_cat" & "Total_Sales_by_Prod_Sub_cat"								 */

-----------Creating a sub-query as View of name "Total_Returns_by_Prod_Sub_cat"----------------

create view Total_Returns_by_Prod_Sub_cat as(
select 
[Prod_Cat_Code - with - Prod_Sub_Cat_Code] ,[Prod_Cat - with - Prod_Sub_Cat],
sum(total_amount) as [Net Total Returns],
(convert(numeric,count(transaction_id))*100)/(select convert(numeric,count(transaction_id)) from Transaction_details_wrt_Prod_cat_and_prod_Sub_cat) [Percentage of Returns]
from Transaction_details_wrt_Prod_cat_and_prod_Sub_cat
where Total_amount like '[-]%'
group by [Prod_Cat_Code - with - Prod_Sub_Cat_Code],[Prod_Cat - with - Prod_Sub_Cat]
)

-----------Creating a sub-query as View of name "Total_Sales_by_Prod_Sub_cat"----------------
create view Total_Sales_by_Prod_Sub_cat as(
select 
[Prod_Cat_Code - with - Prod_Sub_Cat_Code],[Prod_Cat - with - Prod_Sub_Cat],
sum(total_amount) as [Net Total Sales],
(sum(total_amount)*100)/(select sum(total_amount) from Transaction_details_wrt_Prod_cat_and_prod_Sub_cat) [Percentage of Sales]
from Transaction_details_wrt_Prod_cat_and_prod_Sub_cat
where Total_amount not like '[-]%'
group by [Prod_Cat_Code - with - Prod_Sub_Cat_Code],[Prod_Cat - with - Prod_Sub_Cat]
)


--------Viewing records of the above created sub-queries "Total_Returns_by_Prod_Sub_cat", "total_sales_by_Prod_Sub_cat"---------

select * from Total_Returns_by_Prod_Sub_cat

select * from Total_sales_by_Prod_Sub_cat


----Q10---Using the View (sub-query) "Total_Sales_by_Prod_Sub_cat" and "Total_Returns_by_Prod_Sub_cat" to solve Q10---------------

/*	10. What is percentage of sales and returns by product sub category; 
		display only top 5 sub categories in terms of sales? */

select top 5 t1.[Prod_Cat_Code - with - Prod_Sub_Cat_Code],t1.[Prod_Cat - with - Prod_Sub_Cat],
t1.[Net Total SALES],t1.[Percentage of Sales],
t2.[Net Total RETURNS],t2.[Percentage of Returns]
from Total_Sales_by_Prod_Sub_cat t1
inner join Total_Returns_by_Prod_Sub_cat t2 on
t1.[Prod_Cat_Code - with - Prod_Sub_Cat_Code]=t2.[Prod_Cat_Code - with - Prod_Sub_Cat_Code]
order by [percentage of sales] desc

/*	11. For all customers aged between 25 to 35 years find what is the net total revenue 
	generated by these consumers in last 30 days of transactions from max transaction date available in the data? */

--Age of the customer is calculated from their DOB to till transaction date, because we are solving the problem wrt transaction data

select Cust_ID as [Cust_ID of Customers aged between 25 to 35],sum(total_amount) as [Net Total Revenue] from(
select Transaction_ID,Trans_date,Cust_ID,DOB,datediff(year,DOB,Trans_date) as age,Total_amount from Transactions1
left join customer1 on Transactions1.Cust_ID=customer1.Customer_ID 
where datediff(year,DOB,Trans_date) between 25 and 35 
and Trans_date>=dateadd(day,-30,(select max(trans_date) from Transactions1))) as a
group by Cust_ID
order by [Net Total Revenue] desc


/*	12. Which product category has seen the max value of returns in the last 3 months of transactions? */

------------Using the VIEW (sub-query) "Transaction_details_wrt_Prod_cat_and_prod_Sub_cat"--------------------

select top 1 [Product Category with max returns in last 3 months],[MAX Return amount] from (
select Prod_cat_1 as [Product Category with max returns in last 3 months],Trans_date, max (abs(Total_amount)) [MAX Return amount]
from  Transaction_details_wrt_Prod_cat_and_prod_Sub_cat
where Total_amount like '[-]%' and
trans_date>=dateadd(month,-3,(select max(trans_date) from Transaction_details_wrt_Prod_cat_and_prod_Sub_cat))
group by Prod_cat_1,Trans_date) as a
order by [MAX Return amount] desc


/*	13. Which store-type sells the maximum products; by value of sales amount and by quantity sold? */

select store_type as [Store Type which sells MAX Products] from(
select TOP 1 Store_type,sum(qty) [Total qty],sum(total_amount) [Total sales] from Transactions1
group by Store_type
order by [Total sales] desc,[Total qty] desc) as a


/*	14. What are the categories for which average revenue is above the overall average. */

------------Using the VIEW (sub-query) "Transaction_details_wrt_Prod_cat_and_prod_Sub_cat"--------------------

select Prod_cat_1 as [Categories with AVG Revenue more than overall AVG],avg(total_amount) [Average revenue of each category] 
from Transaction_details_wrt_Prod_cat_and_prod_Sub_cat
group by Prod_cat_1
having avg(total_amount)>=(select avg(total_amount) from Transaction_details_wrt_Prod_cat_and_prod_Sub_cat)
order by [Average revenue of each category] desc

/*	15. Find the average and total revenue by each subcategory for the categories 
	which are among top 5 categories in terms of quantity sold. */

------------Using the VIEW (sub-query) "Transaction_details_wrt_Prod_cat_and_prod_Sub_cat"--------------------

select [Prod_Cat - with - Prod_Sub_Cat] as ["(Category)"--"(Sub.Category)"],
sum(total_amount) [Total Revenue],avg(total_amount) [Average Revenue] 
from Transaction_details_wrt_Prod_cat_and_prod_Sub_cat
where Prod_cat_code in 
(
select top 5 Prod_cat_code from Transactions1
group by Prod_cat_code
order by sum(abs(qty)) desc
)
group by [Prod_Cat - with - Prod_Sub_Cat]
order by [Total Revenue] desc

