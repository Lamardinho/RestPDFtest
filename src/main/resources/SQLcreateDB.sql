DROP TABLE IF EXISTS staff;

CREATE TABLE public.staff
(
    employee_id            serial,
    employee_name          character varying(50) NOT NULL,
    employee_position      character varying(50) NOT NULL,
    employee_phone         bigint                NOT NULL,
    employee_data_birthday date                  NOT NULL,
    CONSTRAINT pk_employee_id PRIMARY KEY (employee_id)
);

ALTER TABLE public.staff
    OWNER to postgres;

INSERT INTO staff(employee_name, employee_position, employee_phone, employee_data_birthday)
VALUES ('Marcus Prince', 'Developer', 89027994023, '1987-04-23'),
       ('Илья Слёзкин', 'Разработчик', 89630165023, '1987-04-16');

INSERT INTO staff(employee_name, employee_position, employee_phone, employee_data_birthday)
VALUES ('Harry Potter', 'Magic Developer', 89999999999, '1980-07-31');

--SELECT * FROM staff;

/*CREATE TABLE public.orders
(
    order_id               serial,
    order_date             date,
    CONSTRAINT pk_employee_id PRIMARY KEY (order_id)
);*/