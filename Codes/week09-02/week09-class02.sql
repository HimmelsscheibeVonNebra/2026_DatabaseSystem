-- Week 09 Class 02 · GIS 서버 접속과 샘플 프로그램
-- 슬라이드에 나온 SQL 원문 모음. DBeaver SQL Editor에 그대로 붙여 넣어 실행한다.
-- 서버: 203.252.136.17 : 54321 · Database osm · PostGIS 3.4.3
-- 실행: 커서를 문장 위에 두고 Ctrl+Enter (Mac: Cmd+Enter)

-- [슬라이드 18] ⑤ SQL Editor에서 첫 질의
SELECT version();

SELECT postgis_full_version();

-- [슬라이드 19·20] 공간 테이블 목록 찾기
SELECT f_table_schema, f_table_name,
       f_geometry_column, type, srid
FROM   geometry_columns
ORDER  BY 1, 2;

-- [슬라이드 21·22] 공간 열을 읽는 질의
SELECT ST_GeometryType(geom) AS 유형,
       ST_SRID(geom)         AS srid,
       ST_AsText(geom)       AS wkt
FROM   public.points
WHERE  name IS NOT NULL
LIMIT  20;

-- [슬라이드 23] 공간 데이터 보기 — geom 열을 함께 가져와 결과 패널의 Spatial 탭으로 본다
SELECT node_id, name,
       ST_GeometryType(geom) AS 유형,
       ST_SRID(geom)         AS srid,
       ST_AsText(geom)       AS wkt,
       geom
FROM   public.points
WHERE  name IS NOT NULL
LIMIT  20;

-- [슬라이드 28] 샘플 1: 접속 확인 (Python 코드 안의 SQL)
SELECT current_database(), current_user, postgis_version();

-- [슬라이드 29] 샘플 2: 공간 테이블 목록 (Python 코드 안의 SQL)
SELECT f_table_schema, f_table_name,
       f_geometry_column, type, srid
FROM   geometry_columns ORDER BY 1, 2;

-- [슬라이드 30] 샘플 3: 공간 열 읽기 — Python에서는 {c}·{t}를 sql.Identifier로, %s를 값으로 채운다
SELECT ST_AsText(geom) FROM public.points LIMIT 5;

-- [슬라이드 31] 샘플 4: 가까운 도형 찾기 — 서울시청(126.9780, 37.5665)에서 가까운 5개, 거리는 미터
SELECT ST_AsText(geom), ST_Distance(
      ST_Transform(geom, 4326)::geography,
      ST_SetSRID(ST_MakePoint(126.9780, 37.5665), 4326)::geography) AS m
FROM   public.points
ORDER  BY m LIMIT 5;
