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
VALUES ('2020-01-20', 'Marcus', 'internet', 500);
INSERT INTO orders (date, fk_customer_name, fk_service, pay)
VALUES ('2020-01-19', 'Marcus', 'TV', 300);
INSERT INTO orders (date, fk_customer_name, fk_service, pay)
VALUES ('2020-02-19', 'Marcus', 'internet', 500);
INSERT INTO orders (date, fk_customer_name, fk_service, pay)
VALUES ('2020-02-19', 'Marcus', 'TV', 300);
INSERT INTO orders (date, fk_customer_name, fk_service, pay)
VALUES ('2020-03-19', 'Marcus', 'internet', 500);
INSERT INTO orders (date, fk_customer_name, fk_service, pay)
VALUES ('2020-03-19', 'Marcus', 'TV', 300);
INSERT INTO orders (date, fk_customer_name, fk_service, pay)
VALUES ('2020-04-19', 'Marcus', 'internet', 500);
INSERT INTO orders (date, fk_customer_name, fk_service, pay)
VALUES ('2020-04-19', 'Marcus', 'TV', 300);
INSERT INTO orders (date, fk_customer_name, fk_service, pay)
VALUES ('2020-05-19', 'Marcus', 'internet', 500);
INSERT INTO orders (date, fk_customer_name, fk_service, pay)
VALUES ('2020-05-19', 'Marcus', 'TV', 300);
INSERT INTO orders (date, fk_customer_name, fk_service, pay)
VALUES ('2020-06-19', 'Marcus', 'internet', 500);
INSERT INTO orders (date, fk_customer_name, fk_service, pay)
VALUES ('2020-06-19', 'Marcus', 'TV', 300);
INSERT INTO orders (date, fk_customer_name, fk_service, pay)
VALUES ('2020-07-19', 'Marcus', 'internet', 500);
INSERT INTO orders (date, fk_customer_name, fk_service, pay)
VALUES ('2020-07-19', 'Marcus', 'TV', 300);

INSERT INTO orders (date, fk_customer_name, fk_service, pay)
VALUES ('2020-06-19', 'Alice', 'internet', 500);
INSERT INTO orders (date, fk_customer_name, fk_service, pay)
VALUES ('2020-07-19', 'Alice', 'internet', 500);

INSERT INTO orders (date, fk_customer_name, fk_service, pay)
VALUES ('2020-06-19', 'Alexandra', 'internet', 500);
INSERT INTO orders (date, fk_customer_name, fk_service, pay)
VALUES ('2020-07-19', 'Alexandra', 'TV', 300);

