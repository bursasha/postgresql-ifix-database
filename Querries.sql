-- All gadget manufacturers, models, and service costs of cracked screen repairments.
-- Relational algebra: {breakdown(breakdown_type = 'Cracked screen') * gadget_repair_breakdown * gadget_repair * service}[manufacturer, gadget_model, service_cost]
-- SQL:
SELECT DISTINCT manufacturer,
                gadget_model,
                service_cost
FROM (
         SELECT DISTINCT *
         FROM BREAKDOWN
         WHERE breakdown_type = 'Cracked screen'
     ) R1
         NATURAL JOIN GADGET_REPAIR_BREAKDOWN
         NATURAL JOIN GADGET_REPAIR
         NATURAL JOIN SERVICE;

-- iFix branches that are located in London (all branch attributes).
-- Relational algebra: city(city_name = 'London') * address *> branch
-- SQL:
SELECT DISTINCT id_branch,
                id_address,
                spare_parts,
                building_year
FROM BRANCH
         NATURAL JOIN (
    SELECT DISTINCT *
    FROM (
             SELECT DISTINCT *
             FROM CITY
             WHERE city_name = 'London'
         ) R1
             NATURAL JOIN ADDRESS
) R2;

-- Headphones that were sold in branch number 1 with special wrap (all accessories attibutes).
-- Relational algebra: branch(id_branch = 1) * employee *> service_employee[service_employee.id_service = service.id_service]service *> accessory_purchase(accessory_type = 'Headphones' ∧ special_wrap = 'true')
-- SQL:
SELECT DISTINCT id_accessory,
                id_service,
                accessory_type,
                special_wrap
FROM (
         SELECT DISTINCT *
         FROM ACCESSORY_PURCHASE
         WHERE accessory_type = 'Headphones' AND special_wrap = 'true'
     ) R4
         NATURAL JOIN (
    SELECT DISTINCT R3.id_service,
                    R3.id_person,
                    SERVICE.id_service AS id_service_1,
                    SERVICE.id_person AS id_person_1,
                    SERVICE.id_payment_type,
                    SERVICE.service_cost,
                    SERVICE.service_date,
                    SERVICE.service_time
    FROM (
             SELECT DISTINCT id_service,
                             id_person
             FROM SERVICE_EMPLOYEE
                      NATURAL JOIN (
                 SELECT DISTINCT *
                 FROM (
                          SELECT DISTINCT *
                          FROM BRANCH
                          WHERE id_branch = 1
                      ) R1
                          NATURAL JOIN EMPLOYEE
             ) R2
         ) R3
             JOIN SERVICE ON R3.id_service = SERVICE.id_service
) R5;

-- The device of the brand Huawei which had only a problem with the battery and nothing else (select gadget_imei as IMEI, id_service as Service, and gadget_model as Model).
-- Relational algebra: {{breakdown(breakdown_type = 'Battery failure') * gadget_repair_breakdown *> gadget_repair(manufacturer = 'Huawei')} \ {breakdown(breakdown_type != 'Battery failure') * gadget_repair_breakdown *> gadget_repair(manufacturer = 'Huawei')}}[gadget_imei->IMEI, id_service->Service, gadget_model->Model]
-- SQL:
SELECT DISTINCT gadget_imei AS IMEI,
                id_service AS Service,
                gadget_model AS Model
FROM (
         SELECT DISTINCT gadget_imei,
                         id_service,
                         manufacturer,
                         gadget_model,
                         release_year
         FROM (
                  SELECT DISTINCT *
                  FROM GADGET_REPAIR
                  WHERE manufacturer = 'Huawei'
              ) R2
                  NATURAL JOIN (
             SELECT DISTINCT *
             FROM (
                      SELECT DISTINCT *
                      FROM BREAKDOWN
                      WHERE breakdown_type = 'Battery failure'
                  ) R1
                      NATURAL JOIN GADGET_REPAIR_BREAKDOWN
         ) R3
         EXCEPT
         SELECT DISTINCT gadget_imei,
                         id_service,
                         manufacturer,
                         gadget_model,
                         release_year
         FROM (
                  SELECT DISTINCT *
                  FROM GADGET_REPAIR GADGET_REPAIR1
                  WHERE manufacturer = 'Huawei'
              ) R5
                  NATURAL JOIN (
             SELECT DISTINCT *
             FROM (
                      SELECT DISTINCT *
                      FROM BREAKDOWN BREAKDOWN1
                      WHERE breakdown_type != 'Battery failure'
                  ) R4
                      NATURAL JOIN GADGET_REPAIR_BREAKDOWN GADGET_REPAIR_BREAKDOWN1
         ) R6
     ) R7;

-- Employee who accepted each of the payment methods for the service, his position, and salary (fisrt name as name, last name as surname, position, and salary).
-- Relational algebra: {{{service_employee[id_service, id_person->id_employee_person] * service}[id_employee_person, id_payment_type] ÷ payment[id_payment_type]}[id_employee_person = id_person>employee * person}[first_name->name, last_name->surname, employee_position, employee_salary]
-- SQL:
SELECT DISTINCT first_name AS name,
                last_name AS surname,
                employee_position,
                employee_salary
FROM (
         SELECT DISTINCT *
         FROM EMPLOYEE
         WHERE EXISTS (
                       SELECT DISTINCT 1
                       FROM (
                                SELECT DISTINCT id_employee_person
                                FROM (
                                         SELECT DISTINCT id_employee_person,
                                                         id_payment_type
                                         FROM (
                                                  SELECT DISTINCT id_service,
                                                                  id_person AS id_employee_person
                                                  FROM SERVICE_EMPLOYEE
                                              ) R1
                                                  NATURAL JOIN SERVICE
                                     ) R2
                                EXCEPT
                                SELECT DISTINCT id_employee_person
                                FROM (
                                         SELECT DISTINCT *
                                         FROM (
                                                  SELECT DISTINCT id_employee_person
                                                  FROM (
                                                           SELECT DISTINCT id_employee_person,
                                                                           id_payment_type
                                                           FROM (
                                                                    SELECT DISTINCT id_service,
                                                                                    id_person AS id_employee_person
                                                                    FROM SERVICE_EMPLOYEE
                                                                ) R1
                                                                    NATURAL JOIN SERVICE
                                                       ) R2
                                              ) R3
                                                  CROSS JOIN (
                                             SELECT DISTINCT id_payment_type
                                             FROM PAYMENT
                                         ) R4
                                         EXCEPT
                                         SELECT DISTINCT id_employee_person,
                                                         id_payment_type
                                         FROM (
                                                  SELECT DISTINCT id_service,
                                                                  id_person AS id_employee_person
                                                  FROM SERVICE_EMPLOYEE
                                              ) R1
                                                  NATURAL JOIN SERVICE
                                     ) R5
                            ) R6
                       WHERE id_employee_person = id_person
                   )
     ) R7
         NATURAL JOIN PERSON;

-- Employees who aren't employed in the third branch (ID).
-- Relational algebra: {employee !<* branch(id_branch = 3)}[id_person]
-- SQL:
select distinct id_person from  Employee E where not exists (
        select distinct * from Branch B where B.id_branch = 3 and B.id_branch = E.id_branch);

-- The oldest date of conducted service for each employee. If an employee hasn't served anyone, the message "Has not ever served!" should be printed. Select name, last name, and the oldest date.
-- SQL:
begin;

insert into Person (id_person, id_address, first_name, last_name, phone) values (101, 10, 'Vasya', 'Pupkin', '88005553535');
insert into Employee (id_person, id_branch, is_subordinated_to, employee_position, employee_salary, employment_date) values (101, 2, 7, 'Technician', 2007, '2021-01-01');
select first_name, last_name, coalesce(to_char(min(service_date), 'yyyy-mm-dd'), 'Has not ever served!') as oldest_service
from Person natural join Employee natural left join Service_employee SE left join service S on SE.id_service = S.id_service
group by first_name, last_name
order by oldest_service;

rollback;

-- First names, last names, phones, postal codes, service dates, payment types, and printed invoices of all clients from Birmingham who paid in cash or with bank transfer.
-- Relational algebra: {{city(city_name = 'Birmingham') * address * person * service * payment(payment_type = 'Cash')} ∪ {city(city_name = 'Birmingham') * address * person * service * payment(payment_type = 'Bank transfer')}}[first_name, last_name, phone, postal_code, service_date, payment_type, printed_invoice]
-- SQL:
SELECT DISTINCT first_name,
                last_name,
                phone,
                postal_code,
                service_date,
                payment_type,
                printed_invoice
FROM (
         SELECT DISTINCT *
         FROM (
                  SELECT DISTINCT *
                  FROM CITY
                  WHERE city_name = 'Birmingham'
              ) R1
                  NATURAL JOIN ADDRESS
                  NATURAL JOIN PERSON
                  NATURAL JOIN SERVICE
                  NATURAL JOIN (
             SELECT DISTINCT *
             FROM PAYMENT
             WHERE payment_type = 'Cash'
         ) R2
         UNION
         SELECT DISTINCT *
         FROM (
                  SELECT DISTINCT *
                  FROM CITY CITY1
                  WHERE city_name = 'Birmingham'
              ) R3
                  NATURAL JOIN ADDRESS ADDRESS1
                  NATURAL JOIN PERSON PERSON1
                  NATURAL JOIN SERVICE SERVICE1
                  NATURAL JOIN (
             SELECT DISTINCT *
             FROM PAYMENT PAYMENT1
             WHERE payment_type = 'Bank transfer'
         ) R4
     ) R5;

-- Manufacturers of serviced gadgets with both battery failure and overheating problems.
-- Relational algebra: {gadget_repair * gadget_repair_breakdown * breakdown(breakdown_type = 'Battery failure')}[manufacturer] ∩ {gadget_repair * gadget_repair_breakdown * breakdown(breakdown_type = 'Overheating')}[manufacturer]
-- SQL:
SELECT DISTINCT manufacturer
FROM GADGET_REPAIR
         NATURAL JOIN GADGET_REPAIR_BREAKDOWN
         NATURAL JOIN (
    SELECT DISTINCT *
    FROM BREAKDOWN
    WHERE breakdown_type = 'Battery failure'
) R1
INTERSECT
SELECT DISTINCT manufacturer
FROM GADGET_REPAIR GADGET_REPAIR1
         NATURAL JOIN GADGET_REPAIR_BREAKDOWN GADGET_REPAIR_BREAKDOWN1
         NATURAL JOIN (
    SELECT DISTINCT *
    FROM BREAKDOWN BREAKDOWN1
    WHERE breakdown_type = 'Overheating'
) R2;

-- Checking the fifth D1 query (employee who accepted each of the payment methods for the service).
-- Relational algebra: payment[id_payment_type] \ {{{{service_employee[id_service, id_person->id_employee_person] * service}[id_employee_person, id_payment_type] ÷ payment[id_payment_type]}[id_employee_person = id_person>service_employee[service_employee.id_service = service.id_service]service *> payment}[id_payment_type]}
-- SQL:
SELECT DISTINCT id_payment_type
FROM PAYMENT
EXCEPT
SELECT DISTINCT id_payment_type
FROM (
         SELECT DISTINCT id_payment_type,
                         payment_type,
                         printed_invoice
         FROM PAYMENT PAYMENT2
                  NATURAL JOIN (
             SELECT DISTINCT R7.id_service,
                             R7.id_person,
                             SERVICE1.id_service AS id_service_1,
                             SERVICE1.id_person AS id_person_1,
                             SERVICE1.id_payment_type,
                             SERVICE1.service_cost,
                             SERVICE1.service_date,
                             SERVICE1.service_time
             FROM (
                      SELECT DISTINCT *
                      FROM SERVICE_EMPLOYEE SERVICE_EMPLOYEE1
                      WHERE EXISTS (
                                    SELECT DISTINCT 1
                                    FROM (
                                             SELECT DISTINCT id_employee_person
                                             FROM (
                                                      SELECT DISTINCT id_employee_person,
                                                                      id_payment_type
                                                      FROM (
                                                               SELECT DISTINCT id_service,
                                                                               id_person AS id_employee_person
                                                               FROM SERVICE_EMPLOYEE
                                                           ) R1
                                                               NATURAL JOIN SERVICE
                                                  ) R2
                                             EXCEPT
                                             SELECT DISTINCT id_employee_person
                                             FROM (
                                                      SELECT DISTINCT *
                                                      FROM (
                                                               SELECT DISTINCT id_employee_person
                                                               FROM (
                                                                        SELECT DISTINCT id_employee_person,
                                                                                        id_payment_type
                                                                        FROM (
                                                                                 SELECT DISTINCT id_service,
                                                                                                 id_person AS id_employee_person
                                                                                 FROM SERVICE_EMPLOYEE
                                                                             ) R1
                                                                                 NATURAL JOIN SERVICE
                                                                    ) R2
                                                           ) R3
                                                               CROSS JOIN (
                                                          SELECT DISTINCT id_payment_type
                                                          FROM PAYMENT PAYMENT1
                                                      ) R4
                                                      EXCEPT
                                                      SELECT DISTINCT id_employee_person,
                                                                      id_payment_type
                                                      FROM (
                                                               SELECT DISTINCT id_service,
                                                                               id_person AS id_employee_person
                                                               FROM SERVICE_EMPLOYEE
                                                           ) R1
                                                               NATURAL JOIN SERVICE
                                                  ) R5
                                         ) R6
                                    WHERE id_employee_person = id_person
                                )
                  ) R7
                      JOIN SERVICE SERVICE1 ON R7.id_service = SERVICE1.id_service
         ) R8
     ) R9;

-- All technicians (id_person as id_technician, first_name as technician_name, last_name as technician_surname) and all managers (id_person as id_manager, first_name as manager_name, last_name as manager_surname) with their subordinating relationships. First table contains all technicians, by the right side are located their manager whom they are subordinated. The output should contain every employee and should be ordered by the technician_name, technician_surname, manager_name, and then manager_surname.
-- SQL:
begin;

-- adding a new technician to the 7th branch who said that he doesn't want to be subordinated, it's revolution
insert into employee (id_person, id_branch, is_subordinated_to, employee_position, employee_salary, employment_date) values (26, 7, null, 'Technician', 2500, '2021-01-05');
-- adding a new manager to the 7th branch because it is crazy branch, and this manager doesn't have any subordinates yet
insert into employee (id_person, id_branch, is_subordinated_to, employee_position, employee_salary, employment_date) values (27, 7, null, 'Manager', 5000, '2021-01-06');

select ET.id_person as id_technician, ET.first_name as technician_name, ET.last_name as technician_surname,
       EM.id_person as id_manager, EM.first_name as manager_name, EM.last_name as manager_surname
from
    (select id_person, first_name, last_name, is_subordinated_to
     from Person natural join Employee E where E.employee_position='Technician')ET
        full outer join
    (select id_person, first_name, last_name
     from Person natural join Employee E where E.employee_position='Manager')EM
    on ET.is_subordinated_to=EM.id_person
order by technician_name, technician_surname, manager_name, manager_surname;

rollback;

-- For all of the days when the employee with id_person = 3 conducted services in branch find out a whole revenue for the specific date and a count of performed services for the specific date (services_conducted). Select only those dates when a count of conducted services was more than 1 and order the output by the count of the conducted services.
-- SQL:
select service_date, sum(service_cost) revenue, count(S.id_service) as services_conducted
from (select distinct * from Employee where id_person = 3) E join Service_employee SE using(id_person) join Service S on SE.id_service = S.id_service
group by S.service_date
having count(S.id_service) > 1
order by services_conducted desc;

-- Find out the count of registered addresses in each of the cities (city, address_count).
-- SQL:
select city_name as city, (select count(id_address) from Address A where A.id_city = City.id_city) as address_count
from City;

-- Selection of all customers who bought accessories in iFix service (id_person as customer, service_time, 3 variants).
-- SQL:
select distinct id_person as customer, service_time from Service S join Accessory_purchase AP on S.id_service = AP.id_service
order by id_person asc, service_time desc;

select distinct id_person as customer, service_time from Service S where exists (select * from Accessory_purchase AP where S.id_service = AP.id_service)
order by id_person asc, service_time desc;

select distinct id_person as customer, service_time from Service S where S.id_service in (select id_service from Accessory_purchase)
order by id_person asc, service_time desc;

-- A view of rich employees in iFix chain services (salary > 3500, all attributes).
-- SQL:
create or replace view rich_employee as
select *
from Employee E where employee_salary > 3500 and exists (select 10 from Service_employee SE where SE.id_person = E.id_person)
    with check option;

select * from rich_employee;

-- Selection of first names, last names, and phone numbers of rich employees (view of rich_employee).
-- SQL:
select id_person, first_name, last_name, phone
from Person P natural join Employee
where exists (select 55 from rich_employee RE where RE.id_person = P.id_person);

-- Insertion of a random service that was requested by a random customer (random existing data).
-- SQL:
begin;

select count(*) from Service;

insert into Service (id_service, id_person, id_payment_type, service_cost, service_date, service_time)
select *
from (select id_service + 500 as id_service, id_person, id_payment_type, service_cost, now() - random() * INTERVAL '1 year' as service_date, service_time from Service) Input
order by random() limit 3;

select count(*) from Service;

rollback;

select count(*) from Service;

-- Raise a salary of the technicians of the third branch and show their ID, first name, last name, and actual salary (new boss has come).
-- SQL:
begin;

select E.id_person, P.first_name, P.last_name, E.employee_salary
from Person P join Employee E using(id_person) where employee_position = 'Technician' and id_branch = 2;

update Employee
set employee_salary = employee_salary + 625
where id_person in (select id_person from Employee where employee_position = 'Technician' and id_branch = 2);

select E.id_person, P.first_name, P.last_name, E.employee_salary
from Person P join Employee E using(id_person) where employee_position = 'Technician' and id_branch = 2;

rollback;

-- Deletion of all rich employees (view rich_employee).
-- SQL:
begin;

select count(id_person) from rich_employee;
delete from Employee where id_person in (select id_person from rich_employee);
select count(id_person) from rich_employee;

rollback;

select count(id_person) from rich_employee;

-- All possible breakdowns of registered gadgets (select breakdown type, manufacturer, and gadget model).
select distinct breakdown_type, manufacturer, gadget_model from breakdown cross join (select distinct manufacturer, gadget_model from Gadget_repair) GR
order by breakdown_type, manufacturer, gadget_model;

-- List of all services that were paid by card (first name, last name of customer, service date, city name).
-- Relational algebra: {service * payment(payment_type = 'Card') * person * address * city}[first_name, last_name, service_date, city_name]
-- SQL:
SELECT DISTINCT first_name,
                last_name,
                service_date,
                city_name
FROM SERVICE
         NATURAL JOIN (
    SELECT DISTINCT *
    FROM PAYMENT
    WHERE payment_type = 'Card'
) R1
         NATURAL JOIN PERSON
         NATURAL JOIN ADDRESS
         NATURAL JOIN CITY;

-- ID, phone, and city names of people that don't live in Leeds.
-- SQL:
select distinct id_person, phone, city_name from Person natural join address natural join city
except
select distinct id_person, phone, city_name from Person P natural join Address natural join City where city_name = 'Leeds'
order by id_person;

-- Addresses of all employees who live in Glasgow and all people that live in London (city name, building number, street)
-- SQL:
select city_name, building_number, street from
    (select distinct A.*, C.* from Employee natural join Person natural join Address A natural join City C where city_name = 'Glasgow'
     union
     select distinct A.*, C.* from Person natural join Address A natural join City C where city_name = 'London')R;

-- IDs of people who bought power adapters with special wrap.
-- SQL:
select id_person from (select * from Accessory_purchase where accessory_type = 'Power adapter' and special_wrap = true) AP
                          join Service using(id_service) natural join Person;

-- Sum of the services of the gyroscope module failure that were paid in cash.
-- SQL:
select sum(service_cost) revenue_cash
from (select id_breakdown from Breakdown where breakdown_type = 'Gyroscope module failure') B natural join Gadget_repair_breakdown
    natural join Gadget_repair natural join Service natural join (select id_payment_type from Payment where payment_type = 'Cash') P;
