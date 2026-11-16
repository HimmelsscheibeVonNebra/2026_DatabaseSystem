Week 11 Class 01 — DBeaver SQL 실습

환경: PostgreSQL 16, DBeaver. 데이터는 수업용 가상 데이터입니다.
1. 새 PostgreSQL DB에서 00_setup.sql을 SQL 스크립트로 한 번 실행합니다.
   w11_demo 스키마가 이미 있다면 별도의 새 DB를 사용하세요. 자동 삭제 코드는 없습니다.
2. 01_star.sql부터 18_lambda.sql까지 원하는 파일을 DBeaver에서 열고 SQL문 실행을 합니다.
   01_all_queries.sql은 동일한 예제 전체 모음이며 setup 뒤에 실행합니다.
3. 각 쿼리는 w11_demo를 명시해 활성 스키마와 무관하게 실행됩니다.

현재 컴퓨터에서 만든 전용 실습 연결:
Host localhost / Port 55435 / Database postgres / User postgres / Password 빈칸
컨테이너: week11-analytics-v05. 이 컴퓨터의 loopback 인터페이스에만 연결됩니다.
같은 컨테이너가 없다면 별도 로컬 PostgreSQL을 사용하면 됩니다.

재현 데이터:
sales 36행, 총수량 164 / 여성복88·남성복76 / S64·M45·L55.
바지⇒벨트 지지도0.5·신뢰도0.714·향상도1.429.
단순선형회귀 절편8.8·기울기3.485714..., X7 예측33.2.
람다 배치10,250,000 + speed50,000 = combined10,300,000.

모델 예제의 범위:
09_tree는 주어진 트리의 일부 규칙 적용.
10_bayes는 두 후보 점수 비교와 후보 내 정규화.
11_svm은 가상 선형 경계 점수 계산, 12_neural은 가상 한 뉴런 순전파.
13_regression은 PostgreSQL 함수로 단순 선형 회귀 적합.
16_cluster는 k-평균의 배정 1단계. 반복 학습 전체가 아닙니다.
17_text는 감성 사전 조인. 부정문·반어를 이해하는 모델이 아닙니다.

람다 설계:
raw_event: 사건 단위 원본. event_id PK, (topic,partition_id,kafka_offset) UNIQUE.
item_dim: 상품 차원. item_name PK.
batch_run: 배치 버전·상태.
batch_cutoff: 배치별 파티션 경계. 누락 없는 연속 offset 구간만 게시.
batch_sales: batch_id × sale_date × item_name 단위 합계.
serving_head: 활성 배치 ID를 한 행에 저장.
speed_tail: 활성 batch_cutoff보다 뒤인 이벤트만 조회하는 교육용 뷰.
sales_current: 해당 배치와 최신 구간을 UNION ALL 후 집계한 뷰.
실제 Kafka·HDFS·MapReduce·Flink 클러스터를 실행한 예가 아니라
PostgreSQL로 경계와 결합 원리를 재현한 것입니다. 대규모 속도 계층은 증분 상태를 유지합니다.

DBeaver 캡처:
슬라이드에는 실제 SQL 편집기와 실제 결과 그리드를 각각 잘라 넣었습니다.
원본 화면과 결과를 합성해 만든 가짜 화면이 아닙니다. 전체 SQL은 각 파일과 발표자 노트에 있습니다.
