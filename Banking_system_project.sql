create database banking_system_project

use banking_system_project


create table account_opening_form (
[date] date default getdate(),
Account_type varchar(20) default 'saving',
Account_HolderName varchar(50),
DOB date,
AadharNumber varchar(12),
MobileNumber varchar(15),
Account_opening_balance decimal(10,2),
FullAddress varchar(100),
KYC_Status varchar(20) default 'pending'
)


create table bank(
AccountNumber bigint identity(1000000000,1),
AccountType varchar(20),
AccountOpeningDate date default getdate(),
CurrentBalance decimal(10,2)
)

create table AccountHolderDetail(
AccountNumber bigint identity(1000000000,1),
Account_HolderName varchar(50),
DOB date,
AadharNumber varchar(12),
MobileNumber varchar(15),
FullAddress varchar(100)
)


create table TransactionDetail(
AccountNumber bigint,
PaymentType varchar(20),
TransactionAmount decimal(10,2),
DateofTransaction date default getdate()
)

---UI insert value

Insert into account_opening_form 
(Account_type,Account_HolderName, DOB,AadharNumber,MobileNumber,Account_opening_balance,FullAddress)
values('saving','Rohit','1999-04-24','545854562845','9897899897',1000,'rishikesh');

Insert into account_opening_form 
(Account_type,Account_HolderName, DOB,AadharNumber,MobileNumber,Account_opening_balance,FullAddress)
values('saving','Virat','1990-07-18','797745621578','9873654125',2000,'Bihar');


--select* from account_opening_form
--creating trigger for insert data into two main tables (bank and Accountholderdetails)

create trigger dbo.insertdata
on account_opening_form
after update
as
declare @status varchar(20),
@Accout_type varchar(20),
@Account_HolderName varchar(50),
@DOB date,
@AadharNumber varchar(12),
@MobileNumber varchar(15),
@Account_opening_balance decimal(10,2),
@FullAddress varchar(100)

select @status=kyc_status , @Accout_type=Account_type, @Account_HolderName=Account_HolderName,
@DOB=dob, @AadharNumber= AadharNumber, @MobileNumber=MobileNumber, @Account_opening_balance=Account_opening_balance
,@FullAddress= FullAddress
from inserted

if @status='Approved'
begin

insert into bank (AccountType,CurrentBalance) values (@Accout_type,@Account_opening_balance)

insert into AccountHolderDetail(Account_HolderName,DOB,AadharNumber,MobileNumber,FullAddress)values
(@Account_HolderName,@DOB,@AadharNumber,@MobileNumber,@FullAddress)

end

--update status approved

update account_opening_form
set KYC_Status='Approved'
where AadharNumber= '797745621578'

select* from bank
select* from AccountHolderDetail

--checking for rejected account status

Insert into account_opening_form 
(Account_type,Account_HolderName, DOB,AadharNumber,MobileNumber,Account_opening_balance,FullAddress)
values('saving','amit','1999-08-20','545854562887','8789654125',1000,'Delhi');

Insert into account_opening_form 
(Account_type,Account_HolderName, DOB,AadharNumber,MobileNumber,Account_opening_balance,FullAddress)
values('saving','Rahul','2004-01-15','456512369874','789632159745',1000,'Pune');

select*from account_opening_form


--update status Rejected

update account_opening_form
set KYC_Status='Rejected'
where AadharNumber= '456512369874'


--create trigger on transaction table for update current balance into main table

select*from TransactionDetail

create trigger dbo.updatecurrentbalance
on TransactionDetail
after insert
as
declare @paymenttype varchar(20),
@Amount decimal(10,2),
@accountnumber bigint

select @paymenttype=PaymentType, @Amount= TransactionAmount,
@accountnumber=AccountNumber
from inserted

if @paymenttype='credit'
begin
update bank
set CurrentBalance= CurrentBalance+@Amount
where AccountNumber=@accountnumber
end

if @paymenttype='debit'
begin
update bank
set CurrentBalance= CurrentBalance-@Amount
where AccountNumber=@accountnumber
end


--select*from bank
-- accountno 1000000001

select* from TransactionDetail


insert into TransactionDetail (AccountNumber,PaymentType,TransactionAmount) values
( 1000000000,'credit',6000)


insert into TransactionDetail (AccountNumber,PaymentType,TransactionAmount) values
(1000000001,'debit',4000)



select* from TransactionDetail where DateofTransaction>= dateadd(month,-1,getdate())
and AccountNumber='1000000000'

select* from TransactionDetail where DateofTransaction>= dateadd(month,-1,getdate())
and AccountNumber='1000000001'

select dateadd(month,-1,getdate())



create procedure dbo.paystatement( @month int , @accountnumber bigint )
as
begin
	select *From TransactionDetail where  DateofTransaction >= DATEADD (MONTH , -@month , GETDATE())
	and AccountNumber= @accountnumber
end


exec dbo.paystatement 1 , 1000000000
exec dbo.paystatement 1 , 1000000001

