-- PostgreSQL 16. 수업용 가상 데이터. 새 실습 schema에만 생성한다.
CREATE SCHEMA w11_demo;
SET search_path TO w11_demo, public;
CREATE TABLE item_dim(item_name text PRIMARY KEY, category text NOT NULL);
INSERT INTO item_dim VALUES ('치마','여성복'),('원피스','여성복'),('셔츠','남성복'),('바지','남성복');
CREATE TABLE sales(item_name text REFERENCES item_dim, color text, size text, quantity int NOT NULL CHECK(quantity>=0), PRIMARY KEY(item_name,color,size));
INSERT INTO sales VALUES
('치마','진한색','S',2),
('치마','진한색','M',5),
('치마','진한색','L',1),
('치마','파스텔','S',11),
('치마','파스텔','M',9),
('치마','파스텔','L',15),
('치마','흰색','S',1),
('치마','흰색','M',6),
('치마','흰색','L',3),
('원피스','진한색','S',2),
('원피스','진한색','M',6),
('원피스','진한색','L',12),
('원피스','파스텔','S',4),
('원피스','파스텔','M',3),
('원피스','파스텔','L',3),
('원피스','흰색','S',2),
('원피스','흰색','M',3),
('원피스','흰색','L',0),
('셔츠','진한색','S',6),
('셔츠','진한색','M',2),
('셔츠','진한색','L',6),
('셔츠','파스텔','S',4),
('셔츠','파스텔','M',1),
('셔츠','파스텔','L',2),
('셔츠','흰색','S',17),
('셔츠','흰색','M',1),
('셔츠','흰색','L',10),
('바지','진한색','S',14),
('바지','진한색','M',6),
('바지','진한색','L',0),
('바지','파스텔','S',1),
('바지','파스텔','M',0),
('바지','파스텔','L',1),
('바지','흰색','S',0),
('바지','흰색','M',3),
('바지','흰색','L',2);
CREATE TABLE customer_case(id int PRIMARY KEY, degree text, income int);
INSERT INTO customer_case VALUES (1,'석사',40000),(2,'학사',30000),(3,'박사',90000);
CREATE TABLE bayes_likelihood(class text PRIMARY KEY, prior numeric, likelihood numeric);
INSERT INTO bayes_likelihood VALUES ('우수',0.1,0.1),('좋음',0.3,0.05);
CREATE TABLE ad_sales(x float8 PRIMARY KEY, y float8);
INSERT INTO ad_sales VALUES (1,12),(2,15),(3,21),(4,22),(5,27),(6,29);
CREATE TABLE prediction(actual int, predicted int, n int);
INSERT INTO prediction VALUES(1,1,80),(1,0,20),(0,1,95),(0,0,1805);
CREATE TABLE basket(tx int, item text, PRIMARY KEY(tx,item));
INSERT INTO basket VALUES (1,'셔츠'),(1,'바지'),(1,'벨트'),(2,'셔츠'),(2,'바지'),(3,'바지'),(3,'벨트'),(4,'셔츠'),(4,'양말'),(5,'셔츠'),(5,'바지'),(5,'벨트'),(5,'양말'),(6,'양말'),(6,'치마'),(7,'셔츠'),(7,'바지'),(7,'양말'),(8,'바지'),(8,'벨트'),(9,'셔츠'),(9,'치마'),(10,'바지'),(10,'벨트'),(10,'양말');
CREATE TABLE customer_point(id int PRIMARY KEY,x numeric,y numeric);
INSERT INTO customer_point VALUES(1,1,1),(2,2,1),(3,8,8),(4,9,8);
CREATE TABLE center(id int PRIMARY KEY,x numeric,y numeric);
INSERT INTO center VALUES(1,1,1),(2,8,8);
CREATE TABLE review(id int PRIMARY KEY, body text);
INSERT INTO review VALUES(1,'품질이 좋다'),(2,'배송이 나쁘다'),(3,'그냥 보통이다');
CREATE TABLE lexicon(word text PRIMARY KEY, score int);
INSERT INTO lexicon VALUES('좋다',1),('나쁘다',-1);
-- 람다 원본: DB 표는 Kafka/HDFS 이벤트 형식의 교육용 관계형 표현이다.
CREATE TABLE raw_event(
 event_id text PRIMARY KEY, topic text NOT NULL, partition_id int NOT NULL,
 kafka_offset bigint NOT NULL, occurred_at timestamptz NOT NULL,
 ingested_at timestamptz NOT NULL, item_name text NOT NULL REFERENCES item_dim,
 amount numeric(14,2) NOT NULL, UNIQUE(topic,partition_id,kafka_offset));
INSERT INTO raw_event VALUES
('e1','sales',0,0,'2026-11-10 09:00+09','2026-11-10 09:00+09','치마',10000000),
('e2','sales',0,1,'2026-11-10 10:00+09','2026-11-10 10:00+09','치마',250000),
('e3','sales',0,2,'2026-11-10 10:05+09','2026-11-10 10:05+09','치마',50000);
CREATE TABLE batch_run(
 batch_id int PRIMARY KEY,status text NOT NULL CHECK(status IN('building','ready')));
CREATE TABLE batch_cutoff(
 batch_id int REFERENCES batch_run, topic text, partition_id int, max_offset bigint NOT NULL,
 PRIMARY KEY(batch_id,topic,partition_id));
CREATE TABLE batch_sales(
 batch_id int REFERENCES batch_run, sale_date date, item_name text REFERENCES item_dim,
 amount numeric(14,2) NOT NULL, PRIMARY KEY(batch_id,sale_date,item_name));
CREATE TABLE serving_head(
 singleton boolean PRIMARY KEY DEFAULT true CHECK(singleton),
 active_batch_id int NOT NULL REFERENCES batch_run);
INSERT INTO batch_run VALUES(1,'ready'),(2,'ready');
INSERT INTO batch_cutoff VALUES(1,'sales',0,0),(2,'sales',0,1);
INSERT INTO batch_sales VALUES(1,'2026-11-10','치마',10000000),(2,'2026-11-10','치마',10250000);
INSERT INTO serving_head VALUES(true,2);
CREATE VIEW speed_tail AS
 SELECT h.active_batch_id AS batch_id,e.* FROM serving_head h
 JOIN batch_cutoff c ON c.batch_id=h.active_batch_id
 JOIN raw_event e ON e.topic=c.topic AND e.partition_id=c.partition_id
 WHERE e.kafka_offset>c.max_offset;
CREATE VIEW sales_current AS
 SELECT sale_date,item_name,sum(amount) AS amount FROM (
 SELECT b.sale_date,b.item_name,b.amount FROM batch_sales b
 JOIN serving_head h ON b.batch_id=h.active_batch_id
 UNION ALL
 SELECT (occurred_at AT TIME ZONE 'Asia/Seoul')::date,item_name,amount FROM speed_tail
 ) u GROUP BY sale_date,item_name;
