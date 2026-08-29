SELECT
    name AS TableName
    ,create_date AS CreatedDate
    ,modify_date AS LastModifiedDate
FROM
    sys.objects
WHERE
    TYPE = 'U' -- 'U' คือ User Table
    AND name LIKE 'pp_%'
ORDER BY
    modify_date DESC;
/*
https://pitt.plusmagi.com/sql-server-%e0%b8%95%e0%b8%b2%e0%b8%a3%e0%b8%b2%e0%b8%87-%e0%b8%ab%e0%b8%a3%e0%b8%ad-xxx-%e0%b8%99%e0%b8%96%e0%b8%81%e0%b8%aa%e0%b8%a3%e0%b8%b2%e0%b8%87-%e0%b8%96%e0%b8%81%e0%b9%81%e0%b8%81%e0%b9%80/

TYPE =

AF = Aggregate function (CLR)
C = Check constraint
D = Default (constraint or stand-alone)
EC = Edge constraint
ET = External table
F = Foreign key constraint
FN = SQL scalar function
FS = Assembly (CLR) scalar-function
FT = Assembly (CLR) table-valued function
IF = SQL inline table-valued function (TVF)
IT = Internal table
P = SQL stored procedure
PC = Assembly (CLR) stored-procedure
PG = Plan guide
PK = Primary key constraint
R = Rule (old-style, stand-alone)
RF = Replication-filter-procedure
S = System base table
SN = Synonym
SO = Sequence object
SQ = Service queue
ST = Statistics tree
TA = Assembly (CLR) DML trigger
TF = SQL table-valued-function (TVF)
TR = SQL DML trigger
TT = Table type
U = Table (user-defined)
UQ = unique constraint
V = View
X = Extended stored procedure
*/