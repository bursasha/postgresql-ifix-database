-- Remove conflicting tables
-- DROP TABLE IF EXISTS accessory_purchase CASCADE;
-- DROP TABLE IF EXISTS address CASCADE;
-- DROP TABLE IF EXISTS branch CASCADE;
-- DROP TABLE IF EXISTS breakdown CASCADE;
-- DROP TABLE IF EXISTS city CASCADE;
-- DROP TABLE IF EXISTS employee CASCADE;
-- DROP TABLE IF EXISTS gadget_repair CASCADE;
-- DROP TABLE IF EXISTS payment CASCADE;
-- DROP TABLE IF EXISTS person CASCADE;
-- DROP TABLE IF EXISTS service CASCADE;
-- DROP TABLE IF EXISTS gadget_repair_breakdown CASCADE;
-- DROP TABLE IF EXISTS service_employee CASCADE;
-- -- End of removing

-- odeberu pokud existuje funkce na oodebrání tabulek a sekvencí
DROP FUNCTION IF EXISTS remove_all();

-- vytvořím funkci která odebere tabulky a sekvence
-- chcete také umět psát PLSQL? Zapište si předmět BI-SQL ;-)
CREATE or replace FUNCTION remove_all() RETURNS void AS $$
DECLARE
rec RECORD;
    cmd text;
BEGIN
    cmd := '';

FOR rec IN SELECT
                   'DROP SEQUENCE ' || quote_ident(n.nspname) || '.'
                   || quote_ident(c.relname) || ' CASCADE;' AS name
           FROM
               pg_catalog.pg_class AS c
                   LEFT JOIN
               pg_catalog.pg_namespace AS n
               ON
                       n.oid = c.relnamespace
           WHERE
                   relkind = 'S' AND
                   n.nspname NOT IN ('pg_catalog', 'pg_toast') AND
               pg_catalog.pg_table_is_visible(c.oid)
               LOOP
        cmd := cmd || rec.name;
END LOOP;

FOR rec IN SELECT
                   'DROP TABLE ' || quote_ident(n.nspname) || '.'
                   || quote_ident(c.relname) || ' CASCADE;' AS name
           FROM
               pg_catalog.pg_class AS c
                   LEFT JOIN
               pg_catalog.pg_namespace AS n
               ON
                       n.oid = c.relnamespace WHERE relkind = 'r' AND
                   n.nspname NOT IN ('pg_catalog', 'pg_toast') AND
               pg_catalog.pg_table_is_visible(c.oid)
               LOOP
        cmd := cmd || rec.name;
END LOOP;

EXECUTE cmd;
RETURN;
END;
$$ LANGUAGE plpgsql;
-- zavolám funkci co odebere tabulky a sekvence - Mohl bych dropnout celé schéma a znovu jej vytvořit, použíjeme však PLSQL
select remove_all();

CREATE TABLE accessory_purchase (
                                    id_accessory SERIAL NOT NULL,
                                    id_service INTEGER NOT NULL,
                                    accessory_type VARCHAR(30) NOT NULL,
                                    special_wrap BOOLEAN NOT NULL
);
ALTER TABLE accessory_purchase ADD CONSTRAINT pk_accessory_purchase PRIMARY KEY (id_accessory);

CREATE TABLE address (
                         id_address SERIAL NOT NULL,
                         id_city INTEGER NOT NULL,
                         building_number INTEGER NOT NULL,
                         street VARCHAR(40) NOT NULL,
                         district VARCHAR(30) NOT NULL,
                         postal_code VARCHAR(15) NOT NULL
);
ALTER TABLE address ADD CONSTRAINT pk_address PRIMARY KEY (id_address);

CREATE TABLE branch (
                        id_branch SERIAL NOT NULL,
                        id_address INTEGER NOT NULL,
                        spare_parts BOOLEAN NOT NULL,
                        building_year INTEGER
);
ALTER TABLE branch ADD CONSTRAINT pk_branch PRIMARY KEY (id_branch);
ALTER TABLE branch ADD CONSTRAINT u_fk_branch_address UNIQUE (id_address);

CREATE TABLE breakdown (
                           id_breakdown SERIAL NOT NULL,
                           breakdown_type VARCHAR(30) NOT NULL
);
ALTER TABLE breakdown ADD CONSTRAINT pk_breakdown PRIMARY KEY (id_breakdown);

CREATE TABLE city (
                      id_city SERIAL NOT NULL,
                      city_name VARCHAR(40) NOT NULL
);
ALTER TABLE city ADD CONSTRAINT pk_city PRIMARY KEY (id_city);

CREATE TABLE employee (
                          id_person INTEGER NOT NULL,
                          id_branch INTEGER NOT NULL,
                          is_subordinated_to INTEGER,
                          employee_position VARCHAR(30) NOT NULL,
                          employee_salary INTEGER NOT NULL,
                          employment_date DATE NOT NULL
);
ALTER TABLE employee ADD CONSTRAINT pk_employee PRIMARY KEY (id_person);
ALTER TABLE employee ADD CONSTRAINT chk_employee_position CHECK (employee_position IN ('Manager', 'Technician')) ;
ALTER TABLE employee ADD CONSTRAINT chk_employee_salary CHECK (employee_salary >= 1000 and employee_salary <= 7000);

CREATE TABLE gadget_repair (
                               gadget_imei INTEGER NOT NULL,
                               id_service INTEGER NOT NULL,
                               manufacturer VARCHAR(20) NOT NULL,
                               gadget_model VARCHAR(20) NOT NULL,
                               release_year INTEGER
);
ALTER TABLE gadget_repair ADD CONSTRAINT pk_gadget_repair PRIMARY KEY (gadget_imei);
ALTER TABLE gadget_repair ADD CONSTRAINT chk_gadget_repair_imei CHECK (gadget_imei > 99999 and gadget_imei < 1000000000);

CREATE TABLE payment (
                         id_payment_type SERIAL NOT NULL,
                         payment_type VARCHAR(30) NOT NULL,
                         printed_invoice BOOLEAN NOT NULL
);
ALTER TABLE payment ADD CONSTRAINT pk_payment PRIMARY KEY (id_payment_type);
ALTER TABLE payment ADD CONSTRAINT chk_payment_type CHECK (payment_type IN ('Bank transfer', 'Cash', 'Card'));

CREATE TABLE person (
                        id_person SERIAL NOT NULL,
                        id_address INTEGER NOT NULL,
                        first_name VARCHAR(30) NOT NULL,
                        last_name VARCHAR(30) NOT NULL,
                        phone VARCHAR(15) NOT NULL,
                        email VARCHAR(40)
);
ALTER TABLE person ADD CONSTRAINT pk_person PRIMARY KEY (id_person);

CREATE TABLE service (
                         id_service SERIAL NOT NULL,
                         id_person INTEGER NOT NULL,
                         id_payment_type INTEGER NOT NULL,
                         service_cost INTEGER NOT NULL,
                         service_date DATE NOT NULL,
                         service_time TIME NOT NULL
);
ALTER TABLE service ADD CONSTRAINT pk_service PRIMARY KEY (id_service);
ALTER TABLE service ADD CONSTRAINT chk_service_date CHECK (service_date >= '2021-01-01');
ALTER TABLE service ADD CONSTRAINT chk_service_time CHECK (service_time >= '9:00' and service_time < '18:00');

CREATE TABLE gadget_repair_breakdown (
                                         gadget_imei INTEGER NOT NULL,
                                         id_breakdown INTEGER NOT NULL
);
ALTER TABLE gadget_repair_breakdown ADD CONSTRAINT pk_gadget_repair_breakdown PRIMARY KEY (gadget_imei, id_breakdown);

CREATE TABLE service_employee (
                                  id_service INTEGER NOT NULL,
                                  id_person INTEGER NOT NULL
);
ALTER TABLE service_employee ADD CONSTRAINT pk_service_employee PRIMARY KEY (id_service, id_person);

ALTER TABLE accessory_purchase ADD CONSTRAINT fk_accessory_purchase_service FOREIGN KEY (id_service) REFERENCES service (id_service) ON DELETE CASCADE;

ALTER TABLE address ADD CONSTRAINT fk_address_city FOREIGN KEY (id_city) REFERENCES city (id_city) ON DELETE CASCADE;

ALTER TABLE branch ADD CONSTRAINT fk_branch_address FOREIGN KEY (id_address) REFERENCES address (id_address) ON DELETE CASCADE;

ALTER TABLE employee ADD CONSTRAINT fk_employee_person FOREIGN KEY (id_person) REFERENCES person (id_person) ON DELETE CASCADE;
ALTER TABLE employee ADD CONSTRAINT fk_employee_branch FOREIGN KEY (id_branch) REFERENCES branch (id_branch) ON DELETE CASCADE;
ALTER TABLE employee ADD CONSTRAINT fk_employee_employee FOREIGN KEY (is_subordinated_to) REFERENCES employee (id_person) ON DELETE CASCADE;

ALTER TABLE gadget_repair ADD CONSTRAINT fk_gadget_repair_service FOREIGN KEY (id_service) REFERENCES service (id_service) ON DELETE CASCADE;

ALTER TABLE person ADD CONSTRAINT fk_person_address FOREIGN KEY (id_address) REFERENCES address (id_address) ON DELETE CASCADE;

ALTER TABLE service ADD CONSTRAINT fk_service_person FOREIGN KEY (id_person) REFERENCES person (id_person) ON DELETE CASCADE;
ALTER TABLE service ADD CONSTRAINT fk_service_payment FOREIGN KEY (id_payment_type) REFERENCES payment (id_payment_type) ON DELETE CASCADE;

ALTER TABLE gadget_repair_breakdown ADD CONSTRAINT fk_gadget_repair_breakdown_gadg FOREIGN KEY (gadget_imei) REFERENCES gadget_repair (gadget_imei) ON DELETE CASCADE;
ALTER TABLE gadget_repair_breakdown ADD CONSTRAINT fk_gadget_repair_breakdown_brea FOREIGN KEY (id_breakdown) REFERENCES breakdown (id_breakdown) ON DELETE CASCADE;

ALTER TABLE service_employee ADD CONSTRAINT fk_service_employee_service FOREIGN KEY (id_service) REFERENCES service (id_service) ON DELETE CASCADE;
ALTER TABLE service_employee ADD CONSTRAINT fk_service_employee_employee FOREIGN KEY (id_person) REFERENCES employee (id_person) ON DELETE CASCADE;

