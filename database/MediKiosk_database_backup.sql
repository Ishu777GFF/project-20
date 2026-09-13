--
-- PostgreSQL database dump
--

\restrict dGTLfuBArNVfosm9prw0Vlcf35bBFefeZJNn0Yg57WVkLdHrNm9k0ZU8Li3uemg

-- Dumped from database version 18.6
-- Dumped by pg_dump version 18.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: ConsentType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."ConsentType" AS ENUM (
    'history_collection',
    'document_processing',
    'mock_abdm_sharing'
);


--
-- Name: InputMode; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."InputMode" AS ENUM (
    'TOUCH',
    'TEXT',
    'VOICE'
);


--
-- Name: Priority; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."Priority" AS ENUM (
    'NORMAL',
    'URGENT'
);


--
-- Name: Role; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."Role" AS ENUM (
    'PATIENT',
    'DOCTOR',
    'NURSE',
    'ADMIN'
);


--
-- Name: SummaryStatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."SummaryStatus" AS ENUM (
    'PENDING',
    'CONFIRMED',
    'REJECTED'
);


--
-- Name: VisitMode; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."VisitMode" AS ENUM (
    'GENERAL',
    'AYUSH'
);


--
-- Name: VisitStatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."VisitStatus" AS ENUM (
    'IN_PROGRESS',
    'READY_FOR_REVIEW',
    'REVIEWED'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: _prisma_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public._prisma_migrations (
    id character varying(36) NOT NULL,
    checksum character varying(64) NOT NULL,
    finished_at timestamp with time zone,
    migration_name character varying(255) NOT NULL,
    logs text,
    rolled_back_at timestamp with time zone,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    applied_steps_count integer DEFAULT 0 NOT NULL
);


--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_logs (
    id uuid NOT NULL,
    actor text NOT NULL,
    action text NOT NULL,
    resource_type text NOT NULL,
    resource_id text NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: clinical_summaries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.clinical_summaries (
    id uuid NOT NULL,
    visit_id uuid NOT NULL,
    summary_text text NOT NULL,
    status public."SummaryStatus" DEFAULT 'PENDING'::public."SummaryStatus" NOT NULL,
    version integer DEFAULT 1 NOT NULL,
    reviewer text,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: consents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.consents (
    id uuid NOT NULL,
    visit_id uuid NOT NULL,
    type public."ConsentType" NOT NULL,
    granted boolean DEFAULT true NOT NULL,
    version text DEFAULT 'v1.0'::text NOT NULL,
    granted_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: document_entities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.document_entities (
    id uuid NOT NULL,
    document_id uuid NOT NULL,
    entity_type text NOT NULL,
    name text NOT NULL,
    value text,
    unit text,
    abnormal boolean DEFAULT false NOT NULL
);


--
-- Name: documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.documents (
    id uuid NOT NULL,
    visit_id uuid NOT NULL,
    filename text NOT NULL,
    type text NOT NULL,
    ocr_status text NOT NULL,
    extracted_text text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: history_answers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.history_answers (
    id uuid NOT NULL,
    visit_id uuid NOT NULL,
    question_id text NOT NULL,
    label text NOT NULL,
    answer text NOT NULL,
    input_mode public."InputMode" DEFAULT 'TOUCH'::public."InputMode" NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: patients; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.patients (
    id uuid NOT NULL,
    full_name text NOT NULL,
    dob date,
    gender text,
    phone text,
    abha_id text NOT NULL,
    preferred_language text DEFAULT 'en'::text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    access_code text,
    password_hash text
);


--
-- Name: red_flags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.red_flags (
    id uuid NOT NULL,
    visit_id uuid NOT NULL,
    rule_id text NOT NULL,
    severity text NOT NULL,
    message text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid NOT NULL,
    name text NOT NULL,
    role public."Role" NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    access_code text,
    password_hash text
);


--
-- Name: visits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.visits (
    id uuid NOT NULL,
    patient_id uuid NOT NULL,
    mode public."VisitMode" NOT NULL,
    status public."VisitStatus" DEFAULT 'IN_PROGRESS'::public."VisitStatus" NOT NULL,
    priority public."Priority" DEFAULT 'NORMAL'::public."Priority" NOT NULL,
    started_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "completedAt" timestamp(3) without time zone
);


--
-- Data for Name: _prisma_migrations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) FROM stdin;
5151674e-a947-4fca-b696-b34f1e524b19	d3d95c5a2ffd40224afa9e0ba557ce3f47230f579786db111106e8f799d360fe	2026-09-12 23:45:12.370821+05:30	20260912181512_init	\N	\N	2026-09-12 23:45:12.336751+05:30	1
f591508e-76f9-4c01-9f64-37b15c673a4f	3a32a6b429af9e635ba09f89662ce1a5948e73a824a252c4d535644f72b37a25	2026-09-13 15:36:46.456252+05:30	20260913152000_local_account_auth	\N	\N	2026-09-13 15:36:46.446658+05:30	1
\.


--
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.audit_logs (id, actor, action, resource_type, resource_id, metadata, created_at) FROM stdin;
cabc9eca-80ba-4281-8687-55aa3c83a50e	system	SEEDED_DEMO_CASE	visit	7c43581b-4a8d-4aa7-b706-2c9fcdebe2c3	{}	2026-09-12 18:15:20.857
06e3d8d1-18cf-4261-95a3-e314c57472aa	patient-kiosk	REGISTERED_AND_CONSENTED	visit	20b32d23-3f26-4c05-9403-9c7a577a7850	{"mode": "GENERAL"}	2026-09-12 18:15:21.796
016e5b61-05ec-4eaf-8d81-fd6ba69dc7ac	patient-kiosk	MOCK_OCR_PROCESSED	document	edefb0d4-0930-44b4-aed5-fa0ee60307fa	{"filename": "previous_lab_report.pdf"}	2026-09-12 18:15:21.796
ac4b6695-ee87-4408-afe6-fad485337dce	patient-kiosk	SUMMARY_GENERATED	visit	20b32d23-3f26-4c05-9403-9c7a577a7850	{}	2026-09-12 18:15:21.796
5dfd7c91-4088-4a17-b625-a37c4e8f47c5	patient-kiosk	REGISTERED_AND_CONSENTED	visit	25873caf-7569-482c-8dee-15ae7a53f13d	{"mode": "GENERAL", "consents": ["history_collection", "document_processing", "mock_abdm_sharing"]}	2026-09-12 18:17:48.34
3b26b84c-df5d-40f4-a311-46a3999b3621	patient-kiosk	ANSWER_RECORDED	visit	25873caf-7569-482c-8dee-15ae7a53f13d	{"input": "TEXT", "question": "chief"}	2026-09-12 18:18:03.864
28059a6e-5f3b-4a9d-b877-e72d755a1de6	patient-kiosk	ANSWER_RECORDED	visit	25873caf-7569-482c-8dee-15ae7a53f13d	{"input": "TOUCH", "question": "duration"}	2026-09-12 18:18:28.065
f135f035-8d46-4288-9a51-e8eb83eb1927	patient-kiosk	ANSWER_RECORDED	visit	25873caf-7569-482c-8dee-15ae7a53f13d	{"input": "TOUCH", "question": "severity"}	2026-09-12 18:18:45.472
e5f4c21c-d2a5-4b77-8a1d-0c539d07c859	patient-kiosk	ANSWER_RECORDED	visit	25873caf-7569-482c-8dee-15ae7a53f13d	{"input": "TOUCH", "question": "breathlessness"}	2026-09-12 18:19:00.165
ef30db04-7c96-42cd-921d-500482ad25c1	patient-kiosk	ANSWER_RECORDED	visit	25873caf-7569-482c-8dee-15ae7a53f13d	{"input": "TOUCH", "question": "sweating"}	2026-09-12 18:19:08.459
4c5167fe-c6ce-49fb-a692-dfc81b1874d5	patient-kiosk	ANSWER_RECORDED	visit	25873caf-7569-482c-8dee-15ae7a53f13d	{"input": "TEXT", "question": "history"}	2026-09-12 18:19:24.467
86831749-3148-463a-bb9d-1dc560ab7274	patient-kiosk	MOCK_OCR_PROCESSED	document	09296dab-a428-4345-8aa7-9127a289c67a	{"filename": "previous_report.pdf"}	2026-09-12 18:19:45.591
84ecf56c-e92c-4d2a-80c4-9aae8851cb92	patient-kiosk	SUMMARY_GENERATED	visit	25873caf-7569-482c-8dee-15ae7a53f13d	{}	2026-09-12 18:19:55.207
1bd03a78-de00-4dd8-b2b5-0b7667041741	Dr. Ananya Rao	VIEWED_CASE	visit	20b32d23-3f26-4c05-9403-9c7a577a7850	{}	2026-09-12 18:20:16.017
7c553f97-467a-4663-9ecb-9d3aa8c7be19	Dr. Ananya Rao	SUMMARY_CONFIRMED	visit	20b32d23-3f26-4c05-9403-9c7a577a7850	{}	2026-09-12 18:20:37.657
8bf0e31c-5560-4d88-8f15-93a3f1a63b92	Dr. Ananya Rao	VIEWED_CASE	visit	20b32d23-3f26-4c05-9403-9c7a577a7850	{}	2026-09-12 18:20:37.731
e22f5fbd-20ee-4c38-bb94-8c486d2b2d02	Dr. Ananya Rao	SUMMARY_CONFIRMED	visit	20b32d23-3f26-4c05-9403-9c7a577a7850	{}	2026-09-12 18:21:15.691
f6b0fe3f-b949-4c9f-a193-22af42123184	Dr. Ananya Rao	VIEWED_CASE	visit	20b32d23-3f26-4c05-9403-9c7a577a7850	{}	2026-09-12 18:21:15.705
72efdddb-4bb4-4d22-bc0e-a3af554c2f7d	Dr. Ananya Rao	SUMMARY_CONFIRMED	visit	20b32d23-3f26-4c05-9403-9c7a577a7850	{}	2026-09-12 18:21:20.479
67d1f477-fc99-44d3-b59a-c142244f3db8	Dr. Ananya Rao	VIEWED_CASE	visit	20b32d23-3f26-4c05-9403-9c7a577a7850	{}	2026-09-12 18:21:20.491
2674900e-2d75-4a91-88d4-00fcaef8b2fd	Dr. Ananya Rao	VIEWED_CASE	visit	20b32d23-3f26-4c05-9403-9c7a577a7850	{}	2026-09-12 18:23:25.867
6c16b4e4-72b1-42c2-b6e6-184d9ace32cd	patient-kiosk	REGISTERED_AND_CONSENTED	visit	fc169399-15ff-4e25-ac5f-f4dad0083c72	{"mode": "GENERAL", "consents": ["history_collection", "document_processing", "mock_abdm_sharing"]}	2026-09-12 18:23:48.622
5f367527-904d-4f3d-91a7-a3313ba15b24	patient-kiosk	ANSWER_RECORDED	visit	fc169399-15ff-4e25-ac5f-f4dad0083c72	{"input": "VOICE", "question": "chief"}	2026-09-12 18:23:48.673
d7198403-d1b9-44fc-85c0-1ab23c54bc63	patient-kiosk	ANSWER_RECORDED	visit	fc169399-15ff-4e25-ac5f-f4dad0083c72	{"input": "VOICE", "question": "duration"}	2026-09-12 18:23:48.708
0e13d783-a624-4d5b-a098-7cf02b30f912	patient-kiosk	ANSWER_RECORDED	visit	fc169399-15ff-4e25-ac5f-f4dad0083c72	{"input": "VOICE", "question": "severity"}	2026-09-12 18:23:48.75
c6adf66f-8f8a-4ba5-8b0c-fcfa7a9d6274	patient-kiosk	ANSWER_RECORDED	visit	fc169399-15ff-4e25-ac5f-f4dad0083c72	{"input": "VOICE", "question": "breathlessness"}	2026-09-12 18:23:48.81
c046bc1b-22a2-49c2-b78f-aaa3d0e6364f	patient-kiosk	ANSWER_RECORDED	visit	fc169399-15ff-4e25-ac5f-f4dad0083c72	{"input": "VOICE", "question": "sweating"}	2026-09-12 18:23:48.85
ab588698-97af-45cf-bf22-9644a601d09b	patient-kiosk	ANSWER_RECORDED	visit	fc169399-15ff-4e25-ac5f-f4dad0083c72	{"input": "VOICE", "question": "history"}	2026-09-12 18:23:48.878
143d4d53-d82a-441f-aeb1-cd3a6de35b44	patient-kiosk	SUMMARY_GENERATED	visit	fc169399-15ff-4e25-ac5f-f4dad0083c72	{}	2026-09-12 18:23:59.013
c86df277-a5bc-4e07-b821-6b3c116da348	patient-kiosk	REGISTERED_AND_CONSENTED	visit	789dca42-ac4c-4e92-8b63-c3bcc445beec	{"mode": "AYUSH", "consents": ["history_collection", "document_processing", "mock_abdm_sharing"]}	2026-09-12 18:25:22.202
c19541f8-7bf3-40f7-beb1-57710b1f77a3	patient-kiosk	ANSWER_RECORDED	visit	789dca42-ac4c-4e92-8b63-c3bcc445beec	{"input": "TEXT", "question": "chief"}	2026-09-12 18:25:44.167
84860718-6871-4663-988f-13affcbc61e2	patient-kiosk	ANSWER_RECORDED	visit	789dca42-ac4c-4e92-8b63-c3bcc445beec	{"input": "TOUCH", "question": "duration"}	2026-09-12 18:25:46.898
594fbd20-d4e6-4f0a-86b7-c84cad9cbc20	patient-kiosk	ANSWER_RECORDED	visit	789dca42-ac4c-4e92-8b63-c3bcc445beec	{"input": "TOUCH", "question": "prakriti"}	2026-09-12 18:25:55.502
de47a24d-77a4-43c6-96e0-f3268bafda38	patient-kiosk	REGISTERED_AND_CONSENTED	visit	8f870d55-2f09-4dbc-8679-949faad408cc	{"mode": "GENERAL", "consents": ["history_collection", "document_processing", "mock_abdm_sharing"]}	2026-09-12 18:32:22.064
44119b50-d096-42ad-95bc-44fc1567bedc	patient-kiosk	ANSWER_RECORDED	visit	8f870d55-2f09-4dbc-8679-949faad408cc	{"input": "VOICE", "question": "chief"}	2026-09-12 18:32:22.088
413b0337-91e1-4b87-8994-118291dbb94f	patient-kiosk	ANSWER_RECORDED	visit	8f870d55-2f09-4dbc-8679-949faad408cc	{"input": "VOICE", "question": "duration"}	2026-09-12 18:32:22.101
f6af0046-9074-4b0b-80d6-e5788f2be5b0	patient-kiosk	ANSWER_RECORDED	visit	8f870d55-2f09-4dbc-8679-949faad408cc	{"input": "VOICE", "question": "severity"}	2026-09-12 18:32:22.113
ad15f66f-16ee-4606-905d-201c2d0306e7	patient-kiosk	ANSWER_RECORDED	visit	8f870d55-2f09-4dbc-8679-949faad408cc	{"input": "VOICE", "question": "breathlessness"}	2026-09-12 18:32:22.126
a6f3b882-9f06-4875-aea4-55da71c94511	patient-kiosk	ANSWER_RECORDED	visit	8f870d55-2f09-4dbc-8679-949faad408cc	{"input": "VOICE", "question": "sweating"}	2026-09-12 18:32:22.14
093de2e9-d86c-4fb9-a3f8-29e5bcb2014f	patient-kiosk	ANSWER_RECORDED	visit	8f870d55-2f09-4dbc-8679-949faad408cc	{"input": "VOICE", "question": "history"}	2026-09-12 18:32:22.153
8b8e7f28-aa66-4544-b6b9-8d8367a17e13	patient-kiosk	MOCK_OCR_PROCESSED	document	546eff00-bcc4-489c-b678-ac545432d1a3	{"filename": "app.js"}	2026-09-12 18:33:17.64
256fc4e3-3bab-43e7-b07e-3944e57e46c7	patient-kiosk	MOCK_OCR_PROCESSED	document	4e7515c6-0c9e-4d6e-9ff3-1b3a1373d3ca	{"filename": "app.js"}	2026-09-12 18:33:19.442
9f09ba82-b021-401c-91fa-ba41e9c03455	patient-kiosk	MOCK_OCR_PROCESSED	document	18f940ff-1a13-4d4c-8867-46f7712d4be3	{"filename": "app.js"}	2026-09-12 18:33:24.165
a3c8676f-5758-42be-990f-be17150b94ac	patient-kiosk	SUMMARY_GENERATED	visit	8f870d55-2f09-4dbc-8679-949faad408cc	{}	2026-09-12 18:33:25.021
168aa661-6d35-4785-a6dc-f6ddb9454a39	Dr. Ananya Rao	VIEWED_CASE	visit	8f870d55-2f09-4dbc-8679-949faad408cc	{}	2026-09-12 18:33:29.842
44a8ede0-957d-4a1f-af18-fe8b8c388c9d	Dr. Ananya Rao	VIEWED_CASE	visit	25873caf-7569-482c-8dee-15ae7a53f13d	{}	2026-09-12 18:34:12.918
9a2f5353-315f-405f-b770-1ee60dcdc1b9	Dr. Ananya Rao	VIEWED_CASE	visit	7c43581b-4a8d-4aa7-b706-2c9fcdebe2c3	{}	2026-09-12 18:36:48.93
6dde414f-686b-4643-8410-0eb203e4a5be	patient-kiosk	REGISTERED_AND_CONSENTED	visit	e059bba2-29d2-4bef-b754-2197280b43a4	{"mode": "GENERAL", "consents": ["history_collection", "document_processing", "mock_abdm_sharing"]}	2026-09-12 18:39:44.5
a2fee1c2-eb26-4f7b-b188-a392cc4b42a4	patient-kiosk	ANSWER_RECORDED	visit	e059bba2-29d2-4bef-b754-2197280b43a4	{"input": "TEXT", "question": "chief"}	2026-09-12 18:39:53.472
2fbd59e9-4397-4f65-8487-375c931f837b	patient-kiosk	ANSWER_RECORDED	visit	e059bba2-29d2-4bef-b754-2197280b43a4	{"input": "TOUCH", "question": "duration"}	2026-09-12 18:39:55.232
c6a4da72-7558-48b7-98cb-fad608695d77	patient-kiosk	ANSWER_RECORDED	visit	e059bba2-29d2-4bef-b754-2197280b43a4	{"input": "TOUCH", "question": "severity"}	2026-09-12 18:39:59.281
c2a92b5a-18c4-47da-851e-e6f5ff458b68	patient-kiosk	ANSWER_RECORDED	visit	e059bba2-29d2-4bef-b754-2197280b43a4	{"input": "TOUCH", "question": "breathlessness"}	2026-09-12 18:40:04.065
f542eb6e-0e4c-4d9f-b112-48e45d5e6427	patient-kiosk	ANSWER_RECORDED	visit	e059bba2-29d2-4bef-b754-2197280b43a4	{"input": "TOUCH", "question": "sweating"}	2026-09-12 18:40:06.074
ed2527aa-17ac-455f-b28c-8cfddbd4da63	patient-kiosk	ANSWER_RECORDED	visit	e059bba2-29d2-4bef-b754-2197280b43a4	{"input": "TEXT", "question": "history"}	2026-09-12 18:40:57.63
9c71051c-abdf-41cc-b83f-371d380b4b4e	patient-kiosk	SUMMARY_GENERATED	visit	e059bba2-29d2-4bef-b754-2197280b43a4	{}	2026-09-12 18:41:04.72
b34af95a-969c-4ce9-9404-6701f17a6a2b	Dr. Ananya Rao	VIEWED_CASE	visit	e059bba2-29d2-4bef-b754-2197280b43a4	{}	2026-09-12 18:41:09.838
bb8afb70-3ef6-4371-a761-1814840e894e	patient-kiosk	REGISTERED_AND_CONSENTED	visit	2686b519-aaa2-4f4b-95a8-df3598f810a4	{"mode": "GENERAL", "consents": ["history_collection", "document_processing", "mock_abdm_sharing"]}	2026-09-12 19:33:46.445
b6905233-f151-469b-bd02-8860bcd7a108	patient-kiosk	ANSWER_RECORDED	visit	2686b519-aaa2-4f4b-95a8-df3598f810a4	{"input": "TEXT", "question": "chief"}	2026-09-12 19:34:00.553
ca99bf60-79a8-402c-b71e-bd761a809ce9	patient-kiosk	ANSWER_RECORDED	visit	2686b519-aaa2-4f4b-95a8-df3598f810a4	{"input": "TOUCH", "question": "duration"}	2026-09-12 19:34:03.195
04da7621-5fc1-4268-8036-bd5c7fd3d491	patient-kiosk	ANSWER_RECORDED	visit	2686b519-aaa2-4f4b-95a8-df3598f810a4	{"input": "TOUCH", "question": "severity"}	2026-09-12 19:34:07.556
7c8be0ab-22ec-4071-b511-4758cf351444	patient-kiosk	ANSWER_RECORDED	visit	2686b519-aaa2-4f4b-95a8-df3598f810a4	{"input": "TOUCH", "question": "breathlessness"}	2026-09-12 19:34:10.029
83a8f197-0ab9-485c-a9a1-5cdc712b15a0	patient-kiosk	ANSWER_RECORDED	visit	2686b519-aaa2-4f4b-95a8-df3598f810a4	{"input": "TOUCH", "question": "sweating"}	2026-09-12 19:34:11.425
928f5240-f1d7-4f21-b458-f461135c8968	patient-kiosk	ANSWER_RECORDED	visit	2686b519-aaa2-4f4b-95a8-df3598f810a4	{"input": "TEXT", "question": "history"}	2026-09-12 19:34:48.631
7dd28b80-67fd-4f9e-8dec-17614d7a72ce	patient-kiosk	SUMMARY_GENERATED	visit	2686b519-aaa2-4f4b-95a8-df3598f810a4	{}	2026-09-12 19:34:52.476
d89cd8c2-18e2-4301-96b3-7fd4c53b947d	Dr. Ananya Rao	VIEWED_CASE	visit	2686b519-aaa2-4f4b-95a8-df3598f810a4	{}	2026-09-12 19:34:59.859
cfd4ab04-0eae-4915-b195-e2135950184f	Dr. Ananya Rao	VIEWED_CASE	visit	fc169399-15ff-4e25-ac5f-f4dad0083c72	{}	2026-09-12 19:42:56.665
edfdcf97-3a44-4579-a825-0b24645c4ed3	patient-kiosk	REGISTERED_AND_CONSENTED	visit	6c954f15-d274-4366-b762-3bfd95975eaa	{"mode": "GENERAL", "consents": ["history_collection", "document_processing", "mock_abdm_sharing"]}	2026-09-13 07:19:54.33
897c0d37-4cf3-4b8a-9238-7cb472129e7f	patient-kiosk	ANSWER_RECORDED	visit	6c954f15-d274-4366-b762-3bfd95975eaa	{"input": "TEXT", "question": "chief"}	2026-09-13 07:20:03.838
acfedddd-e567-4a4d-a5e2-8772ad598966	patient-kiosk	ANSWER_RECORDED	visit	6c954f15-d274-4366-b762-3bfd95975eaa	{"input": "TOUCH", "question": "duration"}	2026-09-13 07:20:06.201
6818fbf9-4a07-4e35-9d7f-7160201ff5eb	patient-kiosk	ANSWER_RECORDED	visit	6c954f15-d274-4366-b762-3bfd95975eaa	{"input": "TOUCH", "question": "severity"}	2026-09-13 07:20:09.591
b34f0a25-c615-49f4-89a0-c7092e9a1129	patient-kiosk	ANSWER_RECORDED	visit	6c954f15-d274-4366-b762-3bfd95975eaa	{"input": "TOUCH", "question": "breathlessness"}	2026-09-13 07:20:13.202
7c739df0-ba7e-409a-98d3-e3d7508e73ad	patient-kiosk	ANSWER_RECORDED	visit	6c954f15-d274-4366-b762-3bfd95975eaa	{"input": "TOUCH", "question": "sweating"}	2026-09-13 07:20:15.326
e983126a-bb33-4b52-8f93-aa7d2cb519da	patient-kiosk	ANSWER_RECORDED	visit	6c954f15-d274-4366-b762-3bfd95975eaa	{"input": "TEXT", "question": "history"}	2026-09-13 07:20:34.771
f7653c3f-f9eb-4b72-81c8-3a241e9852a0	patient-kiosk	SUMMARY_GENERATED	visit	6c954f15-d274-4366-b762-3bfd95975eaa	{}	2026-09-13 07:20:46.506
f3a9aeb2-ca86-4389-a433-919f451298c1	Dr. Ananya Rao	VIEWED_CASE	visit	6c954f15-d274-4366-b762-3bfd95975eaa	{}	2026-09-13 07:20:50.443
1b057688-82dc-4f8b-b432-854f89809861	Dr. Ananya Rao	VIEWED_CASE	visit	8f870d55-2f09-4dbc-8679-949faad408cc	{}	2026-09-13 07:21:12.184
a0d866b7-2929-4a9e-b7ee-7f2f34e7696e	patient-kiosk	REGISTERED_AND_CONSENTED	visit	e03c38b5-ea4d-495a-a2e6-e37e9b2fdae1	{"mode": "AYUSH", "consents": ["history_collection", "document_processing", "mock_abdm_sharing"]}	2026-09-13 07:22:39.409
e2dfed7d-0cf7-4a2f-8f7d-2e63b04d0b66	patient-kiosk	ANSWER_RECORDED	visit	e03c38b5-ea4d-495a-a2e6-e37e9b2fdae1	{"input": "TEXT", "question": "chief"}	2026-09-13 07:23:40.035
4c2ea3e4-1013-44d8-aaae-e3207538de26	patient-kiosk	ANSWER_RECORDED	visit	e03c38b5-ea4d-495a-a2e6-e37e9b2fdae1	{"input": "TOUCH", "question": "duration"}	2026-09-13 07:23:41.654
0e29df11-3b16-4ce4-a157-235ceb39276c	patient-kiosk	ANSWER_RECORDED	visit	e03c38b5-ea4d-495a-a2e6-e37e9b2fdae1	{"input": "TOUCH", "question": "prakriti"}	2026-09-13 07:23:54.662
ec7dbfb8-58b3-478c-ac29-21491333bfa5	patient-kiosk	REGISTERED_AND_CONSENTED	visit	8aa91ae0-acd4-4fe5-b171-1791215f58f2	{"mode": "AYUSH", "consents": ["history_collection", "document_processing", "mock_abdm_sharing"]}	2026-09-13 07:27:13.222
b702ab1d-d3b5-4589-899e-52a16bcdbc80	patient-kiosk	REGISTERED_AND_CONSENTED	visit	708225b5-71b9-445a-9e9d-0df6f413741d	{"mode": "AYUSH", "consents": ["history_collection", "document_processing", "mock_abdm_sharing"]}	2026-09-13 07:29:02.354
24f61de7-5df3-49c7-a87b-0e8f5b078a24	patient-kiosk	REGISTERED_AND_CONSENTED	visit	85a301ce-a419-4cc5-862c-55446da78227	{"mode": "GENERAL", "consents": ["history_collection", "document_processing", "mock_abdm_sharing"]}	2026-09-13 07:30:40.482
ba2a6cf4-bde6-4c5d-9764-761dfad6753c	patient-kiosk	REGISTERED_AND_CONSENTED	visit	89c97d50-f9b3-451c-b8ab-7ad66e295af8	{"mode": "GENERAL", "consents": ["history_collection", "document_processing", "mock_abdm_sharing"]}	2026-09-13 07:37:36.719
6654da71-6344-49d9-ba91-be680907d7a9	patient-kiosk	REGISTERED_AND_CONSENTED	visit	071bbfeb-a349-49fe-a2b8-900a6e95c1c3	{"mode": "GENERAL", "consents": ["history_collection", "document_processing", "mock_abdm_sharing"]}	2026-09-13 08:01:53.578
642c0ec0-fe90-4e67-9099-bffc92821782	patient-kiosk	REGISTERED_AND_CONSENTED	visit	a557e8bb-26d9-4ad4-90ac-7ad1369ea797	{"mode": "GENERAL", "consents": ["history_collection", "document_processing", "mock_abdm_sharing"]}	2026-09-13 08:11:31.544
0c9498f4-67dc-4fde-bbf4-b4412dac495e	patient-kiosk	ANSWER_RECORDED	visit	a557e8bb-26d9-4ad4-90ac-7ad1369ea797	{"input": "TEXT", "question": "chief"}	2026-09-13 08:11:54.049
88f675c4-0491-4a43-8c45-00143de14961	patient-kiosk	ANSWER_RECORDED	visit	a557e8bb-26d9-4ad4-90ac-7ad1369ea797	{"input": "TOUCH", "question": "duration"}	2026-09-13 08:11:56.095
c13b85cb-da93-4445-945a-addf8002e778	patient-kiosk	REGISTERED_AND_CONSENTED	visit	616725f4-3987-4d13-b75b-5155e7680451	{"mode": "GENERAL", "consents": ["history_collection", "document_processing", "mock_abdm_sharing"]}	2026-09-13 08:12:22.648
a1a49a7b-888e-44d5-ba64-03125855afc2	patient-kiosk	ANSWER_RECORDED	visit	616725f4-3987-4d13-b75b-5155e7680451	{"input": "TEXT", "question": "chief"}	2026-09-13 08:12:27.922
618711bb-ad92-4a55-a09d-88365b324de2	patient-kiosk	ANSWER_RECORDED	visit	616725f4-3987-4d13-b75b-5155e7680451	{"input": "TOUCH", "question": "duration"}	2026-09-13 08:12:35.862
4328a93b-25e0-425a-b8a4-f25bdcba709e	patient-kiosk	ANSWER_RECORDED	visit	616725f4-3987-4d13-b75b-5155e7680451	{"input": "TOUCH", "question": "severity"}	2026-09-13 08:12:37.052
e379cbb1-642b-4121-bda2-41dd86855db5	patient-kiosk	ANSWER_RECORDED	visit	616725f4-3987-4d13-b75b-5155e7680451	{"input": "TOUCH", "question": "breathlessness"}	2026-09-13 08:12:44.479
2f3bbf69-1a8e-4053-aaa4-ef479c7c1bca	patient-kiosk	ANSWER_RECORDED	visit	616725f4-3987-4d13-b75b-5155e7680451	{"input": "TOUCH", "question": "sweating"}	2026-09-13 08:12:47.259
5b90bd24-8976-4233-9a17-566ece10c76a	patient-kiosk	ANSWER_RECORDED	visit	616725f4-3987-4d13-b75b-5155e7680451	{"input": "TEXT", "question": "history"}	2026-09-13 08:12:56.297
79bfd7ab-a742-4bba-9e4a-2191a356a49d	patient-kiosk	SUMMARY_GENERATED	visit	616725f4-3987-4d13-b75b-5155e7680451	{}	2026-09-13 08:13:02.909
0996b500-202c-4ac1-87c0-2e464a64d145	Dr. Ananya Rao	VIEWED_CASE	visit	8f870d55-2f09-4dbc-8679-949faad408cc	{}	2026-09-13 08:13:10.126
b12be699-8e52-4f91-8f6b-83f1ef122b51	patient-kiosk	REGISTERED_AND_CONSENTED	visit	40885c0f-fb17-4418-9f87-2a6166ce6508	{"mode": "GENERAL", "consents": ["history_collection", "document_processing", "mock_abdm_sharing"]}	2026-09-13 09:16:06.218
40f85ba1-8b17-48c6-a0ef-e26a50d0fb58	patient-kiosk	ANSWER_RECORDED	visit	40885c0f-fb17-4418-9f87-2a6166ce6508	{"input": "VOICE", "question": "chief"}	2026-09-13 09:16:06.374
927e4731-9cbc-479e-a5d3-da5278001426	patient-kiosk	ANSWER_RECORDED	visit	40885c0f-fb17-4418-9f87-2a6166ce6508	{"input": "VOICE", "question": "duration"}	2026-09-13 09:16:06.699
59867e87-7f12-4a20-baf0-3c3f91c83f31	patient-kiosk	ANSWER_RECORDED	visit	40885c0f-fb17-4418-9f87-2a6166ce6508	{"input": "VOICE", "question": "severity"}	2026-09-13 09:16:06.771
976d7804-6be7-4418-b1e1-0f41a1e4c23c	patient-kiosk	ANSWER_RECORDED	visit	40885c0f-fb17-4418-9f87-2a6166ce6508	{"input": "VOICE", "question": "breathlessness"}	2026-09-13 09:16:06.797
a128eba5-59c8-4aee-81d5-3a9304042deb	patient-kiosk	ANSWER_RECORDED	visit	40885c0f-fb17-4418-9f87-2a6166ce6508	{"input": "VOICE", "question": "sweating"}	2026-09-13 09:16:06.815
6503c032-c7a0-4ff8-a3a6-b7c5fbd3a8cb	patient-kiosk	ANSWER_RECORDED	visit	40885c0f-fb17-4418-9f87-2a6166ce6508	{"input": "VOICE", "question": "history"}	2026-09-13 09:16:06.843
d2024150-3e6d-4a3f-832e-48e78e4cf51a	patient-kiosk	SUMMARY_GENERATED	visit	40885c0f-fb17-4418-9f87-2a6166ce6508	{}	2026-09-13 09:16:15.658
2c347e0f-2a24-4a66-a5c8-03026c95ea49	Dr. Ananya Rao	VIEWED_CASE	visit	40885c0f-fb17-4418-9f87-2a6166ce6508	{}	2026-09-13 09:16:28.515
a2f7e369-5da7-4e5f-b15c-cc4262c22c88	patient-kiosk	REGISTERED_AND_CONSENTED	visit	a46769a8-b0ef-4371-b158-973af7a05d37	{"mode": "GENERAL", "consents": ["history_collection", "document_processing", "mock_abdm_sharing"]}	2026-09-13 09:17:50.756
052062a9-47f2-4c8d-b1a6-749db1b8a8a4	patient-kiosk	ANSWER_RECORDED	visit	a46769a8-b0ef-4371-b158-973af7a05d37	{"input": "VOICE", "question": "chief"}	2026-09-13 09:17:50.77
830fbd1e-2fcb-4074-bc45-c2ab7c0937e9	patient-kiosk	ANSWER_RECORDED	visit	a46769a8-b0ef-4371-b158-973af7a05d37	{"input": "VOICE", "question": "duration"}	2026-09-13 09:17:50.784
9722ea34-9cf3-43e8-8e17-3861b8f8a06d	patient-kiosk	ANSWER_RECORDED	visit	a46769a8-b0ef-4371-b158-973af7a05d37	{"input": "VOICE", "question": "severity"}	2026-09-13 09:17:50.798
640998eb-a206-4492-a96a-2b02a6cc5104	patient-kiosk	ANSWER_RECORDED	visit	a46769a8-b0ef-4371-b158-973af7a05d37	{"input": "VOICE", "question": "breathlessness"}	2026-09-13 09:17:50.813
f405988a-385c-4399-afcd-5c4c0d9493da	patient-kiosk	ANSWER_RECORDED	visit	a46769a8-b0ef-4371-b158-973af7a05d37	{"input": "VOICE", "question": "sweating"}	2026-09-13 09:17:50.828
b29668fc-96be-49de-8a00-371c43f5614a	patient-kiosk	ANSWER_RECORDED	visit	a46769a8-b0ef-4371-b158-973af7a05d37	{"input": "VOICE", "question": "history"}	2026-09-13 09:17:50.843
a3bb90de-f070-4e10-9282-8f299015ebbd	patient-kiosk	SUMMARY_GENERATED	visit	a46769a8-b0ef-4371-b158-973af7a05d37	{}	2026-09-13 09:17:52.206
4be95257-b12b-4837-8042-d2b8e5a3161d	Dr. Ananya Rao	VIEWED_CASE	visit	a46769a8-b0ef-4371-b158-973af7a05d37	{}	2026-09-13 09:17:54.296
09a7aaa0-3f29-4769-8672-90f409ca04b8	patient-kiosk	REGISTERED_AND_CONSENTED	visit	864b4751-9be4-4da9-963e-b81503232e05	{"mode": "GENERAL", "consents": ["history_collection", "document_processing", "mock_abdm_sharing"]}	2026-09-13 09:57:38.353
785a5228-2fe6-4e02-89f7-ce2b7628dc3c	patient-kiosk	ANSWER_RECORDED	visit	864b4751-9be4-4da9-963e-b81503232e05	{"input": "TEXT", "question": "chief"}	2026-09-13 09:57:49.568
e0b05a56-3f0f-4461-ab1d-ecbdca0bb943	patient-kiosk	ANSWER_RECORDED	visit	864b4751-9be4-4da9-963e-b81503232e05	{"input": "TOUCH", "question": "duration"}	2026-09-13 09:57:51.059
a45ae61f-44f2-45b0-bf10-d19b80bb3129	patient-kiosk	ANSWER_RECORDED	visit	864b4751-9be4-4da9-963e-b81503232e05	{"input": "TOUCH", "question": "severity"}	2026-09-13 09:57:52.713
33a146f2-124f-4101-9183-5feb9b698941	patient-kiosk	ANSWER_RECORDED	visit	864b4751-9be4-4da9-963e-b81503232e05	{"input": "TOUCH", "question": "breathlessness"}	2026-09-13 09:57:55.836
8dffc7b3-22e9-49fc-bea7-9736d1ef89ea	patient-kiosk	ANSWER_RECORDED	visit	864b4751-9be4-4da9-963e-b81503232e05	{"input": "TOUCH", "question": "sweating"}	2026-09-13 09:57:56.846
6e0f8a0d-3a69-4261-ad43-16455a862270	patient-kiosk	ANSWER_RECORDED	visit	864b4751-9be4-4da9-963e-b81503232e05	{"input": "TEXT", "question": "history"}	2026-09-13 09:58:03.205
fa98a85e-dd6a-45c1-9602-3beee5872602	patient-kiosk	SUMMARY_GENERATED	visit	864b4751-9be4-4da9-963e-b81503232e05	{}	2026-09-13 09:58:07.088
38143122-872e-401e-b6df-4cb1fdf6b6f0	Dr. Ananya Rao	VIEWED_CASE	visit	864b4751-9be4-4da9-963e-b81503232e05	{}	2026-09-13 09:58:14.005
5b30e652-9d0f-49da-af63-e8a7dc7bb89d	Dr. Ananya Rao	VIEWED_CASE	visit	25873caf-7569-482c-8dee-15ae7a53f13d	{}	2026-09-13 09:59:41.663
a02d57dc-d055-433f-b45c-b481df5f2aea	Dr. Ananya Rao	SUMMARY_CONFIRMED	visit	25873caf-7569-482c-8dee-15ae7a53f13d	{}	2026-09-13 10:00:39.565
830011af-d20d-45aa-866f-e4c9669156f5	Dr. Ananya Rao	VIEWED_CASE	visit	25873caf-7569-482c-8dee-15ae7a53f13d	{}	2026-09-13 10:00:39.578
692b7deb-c8ef-41ba-850a-e18181c319fc	Dr. Ananya Rao	VIEWED_CASE	visit	40885c0f-fb17-4418-9f87-2a6166ce6508	{}	2026-09-13 10:00:43.797
32884ca9-83b7-4b92-93f7-da12bc4e57e2	Dr. Ananya Rao	VIEWED_CASE	visit	a46769a8-b0ef-4371-b158-973af7a05d37	{}	2026-09-13 10:00:48.963
43ba9be7-e10a-4024-90a2-4c8b4397dba7	Dr. Ananya Rao	SUMMARY_REJECTED	visit	a46769a8-b0ef-4371-b158-973af7a05d37	{}	2026-09-13 10:00:50.49
6ea9c0c7-0a69-4178-8d6a-190db5651492	Dr. Ananya Rao	VIEWED_CASE	visit	a46769a8-b0ef-4371-b158-973af7a05d37	{}	2026-09-13 10:00:50.501
8e4b3876-30e0-4b67-883b-12966df94000	Dr. Ananya Rao	VIEWED_CASE	visit	20b32d23-3f26-4c05-9403-9c7a577a7850	{}	2026-09-13 10:00:54.906
0bd0e5f3-45c9-4ddf-b873-79d89d1bdf85	Dr. Ananya Rao	SUMMARY_REJECTED	visit	20b32d23-3f26-4c05-9403-9c7a577a7850	{}	2026-09-13 10:00:56.427
2af71946-fa0c-4047-add9-cf1a8b20146c	Dr. Ananya Rao	VIEWED_CASE	visit	20b32d23-3f26-4c05-9403-9c7a577a7850	{}	2026-09-13 10:00:56.439
0e08fc37-3727-4320-8b33-0edb2269a071	Dr. Ananya Rao	VIEWED_CASE	visit	8f870d55-2f09-4dbc-8679-949faad408cc	{}	2026-09-13 10:01:05.047
297d83a0-3452-420b-931d-b16eb9edb9b4	Dr. Ananya Rao	SUMMARY_REJECTED	visit	8f870d55-2f09-4dbc-8679-949faad408cc	{}	2026-09-13 10:01:07.657
e1e51d37-6399-460d-b48b-8a9c4747bde8	Dr. Ananya Rao	VIEWED_CASE	visit	8f870d55-2f09-4dbc-8679-949faad408cc	{}	2026-09-13 10:01:07.67
d0db7525-85be-4d24-a2c9-b22592ae2dce	Dr. Ananya Rao	VIEWED_CASE	visit	8f870d55-2f09-4dbc-8679-949faad408cc	{}	2026-09-13 10:01:13.056
ff7b36c8-78cc-4e35-94fd-b30050ff3d1e	Dr. Ananya Rao	SUMMARY_CONFIRMED	visit	8f870d55-2f09-4dbc-8679-949faad408cc	{}	2026-09-13 10:01:16.577
121ba9a3-5808-47f5-9cf2-76523dbd5044	Dr. Ananya Rao	VIEWED_CASE	visit	8f870d55-2f09-4dbc-8679-949faad408cc	{}	2026-09-13 10:01:16.59
77fafcc2-aa26-4495-9c8b-7ff1aa831665	patient-account	PATIENT_ACCOUNT_CREATED	patient	5a0f1c3c-75ad-48dc-beb6-83cc32b055eb	{"accessCode": "PT-85E99B34"}	2026-09-13 10:08:02.503
d8c81197-a2b8-4cc6-9837-e70c7df10e6d	patient-account	PATIENT_SIGNED_IN	patient	5a0f1c3c-75ad-48dc-beb6-83cc32b055eb	{}	2026-09-13 10:08:15.142
80834fd8-f003-4301-bdb0-160a12e16cf5	patient-account	PATIENT_ACCOUNT_CREATED	patient	c343a65b-2556-45bc-acec-c86f13b7c129	{"accessCode": "PT-A98CA3EA"}	2026-09-13 10:13:36.896
1b8ae341-b9b4-4d45-8fd6-40071af318ef	patient-account	PATIENT_SIGNED_IN	patient	c343a65b-2556-45bc-acec-c86f13b7c129	{}	2026-09-13 10:13:57.567
cb04f6b2-6820-4e6d-b7d8-d3ae787ceb74	patient-kiosk	REGISTERED_AND_CONSENTED	visit	d3cb01ad-a8da-406c-b9a4-46b7ffeecaa5	{"mode": "GENERAL", "consents": ["history_collection", "document_processing", "mock_abdm_sharing"]}	2026-09-13 10:14:44.57
72beeb6f-dd9a-46f3-b86c-e0031dea0f1e	patient-kiosk	ANSWER_RECORDED	visit	d3cb01ad-a8da-406c-b9a4-46b7ffeecaa5	{"input": "TEXT", "question": "chief"}	2026-09-13 10:14:51.506
51964543-a282-4f45-81ee-7cdbc94a27a9	patient-kiosk	ANSWER_RECORDED	visit	d3cb01ad-a8da-406c-b9a4-46b7ffeecaa5	{"input": "TOUCH", "question": "duration"}	2026-09-13 10:14:53.428
9e581283-a271-48d6-bdfd-407360001ec1	patient-kiosk	ANSWER_RECORDED	visit	d3cb01ad-a8da-406c-b9a4-46b7ffeecaa5	{"input": "TOUCH", "question": "severity"}	2026-09-13 10:14:54.666
24620c2e-baaf-4097-b9fd-f3035ddf6fe1	patient-kiosk	ANSWER_RECORDED	visit	d3cb01ad-a8da-406c-b9a4-46b7ffeecaa5	{"input": "TOUCH", "question": "breathlessness"}	2026-09-13 10:14:56.724
233001bb-55f0-46d0-84d0-ad476a2526d7	patient-kiosk	ANSWER_RECORDED	visit	d3cb01ad-a8da-406c-b9a4-46b7ffeecaa5	{"input": "TOUCH", "question": "sweating"}	2026-09-13 10:14:57.469
93b6e7a3-5efa-4371-bc20-f7ba59f3b84a	patient-kiosk	ANSWER_RECORDED	visit	d3cb01ad-a8da-406c-b9a4-46b7ffeecaa5	{"input": "TEXT", "question": "history"}	2026-09-13 10:15:03.345
0ba3f8e7-3d87-45a2-9f57-ac2e18f74eca	patient-kiosk	SUMMARY_GENERATED	visit	d3cb01ad-a8da-406c-b9a4-46b7ffeecaa5	{}	2026-09-13 10:15:05.958
0526cf3b-fed3-4df4-a66f-74ee525b4988	Dr. Ananya Rao	VIEWED_CASE	visit	d3cb01ad-a8da-406c-b9a4-46b7ffeecaa5	{}	2026-09-13 10:15:12.699
87a16d59-8568-4e1e-a6ff-ad83f2b67bd6	patient-account	PATIENT_SIGNED_IN	patient	c343a65b-2556-45bc-acec-c86f13b7c129	{}	2026-09-13 10:15:26.859
7782c735-8102-425c-b3ba-4616ca041021	patient-account	PATIENT_SIGNED_IN	patient	c343a65b-2556-45bc-acec-c86f13b7c129	{}	2026-09-13 10:15:48.473
b5657fb7-cdf1-42f9-89a0-70faa49c6761	patient-account	PATIENT_SIGNED_IN	patient	c343a65b-2556-45bc-acec-c86f13b7c129	{}	2026-09-13 10:16:31.781
eb95d4b9-1311-42ac-999a-6aa1f2083204	patient-account	PATIENT_SIGNED_IN	patient	c343a65b-2556-45bc-acec-c86f13b7c129	{}	2026-09-13 10:21:44.591
76bbf723-ec1e-4bae-8859-545c78b843bc	patient-account	PATIENT_ACCOUNT_CREATED	patient	3c9700e1-f241-4f0a-bccd-2f1c2a1fa173	{"accessCode": "PT-ISHANT18"}	2026-09-13 10:26:21.668
6b8af727-b334-4df6-8e5e-3fbb5359890d	patient-account	PATIENT_SIGNED_IN	patient	3c9700e1-f241-4f0a-bccd-2f1c2a1fa173	{}	2026-09-13 10:26:30.295
bbedb45f-e3a6-447e-a9ad-bccd86e5ce1c	patient-account	PATIENT_SIGNED_IN	patient	3c9700e1-f241-4f0a-bccd-2f1c2a1fa173	{}	2026-09-13 10:27:16.726
406f540f-68a5-4c63-9db5-93f398ca6de8	patient-account	PATIENT_ACCOUNT_CREATED	patient	07a8a9b6-c277-4fef-9ebe-ad778ca9c30b	{"accessCode": "PT-ADITYA16"}	2026-09-13 10:28:52.731
6ee7e10e-35be-4b87-8c5b-ad67e6a1f5aa	patient-account	PATIENT_SIGNED_IN	patient	07a8a9b6-c277-4fef-9ebe-ad778ca9c30b	{}	2026-09-13 10:28:56.225
8b321ec9-efe3-442f-b84e-2370c0936ae7	Dr. Ananya Rao	VIEWED_CASE	visit	a46769a8-b0ef-4371-b158-973af7a05d37	{}	2026-09-13 10:29:20.222
bd41fa76-7470-470f-b3da-325bd6f05e8e	Dr. Ananya Rao	VIEWED_CASE	visit	a46769a8-b0ef-4371-b158-973af7a05d37	{}	2026-09-13 10:29:48.175
963433db-00de-4409-b17d-430548b39e93	patient-account	PATIENT_SIGNED_IN	patient	3c9700e1-f241-4f0a-bccd-2f1c2a1fa173	{}	2026-09-13 10:30:26.02
cc1b68f8-8590-472a-bc76-59f38f465145	patient-kiosk	REGISTERED_AND_CONSENTED	visit	a88899d4-d874-4925-af37-aaf1e1862ece	{"mode": "GENERAL", "consents": ["history_collection", "document_processing", "mock_abdm_sharing"]}	2026-09-13 10:30:59.821
815388c8-cf72-482f-8a9b-29d2862e3ee3	patient-kiosk	ANSWER_RECORDED	visit	a88899d4-d874-4925-af37-aaf1e1862ece	{"input": "TEXT", "question": "chief"}	2026-09-13 10:31:04.314
4f0ad862-8aa4-4a8a-8020-cf6e9f7c6b01	patient-kiosk	ANSWER_RECORDED	visit	a88899d4-d874-4925-af37-aaf1e1862ece	{"input": "TOUCH", "question": "duration"}	2026-09-13 10:31:06.453
6d1d16a2-d1d8-479e-a5e1-11b0dfadef8d	patient-kiosk	ANSWER_RECORDED	visit	a88899d4-d874-4925-af37-aaf1e1862ece	{"input": "TOUCH", "question": "severity"}	2026-09-13 10:31:07.863
aab0c9b7-400e-4e6b-bf33-f618e6dbf166	patient-kiosk	ANSWER_RECORDED	visit	a88899d4-d874-4925-af37-aaf1e1862ece	{"input": "TOUCH", "question": "breathlessness"}	2026-09-13 10:31:09.234
ae5420c8-1b49-4c5d-98e0-0165b80e4a20	patient-kiosk	ANSWER_RECORDED	visit	a88899d4-d874-4925-af37-aaf1e1862ece	{"input": "TOUCH", "question": "sweating"}	2026-09-13 10:31:10.444
6642bab7-8354-4fc2-ab5c-343f216588f2	patient-kiosk	ANSWER_RECORDED	visit	a88899d4-d874-4925-af37-aaf1e1862ece	{"input": "TEXT", "question": "history"}	2026-09-13 10:31:17.693
0998a090-e643-4266-a731-157a6639e031	patient-kiosk	SUMMARY_GENERATED	visit	a88899d4-d874-4925-af37-aaf1e1862ece	{}	2026-09-13 10:31:19.464
27365781-a113-4f06-a249-83d5699e5c42	Dr. Ananya Rao	VIEWED_CASE	visit	a88899d4-d874-4925-af37-aaf1e1862ece	{}	2026-09-13 10:31:22.443
864dbf29-ea36-4268-b2c3-8b43b85ad76d	patient-account	PATIENT_SIGNED_IN	patient	3c9700e1-f241-4f0a-bccd-2f1c2a1fa173	{}	2026-09-13 10:31:31.309
7f7d5d3c-1c1a-40ca-8c9c-c3cec81e4ada	patient-account	PATIENT_SIGNED_IN	patient	3c9700e1-f241-4f0a-bccd-2f1c2a1fa173	{}	2026-09-13 10:32:35.084
ffdc8ab9-1cda-441d-9e0b-bdf8064dfb6f	patient-account	PATIENT_SIGNED_IN	patient	3c9700e1-f241-4f0a-bccd-2f1c2a1fa173	{}	2026-09-13 10:35:32.365
c67e35bd-7d66-4abc-aabb-fd23f0cb87d4	patient-account	PATIENT_SIGNED_IN	patient	3c9700e1-f241-4f0a-bccd-2f1c2a1fa173	{}	2026-09-13 10:38:02.993
a2665832-de94-45e1-a4b8-25496cb24a47	patient-account	PATIENT_PROFILE_UPDATED	patient	3c9700e1-f241-4f0a-bccd-2f1c2a1fa173	{}	2026-09-13 10:38:07.919
caef19f3-718e-46ea-896d-067f4b3e568e	Dr. Ananya Rao	VIEWED_CASE	visit	a88899d4-d874-4925-af37-aaf1e1862ece	{}	2026-09-13 10:42:24.018
a487031f-2f65-41b8-bf2c-788743ff0151	patient-account	PATIENT_SIGNED_IN	patient	3c9700e1-f241-4f0a-bccd-2f1c2a1fa173	{}	2026-09-13 10:45:58.137
af3fbea2-6840-4fcd-b625-5dca630ec9e9	patient-account	PATIENT_SIGNED_IN	patient	3c9700e1-f241-4f0a-bccd-2f1c2a1fa173	{}	2026-09-13 10:53:29.508
48215903-ef6d-4d75-a27f-67793797dd44	patient-account	PATIENT_SIGNED_IN	patient	3c9700e1-f241-4f0a-bccd-2f1c2a1fa173	{}	2026-09-13 10:57:58.246
8fc8239a-0419-4b04-8522-accfa6144bee	patient-account	PATIENT_SIGNED_IN	patient	3c9700e1-f241-4f0a-bccd-2f1c2a1fa173	{}	2026-09-13 11:04:43.32
c654c355-250b-47f7-8a08-b2e1355b3d6d	patient-account	PATIENT_SIGNED_IN	patient	3c9700e1-f241-4f0a-bccd-2f1c2a1fa173	{}	2026-09-13 11:52:00.073
16fa79ad-32bd-43cb-8f85-3a1fbcd76b13	patient-kiosk	REGISTERED_AND_CONSENTED	visit	478228db-82aa-42be-829f-547489a08838	{"mode": "GENERAL", "consents": ["history_collection", "document_processing", "mock_abdm_sharing"]}	2026-09-13 11:52:20.969
34dbf9a6-4d5f-4739-8bb3-e36ae73eb691	patient-kiosk	ANSWER_RECORDED	visit	478228db-82aa-42be-829f-547489a08838	{"input": "TEXT", "question": "chief"}	2026-09-13 11:52:26.529
6ee359a1-956f-439f-be3e-b52ba5650f6c	patient-kiosk	ANSWER_RECORDED	visit	478228db-82aa-42be-829f-547489a08838	{"input": "TOUCH", "question": "duration"}	2026-09-13 11:52:27.742
f1e5c02a-cd4b-46e4-a585-824349e85167	patient-kiosk	ANSWER_RECORDED	visit	478228db-82aa-42be-829f-547489a08838	{"input": "TOUCH", "question": "severity"}	2026-09-13 11:52:30.002
1aed51a9-5667-48ee-b88e-43ad553fbe26	patient-kiosk	ANSWER_RECORDED	visit	478228db-82aa-42be-829f-547489a08838	{"input": "TOUCH", "question": "breathlessness"}	2026-09-13 11:52:31.284
c22f055e-8554-4935-9e85-88592612205d	patient-kiosk	ANSWER_RECORDED	visit	478228db-82aa-42be-829f-547489a08838	{"input": "TOUCH", "question": "sweating"}	2026-09-13 11:52:31.665
0161e8c2-0500-464f-be12-ca1a9ef11345	patient-kiosk	ANSWER_RECORDED	visit	478228db-82aa-42be-829f-547489a08838	{"input": "TEXT", "question": "history"}	2026-09-13 11:52:36.017
2eda2205-8dba-4f06-8359-13b6524ef9e4	patient-kiosk	SUMMARY_GENERATED	visit	478228db-82aa-42be-829f-547489a08838	{}	2026-09-13 11:52:37.742
72980d15-c3f1-496a-96bc-1dd7624df928	patient-account	PATIENT_SIGNED_IN	patient	3c9700e1-f241-4f0a-bccd-2f1c2a1fa173	{}	2026-09-13 11:52:43.266
94cca10c-eb29-4b76-b0fa-20712f967bb6	patient-account	PATIENT_SIGNED_IN	patient	3c9700e1-f241-4f0a-bccd-2f1c2a1fa173	{}	2026-09-13 11:56:31.409
ea2f6320-fd9e-43c6-b057-23e977c57304	patient-account	PATIENT_SIGNED_IN	patient	3c9700e1-f241-4f0a-bccd-2f1c2a1fa173	{}	2026-09-13 11:59:04.252
83b017ed-4244-4218-b1a3-482254d3dc6d	patient-account	PATIENT_SIGNED_IN	patient	3c9700e1-f241-4f0a-bccd-2f1c2a1fa173	{}	2026-09-13 11:59:33.538
\.


--
-- Data for Name: clinical_summaries; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.clinical_summaries (id, visit_id, summary_text, status, version, reviewer, updated_at) FROM stdin;
804be9c7-2458-43a7-9e42-bf1d5c68ace7	7c43581b-4a8d-4aa7-b706-2c9fcdebe2c3	Chief concern: seasonal cough for 5 days. No breathlessness, chest pain, or fever reported.\n\nClinical documentation aid only — requires clinician verification.	PENDING	1	\N	2026-09-12 18:15:20.856
64ad35a4-324a-4ec2-8e75-32c95736b879	40885c0f-fb17-4418-9f87-2a6166ce6508	Chief concern: Severe chest pain and tightness.\n\nStructured history: When did this start?: 1–3 days ago; How severe is it?: Severe (7–10); Are you having difficulty breathing?: Yes; Any cold sweating, fainting, or dizziness?: Yes; Any known illness, medicines, or allergies?: Diabetes; Metformin 500 mg; no known allergies.\n\nTriage alert: Chest symptoms with breathlessness: immediate clinical assessment recommended. Chest symptoms with sweating/dizziness: triage staff should assess now.\n\nClinical documentation aid only — no diagnosis or treatment recommendation. Requires clinician verification.	PENDING	1	\N	2026-09-13 09:16:15.654
571fc12f-d868-48e7-a43c-d82d423e0ab4	d3cb01ad-a8da-406c-b9a4-46b7ffeecaa5	Chief concern: I have pain and discomfort..\n\nStructured history: When did this start?: 1–3 days ago; How severe is it?: Moderate (4–6); Are you having difficulty breathing?: No; Any cold sweating, fainting, or dizziness?: No; Any known illness, medicines, or allergies?: No known allergies..\n\nClinical documentation aid only — no diagnosis or treatment recommendation. Requires clinician verification.	PENDING	1	\N	2026-09-13 10:15:05.955
37e982a4-a082-47e8-9234-f65a1f238be7	fc169399-15ff-4e25-ac5f-f4dad0083c72	Chief concern: Severe chest pain and tightness.\n\nStructured history: When did this start?: 1–3 days ago; How severe is it?: Severe (7–10); Are you having difficulty breathing?: Yes; Any cold sweating, fainting, or dizziness?: Yes; Any known illness, medicines, or allergies?: Diabetes; Metformin 500 mg; no known allergies.\n\nTriage alert: Chest symptoms with breathlessness: immediate clinical assessment recommended. Chest symptoms with sweating/dizziness: triage staff should assess now.\n\nClinical documentation aid only — no diagnosis or treatment recommendation. Requires clinician verification.	PENDING	1	\N	2026-09-12 18:23:59.004
15f22010-1be4-4a82-b3de-cdef5d30cf97	e059bba2-29d2-4bef-b754-2197280b43a4	Chief concern: chest\n.\n\nStructured history: When did this start?: 1–3 days ago; How severe is it?: Moderate (4–6); Are you having difficulty breathing?: No; Any cold sweating, fainting, or dizziness?: Yes; Any known illness, medicines, or allergies?: had allergie hoil colors\n.\n\nClinical documentation aid only — no diagnosis or treatment recommendation. Requires clinician verification.	PENDING	1	\N	2026-09-12 18:41:04.717
b2f4eda4-0171-4aee-aa6c-ae01f1be509c	2686b519-aaa2-4f4b-95a8-df3598f810a4	Chief concern:  having stomach pain.\n\nStructured history: When did this start?: Today; How severe is it?: Moderate (4–6); Are you having difficulty breathing?: Yes; Any cold sweating, fainting, or dizziness?: No; Any known illness, medicines, or allergies?: allergy from a medicine called citrizine.\n\nClinical documentation aid only — no diagnosis or treatment recommendation. Requires clinician verification.	PENDING	1	\N	2026-09-12 19:34:52.473
321c7f0a-ba13-4784-89f5-0cc57c7475ce	6c954f15-d274-4366-b762-3bfd95975eaa	Chief concern: stomach ace\n.\n\nStructured history: When did this start?: 1–3 days ago; How severe is it?: Moderate (4–6); Are you having difficulty breathing?: Yes; Any cold sweating, fainting, or dizziness?: Yes; Any known illness, medicines, or allergies?: allergie from peanut.\n\nClinical documentation aid only — no diagnosis or treatment recommendation. Requires clinician verification.	PENDING	1	\N	2026-09-13 07:20:46.498
6d99a52b-1e90-43f0-8504-52c867d8d937	616725f4-3987-4d13-b75b-5155e7680451	Chief concern: suffering from back pain.\n\nStructured history: When did this start?: 1–3 days ago; How severe is it?: Moderate (4–6); Are you having difficulty breathing?: No; Any cold sweating, fainting, or dizziness?: No; Any known illness, medicines, or allergies?: no \n.\n\nClinical documentation aid only — no diagnosis or treatment recommendation. Requires clinician verification.	PENDING	1	\N	2026-09-13 08:13:02.897
5ab53be6-23dc-432f-b1ea-35aaeb664c9f	864b4751-9be4-4da9-963e-b81503232e05	Chief concern: I have pain and discomfort..\n\nStructured history: When did this start?: 1–3 days ago; How severe is it?: Moderate (4–6); Are you having difficulty breathing?: Yes; Any cold sweating, fainting, or dizziness?: Yes; Any known illness, medicines, or allergies?: no.\n\nClinical documentation aid only — no diagnosis or treatment recommendation. Requires clinician verification.	PENDING	1	\N	2026-09-13 09:58:07.085
77060f56-1c92-4194-9c27-7dbecc40d279	25873caf-7569-482c-8dee-15ae7a53f13d	Chief concern: Fever and body ache since morning.\n\nStructured history: When did this start?: Today; How severe is it?: Moderate (4–6); Are you having difficulty breathing?: Yes; Any cold sweating, fainting, or dizziness?: No; Any known illness, medicines, or allergies?: No known illness; not on any medication.\n\nDocument extraction (MOCK; clinician validation required): MOCK OCR — Hb 9.2 g/dL; Blood Glucose 168 mg/dL; Metformin 500 mg\n\nClinical documentation aid only — no diagnosis or treatment recommendation. Requires clinician verification.	CONFIRMED	2	Dr. Ananya Rao	2026-09-13 10:00:39.56
b7b26db7-de80-4471-80ed-f59558560005	a46769a8-b0ef-4371-b158-973af7a05d37	Chief concern: Severe chest pain and tightness.\n\nStructured history: When did this start?: 1–3 days ago; How severe is it?: Severe (7–10); Are you having difficulty breathing?: Yes; Any cold sweating, fainting, or dizziness?: Yes; Any known illness, medicines, or allergies?: Diabetes; Metformin 500 mg; no known allergies.\n\nTriage alert: Chest symptoms with breathlessness: immediate clinical assessment recommended. Chest symptoms with sweating/dizziness: triage staff should assess now.\n\nClinical documentation aid only — no diagnosis or treatment recommendation. Requires clinician verification.	REJECTED	2	Dr. Ananya Rao	2026-09-13 10:00:50.486
54399bd9-6d50-470a-807b-737dfff7a939	20b32d23-3f26-4c05-9403-9c7a577a7850	Chief concern: Severe chest pain and tightness.\n\nStructured history: When did this start?: 1–3 days ago; How severe is it?: Severe (7–10); Are you having difficulty breathing?: Yes; Any cold sweating, fainting, or dizziness?: Yes; Any known illness, medicines, or allergies?: Diabetes; Metformin 500 mg; no known allergies.\n\nTriage alert: Chest symptoms with breathlessness: immediate clinical assessment recommended. Chest symptoms with sweating/dizziness: triage staff should assess now.\n\nDocument extraction (MOCK; clinician validation required): MOCK OCR — Hb 9.2 g/dL; Blood Glucose 168 mg/dL; Metformin 500 mg\n\nDoctor note: reviewed, ECG ordered. Clinical documentation aid only — no diagnosis or treatment recommendation. Requires clinician verification.	REJECTED	5	Dr. Ananya Rao	2026-09-13 10:00:56.422
0e6b6408-520d-4494-9768-6c3b9822ae90	8f870d55-2f09-4dbc-8679-949faad408cc	Chief concern: Severe chest pain and tightness.\n\nStructured history: When did this start?: 1–3 days ago; How severe is it?: Severe (7–10); Are you having difficulty breathing?: Yes; Any cold sweating, fainting, or dizziness?: Yes; Any known illness, medicines, or allergies?: Diabetes; Metformin 500 mg; no known allergies.\n\nTriage alert: Chest symptoms with breathlessness: immediate clinical assessment recommended. Chest symptoms with sweating/dizziness: triage staff should assess now.\n\nDocument extraction (MOCK; clinician validation required): MOCK OCR — Hb 9.2 g/dL; Blood Glucose 168 mg/dL; Metformin 500 mg\n\nClinical documentation aid only — no diagnosis or treatment recommendation. Requires clinician verification.	CONFIRMED	3	Dr. Ananya Rao	2026-09-13 10:01:16.573
23489976-86e1-407e-b6ca-df59bde14640	a88899d4-d874-4925-af37-aaf1e1862ece	Chief concern: Severe chest pain and tightness\n.\n\nStructured history: When did this start?: 1–3 days ago; How severe is it?: Severe (7–10); Are you having difficulty breathing?: Yes; Any cold sweating, fainting, or dizziness?: Yes; Any known illness, medicines, or allergies?: No known allergies..\n\nTriage alert: Chest symptoms with breathlessness: immediate clinical assessment recommended. Chest symptoms with sweating/dizziness: triage staff should assess now.\n\nClinical documentation aid only — no diagnosis or treatment recommendation. Requires clinician verification.	PENDING	1	\N	2026-09-13 10:31:19.46
ae7a4e2f-bc6b-4138-a6b4-4899aa6cf4fd	478228db-82aa-42be-829f-547489a08838	Chief concern: I have pain and discomfort..\n\nStructured history: When did this start?: 1–3 days ago; How severe is it?: Mild (1–3); Are you having difficulty breathing?: No; Any cold sweating, fainting, or dizziness?: No; Any known illness, medicines, or allergies?: No known allergies..\n\nClinical documentation aid only — no diagnosis or treatment recommendation. Requires clinician verification.	PENDING	1	\N	2026-09-13 11:52:37.74
\.


--
-- Data for Name: consents; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.consents (id, visit_id, type, granted, version, granted_at) FROM stdin;
17728ebb-f5f2-4c8d-8746-1180f3b6b454	20b32d23-3f26-4c05-9403-9c7a577a7850	history_collection	t	v1.0	2026-09-12 18:15:21.781
ac78a915-1c54-412b-ad37-87dc99f2282e	20b32d23-3f26-4c05-9403-9c7a577a7850	document_processing	t	v1.0	2026-09-12 18:15:21.783
60aee0a9-2211-419f-b7fd-2c66d04adb33	20b32d23-3f26-4c05-9403-9c7a577a7850	mock_abdm_sharing	t	v1.0	2026-09-12 18:15:21.784
86ba4f29-db3b-4bc5-8134-b2f9c2073cf9	25873caf-7569-482c-8dee-15ae7a53f13d	history_collection	t	v1.0	2026-09-12 18:17:48.333
75f1f45c-5b46-4d8e-b315-bf4ac97e7775	25873caf-7569-482c-8dee-15ae7a53f13d	document_processing	t	v1.0	2026-09-12 18:17:48.335
b50b8f75-a3f3-4599-9848-30203adabbf0	25873caf-7569-482c-8dee-15ae7a53f13d	mock_abdm_sharing	t	v1.0	2026-09-12 18:17:48.337
c32d2286-5cc1-41d6-a270-a7a063db9df9	fc169399-15ff-4e25-ac5f-f4dad0083c72	history_collection	t	v1.0	2026-09-12 18:23:48.61
14ebaca6-dccc-4861-a75d-ebeae90737bb	fc169399-15ff-4e25-ac5f-f4dad0083c72	document_processing	t	v1.0	2026-09-12 18:23:48.615
f5983f4d-b1fc-4031-b2c9-684fb65e0b78	fc169399-15ff-4e25-ac5f-f4dad0083c72	mock_abdm_sharing	t	v1.0	2026-09-12 18:23:48.618
752e19c1-5787-4b4f-894d-0c200dd741b2	789dca42-ac4c-4e92-8b63-c3bcc445beec	history_collection	t	v1.0	2026-09-12 18:25:22.193
b375b2b8-d055-4fe5-b399-00a5b1e9a4bd	789dca42-ac4c-4e92-8b63-c3bcc445beec	document_processing	t	v1.0	2026-09-12 18:25:22.196
3f0860ef-7d18-4cad-98d2-486df67b81af	789dca42-ac4c-4e92-8b63-c3bcc445beec	mock_abdm_sharing	t	v1.0	2026-09-12 18:25:22.198
5c6b14bd-c95d-4918-9691-59818c54e540	8f870d55-2f09-4dbc-8679-949faad408cc	history_collection	t	v1.0	2026-09-12 18:32:22.06
bfc2b405-134e-4d6f-95ac-e9a2cc15981d	8f870d55-2f09-4dbc-8679-949faad408cc	document_processing	t	v1.0	2026-09-12 18:32:22.062
17e18ba3-b32b-42ba-9dbf-fb9db5530aa1	8f870d55-2f09-4dbc-8679-949faad408cc	mock_abdm_sharing	t	v1.0	2026-09-12 18:32:22.063
bb038855-be3c-4920-8702-a4b17952789c	e059bba2-29d2-4bef-b754-2197280b43a4	history_collection	t	v1.0	2026-09-12 18:39:44.496
61f9d46e-adf2-4640-ab14-91645d76a9a5	e059bba2-29d2-4bef-b754-2197280b43a4	document_processing	t	v1.0	2026-09-12 18:39:44.498
aa8fbf49-2aea-42a2-8fa3-70a638f71c4b	e059bba2-29d2-4bef-b754-2197280b43a4	mock_abdm_sharing	t	v1.0	2026-09-12 18:39:44.499
446f851e-da3e-4f23-8849-27dbde9e829d	2686b519-aaa2-4f4b-95a8-df3598f810a4	history_collection	t	v1.0	2026-09-12 19:33:46.438
bf8e5b2c-e019-4195-a3cd-311f8a7859e3	2686b519-aaa2-4f4b-95a8-df3598f810a4	document_processing	t	v1.0	2026-09-12 19:33:46.443
37e82608-cd3e-4098-b8f4-76b1bd5fe40a	2686b519-aaa2-4f4b-95a8-df3598f810a4	mock_abdm_sharing	t	v1.0	2026-09-12 19:33:46.444
79344c3c-9059-40d3-a04d-972a5b5c6ace	6c954f15-d274-4366-b762-3bfd95975eaa	history_collection	t	v1.0	2026-09-13 07:19:54.32
adc3d41b-0a0e-4890-8477-7f07a20bd8e4	6c954f15-d274-4366-b762-3bfd95975eaa	document_processing	t	v1.0	2026-09-13 07:19:54.325
d4772e4d-b8ec-4b75-aa44-482f6f6aa06f	6c954f15-d274-4366-b762-3bfd95975eaa	mock_abdm_sharing	t	v1.0	2026-09-13 07:19:54.327
b512e651-e337-4bde-b18c-fe46e4183e92	e03c38b5-ea4d-495a-a2e6-e37e9b2fdae1	history_collection	t	v1.0	2026-09-13 07:22:39.403
61115b58-90b7-4ccc-9c05-572847214e7a	e03c38b5-ea4d-495a-a2e6-e37e9b2fdae1	document_processing	t	v1.0	2026-09-13 07:22:39.406
2140440e-0830-4eb4-b5a1-16eca3fa7cbe	e03c38b5-ea4d-495a-a2e6-e37e9b2fdae1	mock_abdm_sharing	t	v1.0	2026-09-13 07:22:39.408
2ddbd807-4979-4dcc-acdc-f935cce14983	8aa91ae0-acd4-4fe5-b171-1791215f58f2	history_collection	t	v1.0	2026-09-13 07:27:13.215
c5eadb30-87aa-44b8-a630-b2b0a47304dd	8aa91ae0-acd4-4fe5-b171-1791215f58f2	document_processing	t	v1.0	2026-09-13 07:27:13.218
b654b38c-483b-454d-9843-f63e651eb135	8aa91ae0-acd4-4fe5-b171-1791215f58f2	mock_abdm_sharing	t	v1.0	2026-09-13 07:27:13.22
e6588cb0-0e19-4155-9ee8-5989113dc16a	708225b5-71b9-445a-9e9d-0df6f413741d	history_collection	t	v1.0	2026-09-13 07:29:02.348
ede24f01-dbbf-4666-8f51-e8d52d3c9fcd	708225b5-71b9-445a-9e9d-0df6f413741d	document_processing	t	v1.0	2026-09-13 07:29:02.35
33efa5d8-eb2a-4464-826c-9f1ee81ce29c	708225b5-71b9-445a-9e9d-0df6f413741d	mock_abdm_sharing	t	v1.0	2026-09-13 07:29:02.352
ce60731d-6e24-42d8-945a-4aec46c3a5fe	85a301ce-a419-4cc5-862c-55446da78227	history_collection	t	v1.0	2026-09-13 07:30:40.466
e9f8076c-e32f-4a92-8a8d-96dec71a3a56	85a301ce-a419-4cc5-862c-55446da78227	document_processing	t	v1.0	2026-09-13 07:30:40.469
aef6a9d3-b3ce-4d2a-8ead-986e7cf2b862	85a301ce-a419-4cc5-862c-55446da78227	mock_abdm_sharing	t	v1.0	2026-09-13 07:30:40.476
ee73f6a5-7012-4466-996e-4157bee8032b	89c97d50-f9b3-451c-b8ab-7ad66e295af8	history_collection	t	v1.0	2026-09-13 07:37:36.712
a9c0adaa-1b96-4dee-92c6-3c752d702811	89c97d50-f9b3-451c-b8ab-7ad66e295af8	document_processing	t	v1.0	2026-09-13 07:37:36.715
082b1d72-448b-46fb-8d8c-89a10da99067	89c97d50-f9b3-451c-b8ab-7ad66e295af8	mock_abdm_sharing	t	v1.0	2026-09-13 07:37:36.717
94dea54d-11f4-4a8d-9acf-ba27086e8966	071bbfeb-a349-49fe-a2b8-900a6e95c1c3	history_collection	t	v1.0	2026-09-13 08:01:53.553
148f91f7-6833-4067-a387-eb8f8b50e72c	071bbfeb-a349-49fe-a2b8-900a6e95c1c3	document_processing	t	v1.0	2026-09-13 08:01:53.56
230ce589-16bf-4e6c-b548-b9fa6c0538d7	071bbfeb-a349-49fe-a2b8-900a6e95c1c3	mock_abdm_sharing	t	v1.0	2026-09-13 08:01:53.567
a4413605-aefe-48aa-832d-01c5433c2e03	a557e8bb-26d9-4ad4-90ac-7ad1369ea797	history_collection	t	v1.0	2026-09-13 08:11:31.504
ceda27d0-a2be-48d5-be47-955f55da58e7	a557e8bb-26d9-4ad4-90ac-7ad1369ea797	document_processing	t	v1.0	2026-09-13 08:11:31.519
37745f28-ae7e-4817-ab9b-1d7567eb0066	a557e8bb-26d9-4ad4-90ac-7ad1369ea797	mock_abdm_sharing	t	v1.0	2026-09-13 08:11:31.53
665b749d-402d-4c1e-8142-6e1bbb36f562	616725f4-3987-4d13-b75b-5155e7680451	history_collection	t	v1.0	2026-09-13 08:12:22.635
2951ed62-f299-4805-ab32-0ff0b879e8df	616725f4-3987-4d13-b75b-5155e7680451	document_processing	t	v1.0	2026-09-13 08:12:22.639
abb724b3-4906-45cd-b29a-a5e91f887cfb	616725f4-3987-4d13-b75b-5155e7680451	mock_abdm_sharing	t	v1.0	2026-09-13 08:12:22.643
200641bb-dbba-4bca-bec5-daa3ec9ea530	40885c0f-fb17-4418-9f87-2a6166ce6508	history_collection	t	v1.0	2026-09-13 09:16:06.204
02be8dbb-220b-4335-90a2-cb56fe178c09	40885c0f-fb17-4418-9f87-2a6166ce6508	document_processing	t	v1.0	2026-09-13 09:16:06.21
bb18e9b6-a558-4242-8c6d-f1356017411c	40885c0f-fb17-4418-9f87-2a6166ce6508	mock_abdm_sharing	t	v1.0	2026-09-13 09:16:06.215
2d8fba01-0145-49f0-878f-e775dc4e3bc0	a46769a8-b0ef-4371-b158-973af7a05d37	history_collection	t	v1.0	2026-09-13 09:17:50.753
87e7c533-ec24-4615-895d-25ff34426e6b	a46769a8-b0ef-4371-b158-973af7a05d37	document_processing	t	v1.0	2026-09-13 09:17:50.754
992b73f2-bfcf-44cb-8d3c-de7c79204d16	a46769a8-b0ef-4371-b158-973af7a05d37	mock_abdm_sharing	t	v1.0	2026-09-13 09:17:50.755
dd1608fa-c983-4db5-8900-236090474204	864b4751-9be4-4da9-963e-b81503232e05	history_collection	t	v1.0	2026-09-13 09:57:38.345
f9497a40-3b78-448c-8883-7f6f0a2e5dce	864b4751-9be4-4da9-963e-b81503232e05	document_processing	t	v1.0	2026-09-13 09:57:38.348
580e956c-dcb8-4446-82bf-83b69aef1da7	864b4751-9be4-4da9-963e-b81503232e05	mock_abdm_sharing	t	v1.0	2026-09-13 09:57:38.349
f7e6af88-7a5d-47b5-a0cc-2fc7231a330a	d3cb01ad-a8da-406c-b9a4-46b7ffeecaa5	history_collection	t	v1.0	2026-09-13 10:14:44.565
ca49ca62-0fb8-4f12-b2a8-a4983d3aa421	d3cb01ad-a8da-406c-b9a4-46b7ffeecaa5	document_processing	t	v1.0	2026-09-13 10:14:44.568
ba363c93-017e-4b6e-81a6-59552f158158	d3cb01ad-a8da-406c-b9a4-46b7ffeecaa5	mock_abdm_sharing	t	v1.0	2026-09-13 10:14:44.569
e0fa5212-d533-4d8b-a58b-c43e01e937f0	a88899d4-d874-4925-af37-aaf1e1862ece	history_collection	t	v1.0	2026-09-13 10:30:59.816
4c0af194-e316-4d20-9b15-474ec6ee4129	a88899d4-d874-4925-af37-aaf1e1862ece	document_processing	t	v1.0	2026-09-13 10:30:59.818
9997bb84-a718-4e44-8ff7-5e925b725e3f	a88899d4-d874-4925-af37-aaf1e1862ece	mock_abdm_sharing	t	v1.0	2026-09-13 10:30:59.82
d69bb7c6-c6ce-42ee-8b18-b3b022673c49	478228db-82aa-42be-829f-547489a08838	history_collection	t	v1.0	2026-09-13 11:52:20.965
da943a86-8e20-49c1-908c-2e2b1f63f4cd	478228db-82aa-42be-829f-547489a08838	document_processing	t	v1.0	2026-09-13 11:52:20.967
03445012-dbb9-4a19-9899-3eda64010038	478228db-82aa-42be-829f-547489a08838	mock_abdm_sharing	t	v1.0	2026-09-13 11:52:20.968
\.


--
-- Data for Name: document_entities; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.document_entities (id, document_id, entity_type, name, value, unit, abnormal) FROM stdin;
e7c5a521-897e-487d-8349-0b9f8fab6177	edefb0d4-0930-44b4-aed5-fa0ee60307fa	investigation	Hemoglobin	9.2	g/dL	t
5eaba5a1-b9c7-4359-a08f-1b06fdb56d5e	edefb0d4-0930-44b4-aed5-fa0ee60307fa	investigation	Blood Glucose	168	mg/dL	t
6510bb09-d891-4d2e-84db-e9ad29d755b0	edefb0d4-0930-44b4-aed5-fa0ee60307fa	medication	Metformin	500	mg	f
46845dbd-9908-4634-9628-42c85ca1f60d	09296dab-a428-4345-8aa7-9127a289c67a	investigation	Hemoglobin	9.2	g/dL	t
c0620b2b-e602-4604-b7e9-3b87a4764c25	09296dab-a428-4345-8aa7-9127a289c67a	investigation	Blood Glucose	168	mg/dL	t
88890915-d440-4026-b879-ba611d296363	09296dab-a428-4345-8aa7-9127a289c67a	medication	Metformin	500	mg	f
32e56401-a9b1-40a5-bc29-3142efa428ab	546eff00-bcc4-489c-b678-ac545432d1a3	investigation	Hemoglobin	9.2	g/dL	t
8d50ea5b-eb29-4e50-b07f-9e3a4194f053	546eff00-bcc4-489c-b678-ac545432d1a3	investigation	Blood Glucose	168	mg/dL	t
c32b20b8-871a-4d91-bbdf-30d159feb857	546eff00-bcc4-489c-b678-ac545432d1a3	medication	Metformin	500	mg	f
384f8049-a0ce-44cf-a653-cd32b6f9a176	4e7515c6-0c9e-4d6e-9ff3-1b3a1373d3ca	investigation	Hemoglobin	9.2	g/dL	t
5ff5516b-85ff-42f2-b71a-fb980f1ec80b	4e7515c6-0c9e-4d6e-9ff3-1b3a1373d3ca	investigation	Blood Glucose	168	mg/dL	t
92aeceaa-eb8c-4eee-b3cf-ada0f486d7db	4e7515c6-0c9e-4d6e-9ff3-1b3a1373d3ca	medication	Metformin	500	mg	f
7c06b3e4-3fed-43e1-ab99-ed0324a7943d	18f940ff-1a13-4d4c-8867-46f7712d4be3	investigation	Hemoglobin	9.2	g/dL	t
9f440b5e-48ea-4664-b43a-a1786b0752ae	18f940ff-1a13-4d4c-8867-46f7712d4be3	investigation	Blood Glucose	168	mg/dL	t
2bb8dfaf-2e85-4a5e-b083-38da0a6d8163	18f940ff-1a13-4d4c-8867-46f7712d4be3	medication	Metformin	500	mg	f
\.


--
-- Data for Name: documents; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.documents (id, visit_id, filename, type, ocr_status, extracted_text, created_at) FROM stdin;
edefb0d4-0930-44b4-aed5-fa0ee60307fa	20b32d23-3f26-4c05-9403-9c7a577a7850	previous_lab_report.pdf	lab_report	MOCK_COMPLETE	MOCK OCR — Hb 9.2 g/dL; Blood Glucose 168 mg/dL; Metformin 500 mg	2026-09-12 18:15:21.792
09296dab-a428-4345-8aa7-9127a289c67a	25873caf-7569-482c-8dee-15ae7a53f13d	previous_report.pdf	lab_report	MOCK_COMPLETE	MOCK OCR — Hb 9.2 g/dL; Blood Glucose 168 mg/dL; Metformin 500 mg	2026-09-12 18:19:45.575
546eff00-bcc4-489c-b678-ac545432d1a3	8f870d55-2f09-4dbc-8679-949faad408cc	app.js	lab_report	MOCK_COMPLETE	MOCK OCR — Hb 9.2 g/dL; Blood Glucose 168 mg/dL; Metformin 500 mg	2026-09-12 18:33:17.636
4e7515c6-0c9e-4d6e-9ff3-1b3a1373d3ca	8f870d55-2f09-4dbc-8679-949faad408cc	app.js	lab_report	MOCK_COMPLETE	MOCK OCR — Hb 9.2 g/dL; Blood Glucose 168 mg/dL; Metformin 500 mg	2026-09-12 18:33:19.439
18f940ff-1a13-4d4c-8867-46f7712d4be3	8f870d55-2f09-4dbc-8679-949faad408cc	app.js	lab_report	MOCK_COMPLETE	MOCK OCR — Hb 9.2 g/dL; Blood Glucose 168 mg/dL; Metformin 500 mg	2026-09-12 18:33:24.162
\.


--
-- Data for Name: history_answers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.history_answers (id, visit_id, question_id, label, answer, input_mode, created_at) FROM stdin;
c7f345be-89b4-421f-b8bd-637fb7650786	20b32d23-3f26-4c05-9403-9c7a577a7850	chief	What is troubling you today?	Severe chest pain and tightness	VOICE	2026-09-12 18:15:21.784
19030da3-13bb-4017-aba7-6de79a2abc7e	20b32d23-3f26-4c05-9403-9c7a577a7850	duration	When did this start?	1–3 days ago	VOICE	2026-09-12 18:15:21.786
e77f7da8-316b-4e82-ad80-83a6f9fc18e0	20b32d23-3f26-4c05-9403-9c7a577a7850	severity	How severe is it?	Severe (7–10)	VOICE	2026-09-12 18:15:21.787
4808eb41-5b8b-4065-b365-e5c3b1111377	20b32d23-3f26-4c05-9403-9c7a577a7850	breathlessness	Are you having difficulty breathing?	Yes	VOICE	2026-09-12 18:15:21.787
012a04d6-4994-4428-9420-b4818fb78b89	20b32d23-3f26-4c05-9403-9c7a577a7850	sweating	Any cold sweating, fainting, or dizziness?	Yes	VOICE	2026-09-12 18:15:21.788
65fb1f6b-fe74-44d6-8665-00a4ef46a5b8	20b32d23-3f26-4c05-9403-9c7a577a7850	history	Any known illness, medicines, or allergies?	Diabetes; Metformin 500 mg; no known allergies	VOICE	2026-09-12 18:15:21.788
ddbb7f4d-a7c8-4a9c-ae59-e13b7330fbb4	25873caf-7569-482c-8dee-15ae7a53f13d	chief	What is troubling you today?	Fever and body ache since morning	TEXT	2026-09-12 18:18:03.838
793517ea-3c02-4b22-a5db-70b3557884ba	25873caf-7569-482c-8dee-15ae7a53f13d	duration	When did this start?	Today	TOUCH	2026-09-12 18:18:28.052
2ccf7080-cc87-41aa-ab74-c25c96bdfac6	25873caf-7569-482c-8dee-15ae7a53f13d	severity	How severe is it?	Moderate (4–6)	TOUCH	2026-09-12 18:18:45.453
5bb031ca-8433-4fd8-8b8b-8302103db440	25873caf-7569-482c-8dee-15ae7a53f13d	breathlessness	Are you having difficulty breathing?	Yes	TOUCH	2026-09-12 18:19:00.152
454233d4-f223-4f2e-83eb-0343890e3df4	25873caf-7569-482c-8dee-15ae7a53f13d	sweating	Any cold sweating, fainting, or dizziness?	No	TOUCH	2026-09-12 18:19:08.445
6366936d-bc08-4294-a205-a5184fb1590a	25873caf-7569-482c-8dee-15ae7a53f13d	history	Any known illness, medicines, or allergies?	No known illness; not on any medication	TEXT	2026-09-12 18:19:24.453
8aa1aff4-ceeb-4873-a52e-6fa378979571	fc169399-15ff-4e25-ac5f-f4dad0083c72	chief	What is troubling you today?	Severe chest pain and tightness	VOICE	2026-09-12 18:23:48.661
a5813688-9f7c-4550-adaf-5b0aa671dd74	fc169399-15ff-4e25-ac5f-f4dad0083c72	duration	When did this start?	1–3 days ago	VOICE	2026-09-12 18:23:48.697
2a4f912e-8307-44bf-a280-5e075b1ff61a	fc169399-15ff-4e25-ac5f-f4dad0083c72	severity	How severe is it?	Severe (7–10)	VOICE	2026-09-12 18:23:48.739
0400f9bc-9e17-4ac3-9665-7f358a0381a8	fc169399-15ff-4e25-ac5f-f4dad0083c72	breathlessness	Are you having difficulty breathing?	Yes	VOICE	2026-09-12 18:23:48.795
b62a8878-b6a9-44be-afd9-402315643b83	fc169399-15ff-4e25-ac5f-f4dad0083c72	sweating	Any cold sweating, fainting, or dizziness?	Yes	VOICE	2026-09-12 18:23:48.841
d6e4eb8e-8b71-40ed-9f49-358397622672	fc169399-15ff-4e25-ac5f-f4dad0083c72	history	Any known illness, medicines, or allergies?	Diabetes; Metformin 500 mg; no known allergies	VOICE	2026-09-12 18:23:48.87
52fd01f0-985c-47d6-9896-32fb64e66807	789dca42-ac4c-4e92-8b63-c3bcc445beec	chief	What is troubling you today?	i have chest pain from 3 days	TEXT	2026-09-12 18:25:44.151
a8b2f2ea-0091-4b91-9f88-452d265f166b	789dca42-ac4c-4e92-8b63-c3bcc445beec	duration	When did this start?	1–3 days ago	TOUCH	2026-09-12 18:25:46.885
89a161cb-656f-49af-b77e-fd4bcbd49340	789dca42-ac4c-4e92-8b63-c3bcc445beec	prakriti	Prakriti (self-described constitution)	Mixed / not sure	TOUCH	2026-09-12 18:25:55.49
04eb8067-3dd0-445b-95de-f8ebb7c08d8b	8f870d55-2f09-4dbc-8679-949faad408cc	chief	What is troubling you today?	Severe chest pain and tightness	VOICE	2026-09-12 18:32:22.082
e87287e8-cb1a-4f03-bf3c-4b58c670ecdf	8f870d55-2f09-4dbc-8679-949faad408cc	duration	When did this start?	1–3 days ago	VOICE	2026-09-12 18:32:22.098
e6df100b-91b5-40c5-b513-4a4c38b83f11	8f870d55-2f09-4dbc-8679-949faad408cc	severity	How severe is it?	Severe (7–10)	VOICE	2026-09-12 18:32:22.11
25830d3d-6450-4edf-aef0-c6377bc3bbb9	8f870d55-2f09-4dbc-8679-949faad408cc	breathlessness	Are you having difficulty breathing?	Yes	VOICE	2026-09-12 18:32:22.122
d0271eb2-c452-420b-ad59-a2b999c12737	8f870d55-2f09-4dbc-8679-949faad408cc	sweating	Any cold sweating, fainting, or dizziness?	Yes	VOICE	2026-09-12 18:32:22.136
246f29ce-76e7-49cd-9f30-b545587670d0	8f870d55-2f09-4dbc-8679-949faad408cc	history	Any known illness, medicines, or allergies?	Diabetes; Metformin 500 mg; no known allergies	VOICE	2026-09-12 18:32:22.149
418685ed-18ee-4913-83cc-f6fd5923b9cb	e059bba2-29d2-4bef-b754-2197280b43a4	chief	What is troubling you today?	chest\n	TEXT	2026-09-12 18:39:53.466
00ce3ecd-51a0-49e3-b2f0-60d31d379812	e059bba2-29d2-4bef-b754-2197280b43a4	duration	When did this start?	1–3 days ago	TOUCH	2026-09-12 18:39:55.228
c9d25ea1-3632-403f-98a2-a0d964a5a580	e059bba2-29d2-4bef-b754-2197280b43a4	severity	How severe is it?	Moderate (4–6)	TOUCH	2026-09-12 18:39:59.278
98cb1a58-c2e0-4a16-bd39-db7dffd896e8	e059bba2-29d2-4bef-b754-2197280b43a4	breathlessness	Are you having difficulty breathing?	No	TOUCH	2026-09-12 18:40:04.062
097c49ac-4a7a-4a01-b526-dc2409eb39cb	e059bba2-29d2-4bef-b754-2197280b43a4	sweating	Any cold sweating, fainting, or dizziness?	Yes	TOUCH	2026-09-12 18:40:06.07
f17582ea-c7b2-494c-9e04-f5c9efeff03c	e059bba2-29d2-4bef-b754-2197280b43a4	history	Any known illness, medicines, or allergies?	had allergie hoil colors\n	TEXT	2026-09-12 18:40:57.627
7ae1d237-1482-4d46-b9a6-626a3bba2e25	2686b519-aaa2-4f4b-95a8-df3598f810a4	chief	What is troubling you today?	 having stomach pain	TEXT	2026-09-12 19:34:00.546
5be9280c-e066-4b19-bb87-39990d68b7cf	2686b519-aaa2-4f4b-95a8-df3598f810a4	duration	When did this start?	Today	TOUCH	2026-09-12 19:34:03.19
99013258-759e-4dfb-b962-6db8445e8868	2686b519-aaa2-4f4b-95a8-df3598f810a4	severity	How severe is it?	Moderate (4–6)	TOUCH	2026-09-12 19:34:07.551
e790145b-16f6-44f9-8ce6-b0bb698c326f	2686b519-aaa2-4f4b-95a8-df3598f810a4	breathlessness	Are you having difficulty breathing?	Yes	TOUCH	2026-09-12 19:34:10.025
5ba1e66e-8fd3-406d-8fd1-f0dda71754aa	2686b519-aaa2-4f4b-95a8-df3598f810a4	sweating	Any cold sweating, fainting, or dizziness?	No	TOUCH	2026-09-12 19:34:11.42
7e08fd63-eb11-495b-9a4f-bf5dea2a5ae2	2686b519-aaa2-4f4b-95a8-df3598f810a4	history	Any known illness, medicines, or allergies?	allergy from a medicine called citrizine	TEXT	2026-09-12 19:34:48.627
c290b59a-5d1d-455d-a201-ae74beac8893	6c954f15-d274-4366-b762-3bfd95975eaa	chief	What is troubling you today?	stomach ace\n	TEXT	2026-09-13 07:20:03.81
cb6386a7-46b4-45fe-b7e6-ca08aba702dc	6c954f15-d274-4366-b762-3bfd95975eaa	duration	When did this start?	1–3 days ago	TOUCH	2026-09-13 07:20:06.195
d81c56c6-c6df-4ba0-b239-790e9b7328c1	6c954f15-d274-4366-b762-3bfd95975eaa	severity	How severe is it?	Moderate (4–6)	TOUCH	2026-09-13 07:20:09.584
53ec1a9c-59f6-43ae-8771-ea773915f138	6c954f15-d274-4366-b762-3bfd95975eaa	breathlessness	Are you having difficulty breathing?	Yes	TOUCH	2026-09-13 07:20:13.194
f6ee7768-568f-4d11-88bb-4e5b646cd972	6c954f15-d274-4366-b762-3bfd95975eaa	sweating	Any cold sweating, fainting, or dizziness?	Yes	TOUCH	2026-09-13 07:20:15.318
52503c2c-e2b4-45c9-bc29-ddc31c269d89	6c954f15-d274-4366-b762-3bfd95975eaa	history	Any known illness, medicines, or allergies?	allergie from peanut	TEXT	2026-09-13 07:20:34.765
d88e7827-62be-4e0a-82aa-e7f1ccfa0960	e03c38b5-ea4d-495a-a2e6-e37e9b2fdae1	chief	What is troubling you today?	sijldosdo	TEXT	2026-09-13 07:23:40.029
f8388207-b29e-40a9-baf2-e4b340503957	e03c38b5-ea4d-495a-a2e6-e37e9b2fdae1	duration	When did this start?	1–3 days ago	TOUCH	2026-09-13 07:23:41.648
fec61761-02c4-46a1-a56f-575b75914e29	e03c38b5-ea4d-495a-a2e6-e37e9b2fdae1	prakriti	Prakriti (self-described constitution)	Mixed / not sure	TOUCH	2026-09-13 07:23:54.655
b6437e5b-fd10-4778-90b2-a03d93a0fb35	a557e8bb-26d9-4ad4-90ac-7ad1369ea797	chief	What is troubling you today?	suffering from stomach ache in 4 days	TEXT	2026-09-13 08:11:54.018
e9ab33ea-1e0e-4bfd-a310-4c71f8c2b475	a557e8bb-26d9-4ad4-90ac-7ad1369ea797	duration	When did this start?	1–3 days ago	TOUCH	2026-09-13 08:11:56.078
d6d997a8-02a9-4aae-8ad7-68a11acadbaa	616725f4-3987-4d13-b75b-5155e7680451	chief	What is troubling you today?	suffering from back pain	TEXT	2026-09-13 08:12:27.908
62f4e34f-364e-4fb3-bd4f-d757bbd61309	616725f4-3987-4d13-b75b-5155e7680451	duration	When did this start?	1–3 days ago	TOUCH	2026-09-13 08:12:35.842
74e0f4ba-93e9-424b-bc8f-5d5e8996b958	616725f4-3987-4d13-b75b-5155e7680451	severity	How severe is it?	Moderate (4–6)	TOUCH	2026-09-13 08:12:37.036
4ddc5eb7-2f88-438e-bb75-25f7be0f3afb	616725f4-3987-4d13-b75b-5155e7680451	breathlessness	Are you having difficulty breathing?	No	TOUCH	2026-09-13 08:12:44.459
75891388-986d-45ca-9cd1-72fef0e861a9	616725f4-3987-4d13-b75b-5155e7680451	sweating	Any cold sweating, fainting, or dizziness?	No	TOUCH	2026-09-13 08:12:47.241
423acf46-52b7-46f4-afb7-31f85712dae6	616725f4-3987-4d13-b75b-5155e7680451	history	Any known illness, medicines, or allergies?	no \n	TEXT	2026-09-13 08:12:56.284
73e54a45-7e1d-4df3-aed9-962b75c2bdea	40885c0f-fb17-4418-9f87-2a6166ce6508	chief	What is troubling you today?	Severe chest pain and tightness	VOICE	2026-09-13 09:16:06.35
864a076d-3668-425f-98ce-c2959e3c4fa1	40885c0f-fb17-4418-9f87-2a6166ce6508	duration	When did this start?	1–3 days ago	VOICE	2026-09-13 09:16:06.649
800c8125-3e11-4575-9f22-cbe1856e5b59	40885c0f-fb17-4418-9f87-2a6166ce6508	severity	How severe is it?	Severe (7–10)	VOICE	2026-09-13 09:16:06.758
7be763c7-dd16-417b-a8de-18da91f427ea	40885c0f-fb17-4418-9f87-2a6166ce6508	breathlessness	Are you having difficulty breathing?	Yes	VOICE	2026-09-13 09:16:06.79
1bffae31-f860-4a89-9a5e-21e77cc34245	40885c0f-fb17-4418-9f87-2a6166ce6508	sweating	Any cold sweating, fainting, or dizziness?	Yes	VOICE	2026-09-13 09:16:06.811
a8cfd0e1-2eca-44ca-8d85-04679fa66a29	40885c0f-fb17-4418-9f87-2a6166ce6508	history	Any known illness, medicines, or allergies?	Diabetes; Metformin 500 mg; no known allergies	VOICE	2026-09-13 09:16:06.835
ca93cba0-b039-4f92-a00c-46ced3f0edff	a46769a8-b0ef-4371-b158-973af7a05d37	chief	What is troubling you today?	Severe chest pain and tightness	VOICE	2026-09-13 09:17:50.768
d099a301-a00e-4a54-a294-0c026549bbbe	a46769a8-b0ef-4371-b158-973af7a05d37	duration	When did this start?	1–3 days ago	VOICE	2026-09-13 09:17:50.78
91b8c14e-96f6-4233-92c9-37647dfa3bc8	a46769a8-b0ef-4371-b158-973af7a05d37	severity	How severe is it?	Severe (7–10)	VOICE	2026-09-13 09:17:50.795
f68a501a-d482-465d-8240-4d580e7b1c57	a46769a8-b0ef-4371-b158-973af7a05d37	breathlessness	Are you having difficulty breathing?	Yes	VOICE	2026-09-13 09:17:50.809
9995737d-a3aa-497e-8089-b0c14aed7248	a46769a8-b0ef-4371-b158-973af7a05d37	sweating	Any cold sweating, fainting, or dizziness?	Yes	VOICE	2026-09-13 09:17:50.824
c36b9b2a-f0fa-4d65-9153-3a8e8e8d8c9a	a46769a8-b0ef-4371-b158-973af7a05d37	history	Any known illness, medicines, or allergies?	Diabetes; Metformin 500 mg; no known allergies	VOICE	2026-09-13 09:17:50.839
a6a94cc9-48da-456c-ae78-fb0e63e2d3b7	864b4751-9be4-4da9-963e-b81503232e05	chief	What is troubling you today?	I have pain and discomfort.	TEXT	2026-09-13 09:57:49.562
9e1c1778-6c1d-4de6-aea3-cca01db112b7	864b4751-9be4-4da9-963e-b81503232e05	duration	When did this start?	1–3 days ago	TOUCH	2026-09-13 09:57:51.055
83c3e0d9-4e3a-4839-8c34-d4ae96bd07d0	864b4751-9be4-4da9-963e-b81503232e05	severity	How severe is it?	Moderate (4–6)	TOUCH	2026-09-13 09:57:52.709
a57a17ce-bab9-4b42-900b-727726913879	864b4751-9be4-4da9-963e-b81503232e05	breathlessness	Are you having difficulty breathing?	Yes	TOUCH	2026-09-13 09:57:55.832
95749900-c6eb-473a-88d1-ea59e07a501f	864b4751-9be4-4da9-963e-b81503232e05	sweating	Any cold sweating, fainting, or dizziness?	Yes	TOUCH	2026-09-13 09:57:56.841
4d70d6e2-b725-46a9-96fb-8c7a1ac55f59	864b4751-9be4-4da9-963e-b81503232e05	history	Any known illness, medicines, or allergies?	no	TEXT	2026-09-13 09:58:03.2
62d00514-72dd-4f29-a31c-ca863032481f	d3cb01ad-a8da-406c-b9a4-46b7ffeecaa5	chief	What is troubling you today?	I have pain and discomfort.	TEXT	2026-09-13 10:14:51.498
c408cb9f-358a-4df0-bc79-ba703ffe052e	d3cb01ad-a8da-406c-b9a4-46b7ffeecaa5	duration	When did this start?	1–3 days ago	TOUCH	2026-09-13 10:14:53.423
626f54bc-5d21-42f0-83f7-16c60a3761a6	d3cb01ad-a8da-406c-b9a4-46b7ffeecaa5	severity	How severe is it?	Moderate (4–6)	TOUCH	2026-09-13 10:14:54.661
50b67af3-f609-442f-bdc5-020352f9a6f6	d3cb01ad-a8da-406c-b9a4-46b7ffeecaa5	breathlessness	Are you having difficulty breathing?	No	TOUCH	2026-09-13 10:14:56.719
310f5672-d6eb-46cf-b194-5f97cd12b536	d3cb01ad-a8da-406c-b9a4-46b7ffeecaa5	sweating	Any cold sweating, fainting, or dizziness?	No	TOUCH	2026-09-13 10:14:57.465
b7f2b536-3ce3-4ddd-94c9-eba0fd420cd1	d3cb01ad-a8da-406c-b9a4-46b7ffeecaa5	history	Any known illness, medicines, or allergies?	No known allergies.	TEXT	2026-09-13 10:15:03.34
d9de86a5-8d0c-407d-ad3f-627df5033f83	a88899d4-d874-4925-af37-aaf1e1862ece	chief	What is troubling you today?	Severe chest pain and tightness\n	TEXT	2026-09-13 10:31:04.307
beb258f1-6519-411e-89a1-c36f4382b469	a88899d4-d874-4925-af37-aaf1e1862ece	duration	When did this start?	1–3 days ago	TOUCH	2026-09-13 10:31:06.447
585c247e-b596-42cc-a3a8-0cc0f1d639cf	a88899d4-d874-4925-af37-aaf1e1862ece	severity	How severe is it?	Severe (7–10)	TOUCH	2026-09-13 10:31:07.857
8a94c6e9-2619-4363-ba77-5fe4d09ba5a0	a88899d4-d874-4925-af37-aaf1e1862ece	breathlessness	Are you having difficulty breathing?	Yes	TOUCH	2026-09-13 10:31:09.228
3542fc7d-4110-4a71-944d-36036b9a515f	a88899d4-d874-4925-af37-aaf1e1862ece	sweating	Any cold sweating, fainting, or dizziness?	Yes	TOUCH	2026-09-13 10:31:10.437
0409fc8c-7aee-4816-a77f-72efd16886c1	a88899d4-d874-4925-af37-aaf1e1862ece	history	Any known illness, medicines, or allergies?	No known allergies.	TEXT	2026-09-13 10:31:17.688
ab76db08-8724-4d53-bd4e-07c635dbcbd7	478228db-82aa-42be-829f-547489a08838	chief	What is troubling you today?	I have pain and discomfort.	TEXT	2026-09-13 11:52:26.522
20ceb996-d791-432e-aec1-58c2bb49cc1a	478228db-82aa-42be-829f-547489a08838	duration	When did this start?	1–3 days ago	TOUCH	2026-09-13 11:52:27.736
c7f9ebea-0fa6-4b0d-a8d9-24089000bad7	478228db-82aa-42be-829f-547489a08838	severity	How severe is it?	Mild (1–3)	TOUCH	2026-09-13 11:52:29.997
dc250c71-b21c-4275-bae5-1e87d76eca54	478228db-82aa-42be-829f-547489a08838	breathlessness	Are you having difficulty breathing?	No	TOUCH	2026-09-13 11:52:31.279
3840ea61-04b4-4bc5-996f-2b18d4e76ba0	478228db-82aa-42be-829f-547489a08838	sweating	Any cold sweating, fainting, or dizziness?	No	TOUCH	2026-09-13 11:52:31.661
8d418e1e-53d5-4d37-b6c4-d7c01f99ae9d	478228db-82aa-42be-829f-547489a08838	history	Any known illness, medicines, or allergies?	No known allergies.	TEXT	2026-09-13 11:52:36.01
\.


--
-- Data for Name: patients; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.patients (id, full_name, dob, gender, phone, abha_id, preferred_language, created_at, access_code, password_hash) FROM stdin;
d4b7be9c-9c5e-48b9-9437-6433cdb41ccc	Arjun Patel	1987-04-08	Male	9876543210	MOCK-ABHA-12345678	en	2026-09-12 18:15:20.852	\N	\N
dfd453cf-39f2-4e2c-9491-8c24d27aa728	Meera Sharma	1982-11-12	Female	9876543210	MOCK-ABHA-1e014a25	en	2026-09-12 18:15:21.776	\N	\N
2c8d23b2-e23d-4a72-9d8e-25172c0e3bad	Rohan Verma	1982-11-12	Female	9876543210	MOCK-ABHA-76a49f5d	en	2026-09-12 18:17:48.324	\N	\N
ff69d28e-8b68-4114-ba36-e205747342c7	Meera Sharma	1982-11-12	Female	9876543210	MOCK-ABHA-5785c794	en	2026-09-12 18:23:48.6	\N	\N
a070cbf5-2f3c-4d87-af97-b2a6fcfe9580	ishant	1982-11-12	Female	9876543210	MOCK-ABHA-06d7d6e2	en	2026-09-12 18:25:22.185	\N	\N
e222a2bb-3e34-412e-8e70-f029e6ace430	Meera Sharma	1982-11-12	Female	9876543210	MOCK-ABHA-c15adf1e	en	2026-09-12 18:32:22.054	\N	\N
6e281e71-fb6d-4787-b5d0-7ecd8d726d49	ishant	1982-11-12	Female	9876543210	MOCK-ABHA-a4e58fcf	en	2026-09-12 18:39:44.493	\N	\N
363458a3-180d-4e4f-a390-f30a90d27522	ishant	2012-02-07	Male	54546595945	MOCK-ABHA-a3ff73aa	en	2026-09-12 19:33:46.246	\N	\N
67b44451-b6df-4daa-b154-4a3755727e43	Ishant verma	2005-02-01	Male	8218149855	MOCK-ABHA-98923e6f	en	2026-09-13 07:19:54.263	\N	\N
52fa67cd-65ba-4fea-b536-aacc9354a1ac	aditya	2001-11-18	Female	945602317	MOCK-ABHA-35bb7115	en	2026-09-13 07:22:39.392	\N	\N
b5a77456-1449-41b7-bcb1-4abb9b07fd8f	ishant	2003-11-18	Male	8218149855	MOCK-ABHA-f538d283	en	2026-09-13 07:27:13.205	\N	\N
54db5b14-90b8-41bf-afc7-a85d66d3221e	ishant	2001-11-17	Male	54546595945	MOCK-ABHA-a45c44da	hi	2026-09-13 07:29:02.335	\N	\N
70f2e8b5-f087-4a26-a824-2f973a525c2c	ishant	2007-11-14	Male	4668892542	MOCK-ABHA-8151f664	en	2026-09-13 07:30:40.167	\N	\N
3050508d-b439-4f06-ba4b-0d039eed0cad	ishant	2001-02-16	Male	8218149855	MOCK-ABHA-b8191f0d	en	2026-09-13 07:37:36.516	\N	\N
7abfc5c8-fedc-4a5a-902d-7c96a94544db	ishu	2006-11-12	Male	9455020983	MOCK-ABHA-68182685	en	2026-09-13 08:01:53.517	\N	\N
edb6fe67-dde6-44bd-99f3-5765cd17899c	aditya	2007-11-18	Male	9455020983	MOCK-ABHA-ea041f41	en	2026-09-13 08:11:30.97	\N	\N
a379a0e5-6d04-429b-9fe3-fc12d81408ae	Ishant	2220-11-11	Male	9455020983	MOCK-ABHA-093183c0	en	2026-09-13 08:12:22.626	\N	\N
f193ac3d-db13-430d-99b9-63d80c10b469	Meera Sharma	1982-11-12	Female	9876543210	MOCK-ABHA-8163d800	en	2026-09-13 09:16:05.939	\N	\N
5c431e9c-b628-47a8-9198-ad0c71bcc699	Meera Sharma	1982-11-12	Female	9876543210	MOCK-ABHA-1cddcc85	en	2026-09-13 09:17:50.749	\N	\N
2f92a082-7014-4338-bf6f-b459e9fdca66	aryan	1998-11-14	Male	8218149855	MOCK-ABHA-63f9d3f7	en	2026-09-13 09:57:38.149	\N	\N
5a0f1c3c-75ad-48dc-beb6-83cc32b055eb	Aarav Test	\N	\N	9000000000	MOCK-ABHA-2087d96d	en	2026-09-13 10:08:02.501	PT-85E99B34	180b01d6e7676818bca7ee44f537aa73:c4d7e103ff9668f7ccc429d4ad48727cd7a9ba6c6708e6c72dec812dbb1b2ac786594ee0f79d45228d815978c24dc2adaf31c29674dcc1df0f4ca75a4a7f0903
c343a65b-2556-45bc-acec-c86f13b7c129	Ishant Verma	\N	\N	9453620558	MOCK-ABHA-23c7d4e5	en	2026-09-13 10:13:36.894	PT-A98CA3EA	44194df4b27de39cb0cf104dc9fa9ed7:8cd8398f4f8907f5844d5808bd82e45ceb3e3f91e21e4a91612810f56d2191e10e75ad1f416b9d5109845bb0f666dcec46e26d3aae19dad9b933e3a74adfb956
e9f2bb1d-abeb-48eb-8f01-257e57d75540	ishant	1998-09-14	Male	54546595945	MOCK-ABHA-9e53137f	en	2026-09-13 10:14:44.557	\N	\N
07a8a9b6-c277-4fef-9ebe-ad778ca9c30b	Aditya	2000-01-16	Male	9111111111	MOCK-ABHA-d8e45f18	en	2026-09-13 10:28:52.729	PT-ADITYA16	\N
3c9700e1-f241-4f0a-bccd-2f1c2a1fa173	ishant	2007-11-18	Male	945602317	MOCK-ABHA-0399ee8b	en	2026-09-13 10:26:21.663	PT-ISHANT18	\N
\.


--
-- Data for Name: red_flags; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.red_flags (id, visit_id, rule_id, severity, message, created_at) FROM stdin;
81dcfdd3-bdef-42a8-86f7-1c1628a27de9	20b32d23-3f26-4c05-9403-9c7a577a7850	CHEST_BREATHLESS	URGENT	Chest symptoms with breathlessness: immediate clinical assessment recommended.	2026-09-12 18:15:21.789
48697415-083a-4e7b-a333-13677586d475	20b32d23-3f26-4c05-9403-9c7a577a7850	CHEST_SWEATING	URGENT	Chest symptoms with sweating/dizziness: triage staff should assess now.	2026-09-12 18:15:21.79
5c8f55ca-c9cc-467a-a7e5-4c8af03956a9	fc169399-15ff-4e25-ac5f-f4dad0083c72	CHEST_BREATHLESS	URGENT	Chest symptoms with breathlessness: immediate clinical assessment recommended.	2026-09-12 18:23:48.874
43e8b926-d474-4f94-89af-2afb9023ce28	fc169399-15ff-4e25-ac5f-f4dad0083c72	CHEST_SWEATING	URGENT	Chest symptoms with sweating/dizziness: triage staff should assess now.	2026-09-12 18:23:48.874
8d6b4393-ea19-4179-aff5-73688a7bb57b	8f870d55-2f09-4dbc-8679-949faad408cc	CHEST_BREATHLESS	URGENT	Chest symptoms with breathlessness: immediate clinical assessment recommended.	2026-09-12 18:32:22.151
18220d5e-f013-40d1-8539-76b5646e2870	8f870d55-2f09-4dbc-8679-949faad408cc	CHEST_SWEATING	URGENT	Chest symptoms with sweating/dizziness: triage staff should assess now.	2026-09-12 18:32:22.151
fcadd5be-d09d-426a-90e5-83f65fb3d35b	40885c0f-fb17-4418-9f87-2a6166ce6508	CHEST_BREATHLESS	URGENT	Chest symptoms with breathlessness: immediate clinical assessment recommended.	2026-09-13 09:16:06.84
97f0c109-ba4a-4638-93e8-32844d7f2b53	40885c0f-fb17-4418-9f87-2a6166ce6508	CHEST_SWEATING	URGENT	Chest symptoms with sweating/dizziness: triage staff should assess now.	2026-09-13 09:16:06.84
5520ee1e-0b8c-487d-8911-fa998a029a6d	a46769a8-b0ef-4371-b158-973af7a05d37	CHEST_BREATHLESS	URGENT	Chest symptoms with breathlessness: immediate clinical assessment recommended.	2026-09-13 09:17:50.841
42f364c6-16bd-4c61-9ed5-6ee73dcc9c69	a46769a8-b0ef-4371-b158-973af7a05d37	CHEST_SWEATING	URGENT	Chest symptoms with sweating/dizziness: triage staff should assess now.	2026-09-13 09:17:50.841
134dfe18-37db-4473-80bd-c20f1a7f7c53	a88899d4-d874-4925-af37-aaf1e1862ece	CHEST_BREATHLESS	URGENT	Chest symptoms with breathlessness: immediate clinical assessment recommended.	2026-09-13 10:31:17.691
89a49694-9967-4260-9061-8c144400a384	a88899d4-d874-4925-af37-aaf1e1862ece	CHEST_SWEATING	URGENT	Chest symptoms with sweating/dizziness: triage staff should assess now.	2026-09-13 10:31:17.691
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (id, name, role, created_at, access_code, password_hash) FROM stdin;
c3197a6d-a301-4d58-bff4-778d5ab3744a	Dr. Ananya Rao	DOCTOR	2026-09-12 18:15:20.849	\N	\N
d6b776ef-8dd4-46ee-9c29-7e44a2e8251f	Demo Administrator	ADMIN	2026-09-12 18:15:20.849	\N	\N
0aa53915-7c90-4234-a4ab-8e841127372d	Kiosk (public)	PATIENT	2026-09-12 18:15:20.849	\N	\N
\.


--
-- Data for Name: visits; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.visits (id, patient_id, mode, status, priority, started_at, "completedAt") FROM stdin;
7c43581b-4a8d-4aa7-b706-2c9fcdebe2c3	d4b7be9c-9c5e-48b9-9437-6433cdb41ccc	GENERAL	READY_FOR_REVIEW	NORMAL	2026-09-12 18:15:20.854	2026-09-12 18:15:20.845
fc169399-15ff-4e25-ac5f-f4dad0083c72	ff69d28e-8b68-4114-ba36-e205747342c7	GENERAL	READY_FOR_REVIEW	URGENT	2026-09-12 18:23:48.604	2026-09-12 18:23:59.002
789dca42-ac4c-4e92-8b63-c3bcc445beec	a070cbf5-2f3c-4d87-af97-b2a6fcfe9580	AYUSH	IN_PROGRESS	NORMAL	2026-09-12 18:25:22.189	\N
864b4751-9be4-4da9-963e-b81503232e05	2f92a082-7014-4338-bf6f-b459e9fdca66	GENERAL	READY_FOR_REVIEW	NORMAL	2026-09-13 09:57:38.342	2026-09-13 09:58:07.084
25873caf-7569-482c-8dee-15ae7a53f13d	2c8d23b2-e23d-4a72-9d8e-25172c0e3bad	GENERAL	REVIEWED	NORMAL	2026-09-12 18:17:48.331	2026-09-12 18:19:55.192
a46769a8-b0ef-4371-b158-973af7a05d37	5c431e9c-b628-47a8-9198-ad0c71bcc699	GENERAL	READY_FOR_REVIEW	URGENT	2026-09-13 09:17:50.751	2026-09-13 09:17:52.203
20b32d23-3f26-4c05-9403-9c7a577a7850	dfd453cf-39f2-4e2c-9491-8c24d27aa728	GENERAL	READY_FOR_REVIEW	URGENT	2026-09-12 18:15:21.78	2026-09-12 18:15:21.79
8f870d55-2f09-4dbc-8679-949faad408cc	e222a2bb-3e34-412e-8e70-f029e6ace430	GENERAL	REVIEWED	URGENT	2026-09-12 18:32:22.058	2026-09-12 18:33:25.008
e059bba2-29d2-4bef-b754-2197280b43a4	6e281e71-fb6d-4787-b5d0-7ecd8d726d49	GENERAL	READY_FOR_REVIEW	NORMAL	2026-09-12 18:39:44.495	2026-09-12 18:41:04.716
d3cb01ad-a8da-406c-b9a4-46b7ffeecaa5	e9f2bb1d-abeb-48eb-8f01-257e57d75540	GENERAL	READY_FOR_REVIEW	NORMAL	2026-09-13 10:14:44.562	2026-09-13 10:15:05.954
2686b519-aaa2-4f4b-95a8-df3598f810a4	363458a3-180d-4e4f-a390-f30a90d27522	GENERAL	READY_FOR_REVIEW	NORMAL	2026-09-12 19:33:46.429	2026-09-12 19:34:52.472
a88899d4-d874-4925-af37-aaf1e1862ece	3c9700e1-f241-4f0a-bccd-2f1c2a1fa173	GENERAL	READY_FOR_REVIEW	URGENT	2026-09-13 10:30:59.813	2026-09-13 10:31:19.458
6c954f15-d274-4366-b762-3bfd95975eaa	67b44451-b6df-4daa-b154-4a3755727e43	GENERAL	READY_FOR_REVIEW	NORMAL	2026-09-13 07:19:54.302	2026-09-13 07:20:46.497
e03c38b5-ea4d-495a-a2e6-e37e9b2fdae1	52fa67cd-65ba-4fea-b536-aacc9354a1ac	AYUSH	IN_PROGRESS	NORMAL	2026-09-13 07:22:39.401	\N
8aa91ae0-acd4-4fe5-b171-1791215f58f2	b5a77456-1449-41b7-bcb1-4abb9b07fd8f	AYUSH	IN_PROGRESS	NORMAL	2026-09-13 07:27:13.213	\N
708225b5-71b9-445a-9e9d-0df6f413741d	54db5b14-90b8-41bf-afc7-a85d66d3221e	AYUSH	IN_PROGRESS	NORMAL	2026-09-13 07:29:02.346	\N
85a301ce-a419-4cc5-862c-55446da78227	70f2e8b5-f087-4a26-a824-2f973a525c2c	GENERAL	IN_PROGRESS	NORMAL	2026-09-13 07:30:40.456	\N
89c97d50-f9b3-451c-b8ab-7ad66e295af8	3050508d-b439-4f06-ba4b-0d039eed0cad	GENERAL	IN_PROGRESS	NORMAL	2026-09-13 07:37:36.706	\N
071bbfeb-a349-49fe-a2b8-900a6e95c1c3	7abfc5c8-fedc-4a5a-902d-7c96a94544db	GENERAL	IN_PROGRESS	NORMAL	2026-09-13 08:01:53.544	\N
a557e8bb-26d9-4ad4-90ac-7ad1369ea797	edb6fe67-dde6-44bd-99f3-5765cd17899c	GENERAL	IN_PROGRESS	NORMAL	2026-09-13 08:11:31.01	\N
478228db-82aa-42be-829f-547489a08838	3c9700e1-f241-4f0a-bccd-2f1c2a1fa173	GENERAL	READY_FOR_REVIEW	NORMAL	2026-09-13 11:52:20.963	2026-09-13 11:52:37.739
616725f4-3987-4d13-b75b-5155e7680451	a379a0e5-6d04-429b-9fe3-fc12d81408ae	GENERAL	READY_FOR_REVIEW	NORMAL	2026-09-13 08:12:22.631	2026-09-13 08:13:02.894
40885c0f-fb17-4418-9f87-2a6166ce6508	f193ac3d-db13-430d-99b9-63d80c10b469	GENERAL	READY_FOR_REVIEW	URGENT	2026-09-13 09:16:05.981	2026-09-13 09:16:15.653
\.


--
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- Name: clinical_summaries clinical_summaries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clinical_summaries
    ADD CONSTRAINT clinical_summaries_pkey PRIMARY KEY (id);


--
-- Name: consents consents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.consents
    ADD CONSTRAINT consents_pkey PRIMARY KEY (id);


--
-- Name: document_entities document_entities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_entities
    ADD CONSTRAINT document_entities_pkey PRIMARY KEY (id);


--
-- Name: documents documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- Name: history_answers history_answers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.history_answers
    ADD CONSTRAINT history_answers_pkey PRIMARY KEY (id);


--
-- Name: patients patients_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patients
    ADD CONSTRAINT patients_pkey PRIMARY KEY (id);


--
-- Name: red_flags red_flags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.red_flags
    ADD CONSTRAINT red_flags_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: visits visits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.visits
    ADD CONSTRAINT visits_pkey PRIMARY KEY (id);


--
-- Name: audit_logs_resource_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_logs_resource_id_idx ON public.audit_logs USING btree (resource_id);


--
-- Name: clinical_summaries_visit_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX clinical_summaries_visit_id_key ON public.clinical_summaries USING btree (visit_id);


--
-- Name: consents_visit_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX consents_visit_id_idx ON public.consents USING btree (visit_id);


--
-- Name: consents_visit_id_type_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX consents_visit_id_type_key ON public.consents USING btree (visit_id, type);


--
-- Name: document_entities_document_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX document_entities_document_id_idx ON public.document_entities USING btree (document_id);


--
-- Name: documents_visit_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX documents_visit_id_idx ON public.documents USING btree (visit_id);


--
-- Name: history_answers_visit_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX history_answers_visit_id_idx ON public.history_answers USING btree (visit_id);


--
-- Name: history_answers_visit_id_question_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX history_answers_visit_id_question_id_key ON public.history_answers USING btree (visit_id, question_id);


--
-- Name: patients_access_code_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX patients_access_code_key ON public.patients USING btree (access_code);


--
-- Name: red_flags_visit_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX red_flags_visit_id_idx ON public.red_flags USING btree (visit_id);


--
-- Name: users_access_code_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_access_code_key ON public.users USING btree (access_code);


--
-- Name: visits_priority_status_started_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX visits_priority_status_started_at_idx ON public.visits USING btree (priority, status, started_at DESC);


--
-- Name: clinical_summaries clinical_summaries_visit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clinical_summaries
    ADD CONSTRAINT clinical_summaries_visit_id_fkey FOREIGN KEY (visit_id) REFERENCES public.visits(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: consents consents_visit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.consents
    ADD CONSTRAINT consents_visit_id_fkey FOREIGN KEY (visit_id) REFERENCES public.visits(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: document_entities document_entities_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_entities
    ADD CONSTRAINT document_entities_document_id_fkey FOREIGN KEY (document_id) REFERENCES public.documents(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: documents documents_visit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_visit_id_fkey FOREIGN KEY (visit_id) REFERENCES public.visits(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: history_answers history_answers_visit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.history_answers
    ADD CONSTRAINT history_answers_visit_id_fkey FOREIGN KEY (visit_id) REFERENCES public.visits(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: red_flags red_flags_visit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.red_flags
    ADD CONSTRAINT red_flags_visit_id_fkey FOREIGN KEY (visit_id) REFERENCES public.visits(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: visits visits_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.visits
    ADD CONSTRAINT visits_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

\unrestrict dGTLfuBArNVfosm9prw0Vlcf35bBFefeZJNn0Yg57WVkLdHrNm9k0ZU8Li3uemg

