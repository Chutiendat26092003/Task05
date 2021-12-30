
--ss8
use AdventureWorks2019
go

--1
select left('International', 5)

--2
select * from HumanResources.Employee 
go

--3
select LocationID, CostRate from Production.Location
go

--4
select Name +':'+ CountryRegionCode +'->'+ [Group] from Sales.SalesTerritory
go

--5
select Name +': '+ CountryRegionCode +'->'+ [Group] AS NameRegionGroup
from Sales.SalesTerritory
go

--6
select ModifiedDate as 'ChangedDate' from Person.Person
go

--7
select ProductID, StandardCost, StandardCost*0.15 Discount 
from Production.ProductCostHistory
go

--8
select distinct StandardCost from Production.ProductCostHistory
go

-- 9
select ProductModelID, Name into Production.ProductName from Production.ProductModel

--10 
select * from Production.ProductCostHistory where EndDate = '2013-05-29 00:00:00.000'
go

--11
select * from Person.Address where City = 'Bothell'
go

--12
select * from HumanResources.Department where DepartmentID < 10
go

--13
select * from Person.Address where AddressID  > 900 and City = 'Seattle'
go

--14 
select * from Person.Address where AddressID  > 900 or City = 'Seattle'
go

--15
select * from Person.Address where not AddressID  = 5
go

--16
select WorkOrderID , sum(ActualResourceHrs) from Production.WorkOrderRouting
group by WorkOrderID
go

--17
select WorkOrderID , sum(ActualResourceHrs) from Production.WorkOrderRouting
group by WorkOrderID having WorkOrderID < 50
go

--18
select * from Sales.SalesTerritory
order by SalesLastYear
go

--19
create table Person.PhoneBilling (Bill_ID int primary key, MobileNumber bigint unique, CallDetails xml)
go

--20
insert into Person.PhoneBilling values 
(100, 9833276605, '<Info><Call>Local</Call><Time>45minutes</Time><Changes>200</Changes></Info>')
select * from Person.PhoneBilling
go

--21
declare @xmlvar xml
select @xmlvar = '<Employee name = "Joan"/>'
go

--22
CREATE XML SCHEMA COLLECTION SoccerSchemaCollection
AS N'<xsd:schema xmlns:xsd="http:www.w3.org/2001/XMLSchema">
<xsd:element name="MatchDetails">
<xsd:complexType>
<xsd:complexContent>
<xsd:restriction base="xsd:anyType">
<xsd:sequence>
<xsd:element name="Team" minOccurs="0" maxOccurs="unbounded">
<xsd:complexType>
<xsd:complexContent>
<xsd:restriction base="xsd: anyType">
<xsd:sequence />
<xsd:attribute name="country" type="xsd:string" />
<xsd:attribute name="score" type="xsd:string" /> 
</xsd:restriction>
</xsd:complexContent>
</xsd:complexType>
</xsd:element>
</xsd:sequence>
</xsd:restriction>
</xsd:complexContent>
</xsd:complexType>
</xsd:element>
</xsd:schema>'
go

--23
create table SoccerTeam (
    TeamID int identity not null, 
	TeamInfo xml (SoccerSchemaCollection) )
go

--24
insert into SoccerTeam(TeamInfo) values ('<MatchDetails>
                                              <Team country="Autralia" score="3"></Team>
                                              <Team country="Zimbabwe" score="2"></Team>
											  <Team country="England" score="4"></Team>
										 </MatchDetails>')
go

select * from SoccerTeam

--25
declare @team xml (SoccerSchemaCollection)
set @team = '<MatchDetails><Team country="Autralia"></Team></MatchDetails>'
select @team


--ss9
--1
select WorkOrderID, SUM(ActualResourceHrs) as TotalHoursPerWorkOrder 
from Production.WorkOrderRouting 
group by WorkOrderID

--2
select WorkOrderID, SUM(ActualResourceHrs) as TotalHoursPerWorkOrder 
from Production.WorkOrderRouting 
where WorkOrderID < 50
group by WorkOrderID

--3
select Class, AVG(ListPrice) as 'SverageListPrice' 
from Production.Product
group by Class

--4
select [Group], SUM(SalesYTD) as 'TotalSales'
from Sales.SalesTerritory
where [Group] like 'N%'
group by all [Group] 

--5
select [Group], SUM(SalesYTD) as 'TotalSales'
from Sales.SalesTerritory
where [Group] like 'P%'
group by all [Group]
having SUM(SalesYTD) < 6000000

--6
select Name, CountryRegionCode, SUM(SalesYTD) as TotalSales
from Sales.SalesTerritory 
where Name <> 'Australia' and Name <> 'Canada' 
group by Name, CountryRegionCode with cube

--7
select Name, CountryRegionCode, SUM(SalesYTD) as TotalSales
from Sales.SalesTerritory 
where Name <> 'Australia' and Name <> 'Canada' 
group by Name, CountryRegionCode with rollup

--8
select AVG([UnitPrice]) as AvgUnitPrice, Min([OrderQty]) as MinQty,
MAX([UnitPriceDiscount]) as MaxDiscount
from Sales.SalesOrderDetail

--9
select SalesOrderID, AVG(UnitPrice) as AvgPrice 
from Sales.SalesOrderDetail

--10
select MIN(OrderDate) as Earliest, MAX(OrderDate) as Latest 
from Sales.SalesOrderHeader

--11
select geometry::Point(251, 1, 4326).STUnion(geometry::Point(252, 2, 4326)) 

--12
declare @City1 geography
set @City1 = geography::STPolyFromText(
  'POLYGON((175.3-41.5, 178.3-37.9, 172.8-34.6, 175.3-41.5))', 4326)
declare @City2 geography
set @City2 = geography::STPolyFromText(
  'POLYGON((169.3-46.6, 174.3-41.6, 172.5-40.7, 166.3-45.8, 169.3-46.6))', 4326)
declare @CombinedCity geography = @City1.STUnion(@City2)
select @CombinedCity

--13
select Geography::UnionAggregate(SpatialLocation) as AVGLocation 
from Person.Address
where City = 'London'

--14
select Geography::EnvelopeAggregate(SpatialLocation) as AVGLocation 
from Person.Address
where City = 'London'

--15
declare @CollectionDemo table(
    shape geometry,
	shapeType nvarchar(50)
)
insert into @CollectionDemo(shape, shapeType) values 
('CURVEPOLYGON(CIRCULARSTRING(2 3, 4 1, 6 3, 4 5, 2 3))', 'Circle'),
('POLYGON((1 1, 4 1, 4 5, 1 5, 1 1))', 'Rectangle');
  
select geometry::CollectionAggregate(shape) from @CollectionDemo

--16
select Geography::ConvexHullAggregate(SpatialLocation) as Location 
from Person.Address
where City = 'London'

--17
select DueDate, ShipDate from Sales.SalesOrderHeader
where Sales.SalesOrderHeader.OrderDate = (select MAX(OrderDate) from Sales.SalesOrderHeader)

--18
select FirstName, LastName from Person.Person
where Person.Person.BusinessEntityID in (select BusinessEntityID
from HumanResources.Employee where JobTitle = 'Research and Development Manager')

--19
select FirstName, LastName from Person.Person as A 
where exists 
(select * from HumanResources.Employee as B
where JobTitle = 'Reserch and Development Manager' and A.BusinessEntityID = B.BusinessEntityID)

--20
select FirstName, LastName from Person.Person 
where BusinessEntityID in
(select BusinessEntityID from Sales.SalesPerson
where TerritoryID in 
(select TerritoryID
from Sales.SalesTerritory 
where Name = 'Canada'))

--21
select e.BusinessEntityID from Person.BusinessEntityContact e
where e.ContactTypeID in
(select c.ContactTypeID from Person.ContactType c
where YEAR(e.ModifiedDate) >=2012 )

--22
select A.FirstName, A.LastName, B.JobTitle
from Person.Person A
JOIN
HumanResources.Employee B on
A.BusinessEntityID = B.BusinessEntityID;

--23
select A.FirstName, A.LastName, B.JobTitle
from Person.Person A
INNER JOIN
HumanResources.Employee B on
A.BusinessEntityID = B.BusinessEntityID;

--24
select A.CustomerID, B.DueDate, B.ShipDate
from Sales.Customer A
LEFT OUTER JOIN
Sales.SalesOrderHeader B
on 
A.CustomerID = B.CustomerID AND YEAR(B.DueDate) <2019

--25
select P.Name, S.SalesOrderID
from Sales.SalesOrderDetail S
RIGHT OUTER JOIN 
Production.Product P
on P.ProductID = S.ProductID

--26
select p1.ProductID,
       p1.Color,
	   p1.Name,
	   p2.Name
from Production.Product p1
inner join Production.Product p2
on  p1.Color = p2.Color
order by p1.ProductID

--27
set identity_insert [Person].[AddressType] on
merge into [Person].[AddressType] as target 
using (values
   (1, 'Billing'),
   (2, 'Home'),
   (3, 'Headquarters'),
   (4, 'Primary'),
   (5, 'Shipping'),
   (6, 'Archival'),
   (7, 'Contact'),
   (8, 'Alternative')
) as Source
([AddressTypeID], [Name]) on (Target.[AddressTypeID] = Source.[AddressTypeID])
when matched and (Target.[Name] <> Source.[Name]) then
    update set [Name] = Source.[Name]
when not matched by Target then 
insert ([AddressTypeID], [Name]) values (Source.[AddressTypeID], Source.[Name])
when not matched by Source then
    delete 
output $action, Inserted.[AddressTypeID], Inserted.Name,
Deleted.[AddressTypeID], Deleted.Name;


--28
WITH CTE_OrderYear as
(
 select YEAR(OrderDate) as OrderYear, CustomerID
 from Sales.SalesOrderHeader
)
select OrderYear, COUNT(DISTINCT CustomerID) as CustomerCount 
from CTE_OrderYear
group by OrderYear

--29
with CTE_Students as 
(
StudentCode, S.Name, C.CityName, St.Status 
from Student S inner join City C
on S.CityCode = C.CityCode inner join Status St
on S.StatusID = St.StatusID),
StatusRecord as
(select Status, count(Name) as CountofStudents
from CTE_Students
group by Status)
select * from StatusRecord

--30  
select Product.ProductID
from Production.Product 
union
select ProductID
from Sales.SalesOrderDetail

--31
select Product.ProductID
from Production.Product 
union all
select ProductID
from Sales.SalesOrderDetail

--32
select Product.ProductId
from Production.Product
intersect
select ProductId
from Sales.SalesOrderDetail

--33
select Product.ProductId
from Production.Product
except
select ProductId
from Sales.SalesOrderDetail

--34
select top 5 Sum(SalesYTD) as TotalSalesYTD, Name 
from Sales.SalesTerritory
group by Name

--35
select top 5 'TotalSalesYTD' as GrandTotal,
[Northwest], [Northeast], [Central], [Southwest], [Southeast]
from 
(select top 5 Name, SalesYTD 
from Sales.SalesTerritory) as SourseTable PIVOT
(SUM(SalesYTD) for Name in ([Northwest], [Northeast], [Central], [Southwest], [Southeast]))
as PivotTable

--36
select SalesYear, TotalSales from
(
    select * from 
	(
	    select YEAR(SOH.OrderDate) as SalesYear,
		           SOH.SubTotal as TotalSales
		from Sales.SalesOrderDetail SOD 
		     JOIN Sales.SalesOrderDetail SOD on SOH.SalesOrderId = SOD.SalesOrderID
	) as Sales PIVOT(SUM(TotalSales) for SalesYear in ([2011],
	                                                   [2012],
													   [2013],
													   [2014])) as PVT
)T UNPIVOT(TotalSales for SalesYear in ([2011],
	                                    [2012],
										[2013],
										[2014])) as upvt












--video
use AdventureWorks2019
go

select *  from Person.ContactType
where ContactTypeID >= 3  and  ContactTypeID <= 9
go

--trong đoạn [3, 9]
select *  from Person.ContactType
where ContactTypeID between 3 and 9
go

-- tập hợp  1, 3, 5, 9 
select * from Person.ContactType
where ContactTypeID in(1, 3, 5, 9)
go

--kết thúc bằng chứ e
select * from Person.Person
where LastName like '%e'

--bắt đầu bằng ký tự R hoặc A kết thức bởi e
select * from Person.Person
where LastName like '[RA]%e'

-- lấy ra 4 ký tự 
select * from Person.Person
where LastName like '[RA]__e'

select * from Person.Person
where LastName like '%a%'

--sử dụng DISTINCT các dữ liệu trùng lặp loại bỏ
select DISTINCT Title from Person.Person

--sd GROUP BY
select Title from Person.Person
Group by Title

select Title, COUNT(*) [Title Number] from Person.Person
Group by Title

select Title, COUNT(*) [Title Number] from Person.Person
where Title like 'Mr%'
Group by Title

select Title, COUNT(*) [Title Number] from Person.Person
where Title like 'Mr%'
Group by all Title

select Title, COUNT(*) [Title Number] from Person.Person
Group by Title
having Title like 'Mr%'

-- where là thực hiện xong mới tổng , having tổng xong rồi thực hiện 
select Title, COUNT(*) [Title Number] from Person.Person
where Title like 'Mr%'
Group by all Title
having COUNT(*) > 10

--GROUP BY với CUBE: sẽ có thêm 1 hàng siêu kết hợp gộp tất cả các hàng trong tập hợp trả về 
select Title, COUNT(*) [Title Number] from Person.Person
group by Title with cube

select Title, COUNT(*) [Title Number] from Person.Person
group by Title with rollup

-- sd ORDER BY
select * from Person.Person
order by FirstName, LastName DESC


-- truy vấn từ nhiều bảng
select * from Person.Person
select * from HumanResources.Employee

--truy vấn con-lấy ra BusinessEntityID trong bảng Person.Person và phải nằm trong bảng HumanResources.Employee
select * from Person.Person
where BusinessEntityID in(
   select BusinessEntityID
   from HumanResources.Employee)

-- lấy ra các trường đó và xem có tồn tại hay không 
select * from Person.Person C
where exists(
   select BusinessEntityID
   from HumanResources.Employee
   where BusinessEntityID=C.BusinessEntityID)

-- kết hợp dữ liệu sử dụng UNION
-- kết hợp các bản ghi lại với nhau 
select ContactTypeID, Name
from Person.ContactType
where ContactTypeID in (1,2,3,4,5,6)
UNION
select ContactTypeID, Name
from Person.ContactType
where ContactTypeID in (1,3,5,7)

-- không muốn loại bỏ giá trị trùng nhau sử dụng UNION all 
select ContactTypeID, Name
from Person.ContactType
where ContactTypeID in (1,2,3,4,5,6)
UNION all 
select ContactTypeID, Name
from Person.ContactType
where ContactTypeID in (1,3,5,7)

--sd inner join 
select * from HumanResources.Employee as e inner join Person.Person as p
              on e.BusinessEntityID = p.BusinessEntityID
order by p.LastName
--bảng e và p được nối với nhau bởi cột chung BusinessEntityID

select distinct p1.ProductSubcategoryID, p1.ListPrice
from Production.Product p1 inner join Production.Product p2
on p1.ProductSubcategoryID = p2.ProductSubcategoryID and p1.ListPrice <> p2.ListPrice -- khác 
where p1.ListPrice < $15 and p2.ListPrice < $15
order by ProductSubcategoryID
