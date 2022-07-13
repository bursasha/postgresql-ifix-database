# A semester university (ČVUT FIT) project on creating a database, create script, insert script, schemas, and queries over a database on PostgreSQL 📊

## iFix Service Center Chain database description:
A year ago, in January 2021 (the 1st of January), a chain of iFix service centers opened in England, focusing primarily on repairing devices from different manufacturers, as well as selling various accessories for gadgets.

All branches of the chain of service centers maintain personal databases, all customers and employees receive their own identification number by the registration, everybody indicates their first name, last name, phone number, and can leave their email as an additional way of communicating with the service center. Employees, in turn, are recorded with their working position, salary, and date of employment in the database. Each branch has several technicians (from 2 to 5), who are managed by one manager.

All customers of the service center bring their gadgets for repair (at least 1) and can buy some accessory for their device (as many as they want). Visitors' gadgets are registered using their IMEI numbers (6-9 digits), which are unique for all devices in the world, the manufacturer of their gadget, the model of the device, and the year of production (if necessary). The types of breakdowns of the brought devices and the payment method of each client are entered into the database, you can pay by card, with bank transfer or cash. Each visitor can be served by several employees of the branch.

And, of course, in addition to people and branches, their addresses are stored in the database. Each address has its own unique code, building number, street, district and postal code. And since a considerable number of such branches have opened in the country, the address is also associated with the city in which the person lives or where the branch is located.

## Loops discussion:
1. Employee – Person – Address – Branch
* It is more convenient and rational to store the address of customers and branches in one table in the database, since it is necessary to store this data for the needs of the service center. The result of this loop is that customers can live at the same address that a branch of the service center can be located. More than one person can live at the same address, but the addresses of customers and branches do not overlap, which I describe in the integrity constraint.

2. Employee – Employee
* Only 1 manager or from 2 to 5 technicians can be employed in a branch. The technicians are led by a manager who is the main individual in each branch. Based on this loop, the manager can subordinate/lead himself, and I constrain this case with the integrity restriction.

3. Person – Service – Employee
* As I wrote about the first loop, and in the case of this one, it is more rational to store data about all people (both customers and employees) in one database table. The result of this loop is that the branch employees can serve themselves, but it is not a problem, since none of the employees stops working at the same time, and the employee pays for the service like all customers.

## Conceptual scheme:
![Conceptual scheme](/assets/conceptual_scheme.png)

## Relational scheme:
![Relational scheme](/assets/relational_scheme.png)

## Sources:
- https://users.fit.cvut.cz/~hunkajir/dbs2/main.xml#D17
- https://users.fit.cvut.cz/~hunkajir/dbs/main.xml
- https://www.postgresql.org/files/documentation/pdf/12/postgresql-12-A4.pdf
- https://stackoverflow.com/
- https://www.mockaroo.com/
- https://courses.fit.cvut.cz/BI-DBS/
