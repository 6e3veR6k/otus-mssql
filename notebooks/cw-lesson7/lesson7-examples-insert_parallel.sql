USE AdventureWorks2017;

begin tran 
INSERT INTO person.address
(addressline1, addressline2, city, stateprovinceid, postalcode)
VALUES('677123223231 Kingsway Address2', '', 'Burnaby', 7, 'V5H 3Z8');

SELECT @@IDENTITY, SCOPE_IDENTITY();

commit tran