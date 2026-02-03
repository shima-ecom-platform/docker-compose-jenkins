--
-- PostgreSQL database dump
--

\restrict 2b623eU5MZ2csdhtZuchRZMG0gtDuVqoa3JeVDlgZjkk5xNN0mYynd6YesZGrzt

-- Dumped from database version 15.15
-- Dumped by pg_dump version 15.15

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: products; Type: TABLE; Schema: public; Owner: phase1_user
--

CREATE TABLE public.products (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    price numeric(10,2) NOT NULL,
    stock integer DEFAULT 0,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.products OWNER TO phase1_user;

--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: phase1_user
--

CREATE SEQUENCE public.products_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.products_id_seq OWNER TO phase1_user;

--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: phase1_user
--

ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: phase1_user
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username character varying(50) NOT NULL,
    email character varying(100) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.users OWNER TO phase1_user;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: phase1_user
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO phase1_user;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: phase1_user
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: products id; Type: DEFAULT; Schema: public; Owner: phase1_user
--

ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: phase1_user
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: phase1_user
--

COPY public.products (id, name, description, price, stock, created_at) FROM stdin;
1	サンプル商品A	これはテスト用の商品です	1000.00	10	2026-01-17 23:23:20.944769
2	サンプル商品B	Docker学習用サンプル	2000.00	5	2026-01-17 23:23:20.944769
3	サンプル商品C	PostgreSQL連携テスト	1500.00	20	2026-01-17 23:23:20.944769
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: phase1_user
--

COPY public.users (id, username, email, created_at) FROM stdin;
1	test_user1	user1@example.com	2026-01-17 23:23:20.942851
2	test_user2	user2@example.com	2026-01-17 23:23:20.942851
3	admin	admin@example.com	2026-01-17 23:23:20.942851
\.


--
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: phase1_user
--

SELECT pg_catalog.setval('public.products_id_seq', 3, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: phase1_user
--

SELECT pg_catalog.setval('public.users_id_seq', 3, true);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: phase1_user
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: phase1_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: phase1_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: phase1_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: idx_products_name; Type: INDEX; Schema: public; Owner: phase1_user
--

CREATE INDEX idx_products_name ON public.products USING btree (name);


--
-- Name: idx_users_email; Type: INDEX; Schema: public; Owner: phase1_user
--

CREATE INDEX idx_users_email ON public.users USING btree (email);


--
-- PostgreSQL database dump complete
--

\unrestrict 2b623eU5MZ2csdhtZuchRZMG0gtDuVqoa3JeVDlgZjkk5xNN0mYynd6YesZGrzt

