DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS services;
DROP TABLE IF EXISTS customers;

create table customers
(
    customer_id    serial             not null,
    customer_login varchar default 20 not null
);
create unique index customers_customer_id_uindex
    on customers (customer_id);
create unique index customers_customer_login_uindex
    on customers (customer_login);
alter table customers
    add constraint customers_pk
        primary key (customer_id);

-- выставляем данные в customers table
INSERT INTO customers(customer_id, customer_login)
VALUES (DEFAULT, 'Marcus'),
       (DEFAULT, 'Ilya'),
       (DEFAULT, 'Alice'),
       (DEFAULT, 'Alex'),
       (DEFAULT, 'Bob'),
       (DEFAULT, 'John'),
       (DEFAULT, 'Alexandra');


-------------- вторая табличка --------------

create table services
(
    service_id   serial             not null,
    service_name varchar default 20 not null
);

create unique index services_service_id_uindex
    on services (service_id);

create unique index services_service_name_uindex
    on services (service_name);

alter table services
    add constraint services_pk
        primary key (service_id);

-- выставляем данные в services table
INSERT INTO services(service_id, service_name)
VALUES (DEFAULT, 'internet'),
       (DEFAULT, 'TV');


-------------- третья табличка --------------

create table orders
(
    order_number     serial                                        NOT NULL,
    date             timestamp                                     NOT NULL,
    fk_customer_name varchar REFERENCES customers (customer_login) NOT NULL,
    fk_service       varchar REFERENCES services (service_name)    NOT NULL,
    pay              integer                                       NOT NULL
);

create unique index orders_order_number_uindex
    on orders (order_number);

alter table orders
    add constraint orders_pk
        primary key (order_number);

-- выставляем данные в orders table
INSERT INTO orders (date, fk_customer_name, fk_service, pay)
VALUES ('2019-12-19', 'Marcus', 'internet', 500);
INSERT INTO orders (date, fk_customer_name, fk_service, pay)
VALUES ('2019-12-19', 'Marcus', 'TV', 300);
INSERT INTO orders (date, fk_customer_name, fk_service, pay)
VALUES ('2020-07-19', 'Marcus', 'internet', 500);
INSERT INTO orders (date, fk_customer_name, fk_service, pay)
VALUES ('2020-07-19', 'Marcus', 'TV', 300);

INSERT INTO orders (date, fk_customer_name, fk_service, pay)
VALUES ('2020-06-19', 'Ilya', 'internet', 500);
INSERT INTO orders (date, fk_customer_name, fk_service, pay)
VALUES ('2020-07-19', 'Ilya', 'TV', 300);

INSERT INTO orders (date, fk_customer_name, fk_service, pay)
VALUES ('2020-06-05', 'Alice', 'internet', 500);
INSERT INTO orders (date, fk_customer_name, fk_service, pay)
VALUES ('2020-07-23', 'Alice', 'internet', 500);

INSERT INTO orders (date, fk_customer_name, fk_service, pay)
VALUES ('2020-06-29', 'Alex', 'internet', 500);
INSERT INTO orders (date, fk_customer_name, fk_service, pay)
VALUES ('2020-07-05', 'Alex', 'TV', 300);

INSERT INTO orders (date, fk_customer_name, fk_service, pay)
VALUES ('2020-06-11', 'Bob', 'internet', 500);
INSERT INTO orders (date, fk_customer_name, fk_service, pay)
VALUES ('2020-07-12', 'Bob', 'TV', 300);

INSERT INTO orders (date, fk_customer_name, fk_service, pay)
VALUES ('2020-06-13', 'John', 'internet', 500);
INSERT INTO orders (date, fk_customer_name, fk_service, pay)
VALUES ('2020-07-15', 'John', 'TV', 300);

INSERT INTO orders (date, fk_customer_name, fk_service, pay)
VALUES ('2020-06-18', 'Alexandra', 'internet', 500);
INSERT INTO orders (date, fk_customer_name, fk_service, pay)
VALUES ('2020-07-27', 'Alexandra', 'TV', 300);



------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS make_order(data_time timestamp without time zone, name character varying, service character varying, pay_int integer);
create function make_order(data_time timestamp without time zone, name character varying, service character varying, pay_int integer)
    returns TABLE("like" orders)
    language plpgsql
as
$$
BEGIN
    INSERT INTO orders(date, fk_customer_name, fk_service, pay)
    VALUES (data_time, name, service,pay_int);
    RETURN QUERY SELECT * FROM orders WHERE fk_customer_name = (name) AND date = (data_time) ORDER BY order_number;
END;
$$;
alter function make_order(timestamp, varchar, varchar, integer) owner to postgres;

------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS select_orders();
CREATE FUNCTION select_orders() RETURNS TABLE ("like" orders)
AS
$$
BEGIN
    RETURN QUERY SELECT * FROM orders ORDER BY order_number;
END;
$$ STABLE LANGUAGE plpgsql;

------------------------------------------------------------------------------

CREATE FUNCTION select_orders(name varchar) RETURNS TABLE ("like" orders)
AS
$$
BEGIN
    RETURN QUERY SELECT * FROM orders WHERE fk_customer_name = (name) ORDER BY order_number;
END;
$$ STABLE LANGUAGE plpgsql;

------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS select_orders(name varchar, data_time timestamp);
CREATE FUNCTION select_orders(name varchar, data_time timestamp)
    RETURNS TABLE ("like" orders)
AS
$$
BEGIN
    RETURN QUERY SELECT * FROM orders WHERE fk_customer_name = (name) AND date = (data_time) ORDER BY order_number;
END;
$$ STABLE LANGUAGE plpgsql;

--- 2020-07-24 12:23:42.210282
SELECT select_orders('Bob', '2020-07-24 12:23:42.210282');