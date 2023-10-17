-- PostgreSQL
-- Schema: public
-- Table: user
CREATE TABLE public.user (
    id uuid NOT NULL,
    email character varying(255) NOT NULL,
    username character varying(255) NOT NULL,
    hashed_password character varying(255) NOT NULL,
    status character varying(255) NOT NULL DEFAULT 'pending'::character varying,
    first_name character varying(255) NOT NULL,
    last_name character varying(255) NOT NULL,
    date_of_birth character varying(255) NOT NULL,
    phone_number bigint,
    phone_number_country_code character varying(255),
    address character varying(255) NOT NULL,
    city character varying(255) NOT NULL,
    country character varying(255) NOT NULL,
    zip_code character varying(255) NOT NULL,
    sex character varying(255) NOT NULL,
    createdAt timestamp with time zone NOT NULL,
    updatedAt timestamp with time zone NOT NULL,
    is_active boolean NOT NULL DEFAULT true
);

ALTER TABLE ONLY public.user ADD CONSTRAINT pk_user PRIMARY KEY (id);
ALTER TABLE ONLY public.user ADD CONSTRAINT uk_user_email UNIQUE (email);
ALTER TABLE ONLY public.user ADD CONSTRAINT uk_user_username UNIQUE (username);

-- Table: giveaway
CREATE TABLE public.giveaway (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(255) NOT NULL,
    criteria character varying(255) NOT NULL,
    number_of_winners integer NOT NULL,
    start_date timestamp NOT NULL,
    end_date timestamp NOT NULL,
    createdAt timestamp with time zone NOT NULL,
    updatedAt timestamp with time zone NOT NULL,
    is_active boolean NOT NULL DEFAULT true
);

ALTER TABLE ONLY public.giveaway ADD CONSTRAINT pk_giveaway PRIMARY KEY (id);

-- Table: item_category
CREATE TABLE public.item_category (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(255) NOT NULL,
    createdAt timestamp with time zone NOT NULL,
    updatedAt timestamp with time zone NOT NULL,
    is_active boolean NOT NULL DEFAULT true
);

ALTER TABLE ONLY public.item_category ADD CONSTRAINT pk_item_category PRIMARY KEY (id);
ALTER TABLE ONLY public.item_category ADD CONSTRAINT uk_item_category_name UNIQUE (name);

-- Table: item
CREATE TABLE public.item (
    id uuid NOT NULL,
    category_id uuid NOT NULL,
	name character varying(255) NOT NULL,
    description character varying(255),
    is_new boolean NOT NULL DEFAULT true,
    createdAt timestamp with time zone NOT NULL,
    updatedAt timestamp with time zone NOT NULL,
    is_active boolean NOT NULL DEFAULT true
);

ALTER TABLE ONLY public.item ADD CONSTRAINT pk_item PRIMARY KEY (id);
ALTER TABLE ONLY public.item ADD CONSTRAINT fk_item_category FOREIGN KEY (category_id) 
REFERENCES public.item_category(id) ON UPDATE CASCADE ON DELETE CASCADE;

-- Table: token
CREATE TABLE public.token (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    value integer NOT NULL,
    createdAt timestamp with time zone NOT NULL,
    updatedAt timestamp with time zone NOT NULL,
    is_active boolean NOT NULL DEFAULT true
);

ALTER TABLE ONLY public.token ADD CONSTRAINT pk_token PRIMARY KEY (id);

-- Table: transaction
CREATE TABLE public.transaction (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    item_id uuid NOT NULL,
    token_id uuid NOT NULL,
    type character varying(255) NOT NULL,
    status character varying(255) DEFAULT 'pending'::character varying NOT NULL,
    createdAt timestamp with time zone NOT NULL,
    updatedAt timestamp with time zone NOT NULL,
	is_active boolean NOT NULL DEFAULT true
);

ALTER TABLE ONLY public.transaction ADD CONSTRAINT pk_transaction PRIMARY KEY (id);
ALTER TABLE ONLY public.transaction ADD CONSTRAINT fk_transaction_user FOREIGN KEY (user_id) 
REFERENCES public.user(id) ON DELETE CASCADE;
ALTER TABLE ONLY public.transaction ADD CONSTRAINT fk_transaction_item FOREIGN KEY (item_id) 
REFERENCES public.item(id) ON DELETE CASCADE;
ALTER TABLE ONLY public.transaction ADD CONSTRAINT fk_transaction_token FOREIGN KEY (token_id) 
REFERENCES public.token(id) ON DELETE CASCADE;

-- Table: wallet
CREATE TABLE public.wallet (
    id uuid NOT NULL,
	user_id uuid NOT NULL,
    token_id uuid NOT NULL,
    createdAt timestamp with time zone NOT NULL,
    updatedAt timestamp with time zone NOT NULL,
	is_active boolean NOT NULL DEFAULT true
);

ALTER TABLE ONLY public.wallet ADD CONSTRAINT pk_wallet PRIMARY KEY (id);
ALTER TABLE ONLY public.wallet ADD CONSTRAINT fk_wallet_user FOREIGN KEY (user_id) 
REFERENCES public.user(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.wallet ADD CONSTRAINT fk_wallet_token FOREIGN KEY (token_id) 
REFERENCES public.token(id) ON UPDATE CASCADE ON DELETE CASCADE;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

INSERT INTO public.user (id,email,username,hashed_password,status,first_name,last_name,date_of_birth,phone_number,
						 phone_number_country_code,address,city,country,zip_code,sex,createdAt,updatedAt,is_active)
VALUES (uuid_generate_v4(), 'user1@example.com', 'user1', 'hashed_password1', 'active', 'John', 'Doe', '1990-01-15', 1234567890, '+1', '123 Main St', 'New York', 'USA', '10001', 'Male', NOW(), NOW(), true),
(uuid_generate_v4(), 'user2@example.com', 'user2', 'hashed_password2', 'active', 'Jane', 'Smith', '1985-05-20', 9876543210, '+1', '456 Elm St', 'Los Angeles', 'USA', '90001', 'Female', NOW(), NOW(), true),
(uuid_generate_v4(), 'user3@example.com', 'user3', 'hashed_password3', 'active', 'Alice', 'Johnson', '1988-09-10', 5551234567, '+1', '789 Oak St', 'Chicago', 'USA', '60601', 'Female', NOW(), NOW(), true),
(uuid_generate_v4(), 'user4@example.com', 'user4', 'hashed_password4', 'active', 'Bob', 'Williams', '1980-03-25', 2223334444, '+1', '101 Pine St', 'San Francisco', 'USA', '94101', 'Male', NOW(), NOW(), true),
(uuid_generate_v4(), 'user5@example.com', 'user5', 'hashed_password5', 'active', 'Eva', 'Brown', '1995-12-05', 7778889999, '+1', '222 Maple St', 'Boston', 'USA', '02101', 'Female', NOW(), NOW(), true);

INSERT INTO public.giveaway (id,name,description,criteria,number_of_winners,start_date,end_date,createdAt,updatedAt,is_active)
VALUES (uuid_generate_v4(), 'Summer Sweepstakes', 'Win amazing prizes this summer!', 'Buy products worth $50 or more', 3, NOW(), NOW() + INTERVAL '30 days', NOW(), NOW(), true),
(uuid_generate_v4(), 'Holiday Giveaway', 'Celebrate the holidays with great gifts!', 'Sign up for our newsletter', 2, NOW() + INTERVAL '2 days', NOW() + INTERVAL '1 month', NOW(), NOW(), true),
(uuid_generate_v4(), 'Back to School Contest', 'Get ready for school with our contest!', 'Purchase a school bundle', 4, NOW() - INTERVAL '1 month', NOW() + INTERVAL '10 days', NOW(), NOW(), true),
(uuid_generate_v4(), 'Spring Raffle', 'Welcome spring with fantastic prizes!', 'Share our post on social media', 5, NOW() + INTERVAL '15 days', NOW() + INTERVAL '2 months', NOW(), NOW(), true),
(uuid_generate_v4(), 'New Year Giveaway', 'Start the year with a bang!', 'Refer a friend to our service', 3, NOW() - INTERVAL '6 months', NOW(), NOW(), NOW(), true);

INSERT INTO public.item_category (id,name,description,createdAt,updatedAt,is_active)
VALUES (uuid_generate_v4(), 'Electronics', 'Electronic gadgets and devices', NOW(), NOW(), true),
(uuid_generate_v4(), 'Clothing', 'Fashionable apparel and accessories', NOW(), NOW(), true),
(uuid_generate_v4(), 'Books', 'A wide selection of books', NOW(), NOW(), true),
(uuid_generate_v4(), 'Toys', 'Fun toys for all ages', NOW(), NOW(), true),
(uuid_generate_v4(), 'Home & Garden', 'Home improvement and gardening items', NOW(), NOW(), true);

INSERT INTO public.item (id,category_id,name,description,is_new,createdAt,updatedAt,is_active)
VALUES (uuid_generate_v4(), (select id from public.item_category where name = 'Electronics'), 'Smartphone', 'The latest smartphone model', true, NOW(), NOW(), true),
(uuid_generate_v4(), (select id from public.item_category where name = 'Clothing'), 'Designer Dress', 'Elegant designer dress for special occasions', true, NOW(), NOW(), true),
(uuid_generate_v4(), (select id from public.item_category where name = 'Books'), 'Mystery Novel', 'Bestselling mystery novel', false, NOW(), NOW(), true),
(uuid_generate_v4(), (select id from public.item_category where name = 'Toys'), 'LEGO Set', 'Build amazing structures with this LEGO set', true, NOW(), NOW(), true),
(uuid_generate_v4(), (select id from public.item_category where name = 'Home & Garden'), 'Garden Tools Set', 'Tools for gardening enthusiasts', true, NOW(), NOW(), true);

INSERT INTO public.token (id,name,value,createdAt,updatedAt,is_active)
VALUES (uuid_generate_v4(), 'Gold Token', 100, NOW(), NOW(), true),
(uuid_generate_v4(), 'Silver Token', 50, NOW(), NOW(), true),
(uuid_generate_v4(), 'Bronze Token', 25, NOW(), NOW(), true),
(uuid_generate_v4(), 'Platinum Token', 200, NOW(), NOW(), true),
(uuid_generate_v4(), 'Copper Token', 10, NOW(), NOW(), true);

INSERT INTO public.transaction (id,user_id,item_id,token_id,type,status,createdAt,updatedAt,is_active)
VALUES (uuid_generate_v4(), (select id from public.user where username = 'user1'), (select id from public.item where name = 'Smartphone'), (select id from public.token where name = 'Gold Token'), 'Purchase', 'completed', NOW(), NOW(), true),
(uuid_generate_v4(), (select id from public.user where username = 'user2'), (select id from public.item where name = 'Designer Dress'), (select id from public.token where name = 'Silver Token'), 'Redeem', 'completed', NOW(), NOW(), true),
(uuid_generate_v4(), (select id from public.user where username = 'user3'), (select id from public.item where name = 'Mystery Novel'), (select id from public.token where name = 'Bronze Token'), 'Purchase', 'pending', NOW(), NOW(), true),
(uuid_generate_v4(), (select id from public.user where username = 'user4'), (select id from public.item where name = 'LEGO Set'), (select id from public.token where name = 'Platinum Token'), 'Redeem', 'completed', NOW(), NOW(), true),
(uuid_generate_v4(), (select id from public.user where username = 'user5'), (select id from public.item where name = 'Garden Tools Set'), (select id from public.token where name = 'Copper Token'), 'Purchase', 'completed', NOW(), NOW(), true);

INSERT INTO public.wallet (id,user_id,token_id,createdAt,updatedAt,is_active)
VALUES (uuid_generate_v4(), (select id from public.user where username = 'user1'), (select id from public.token where name = 'Gold Token'), NOW(), NOW(), true),
(uuid_generate_v4(), (select id from public.user where username = 'user2'), (select id from public.token where name = 'Silver Token'), NOW(), NOW(), true),
(uuid_generate_v4(), (select id from public.user where username = 'user3'), (select id from public.token where name = 'Bronze Token'), NOW(), NOW(), true),
(uuid_generate_v4(), (select id from public.user where username = 'user4'), (select id from public.token where name = 'Platinum Token'), NOW(), NOW(), true),
(uuid_generate_v4(), (select id from public.user where username = 'user5'), (select id from public.token where name = 'Copper Token'), NOW(), NOW(), true);
