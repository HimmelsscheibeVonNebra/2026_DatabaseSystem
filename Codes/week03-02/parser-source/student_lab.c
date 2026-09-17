/* Week 3-2: 공식 SQLite 3.53.4 C API로 구현한 CRUD / Binding 실습. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <limits.h>
#include "sqlite3.h"

typedef struct { int type; int number; const char *text; } Value;
enum { VALUE_INT, VALUE_TEXT, VALUE_NULL };
static int trace_enabled;

static void trace(const char *api, int rc){
  if(trace_enabled) fprintf(stderr, "[API] %-24s rc=%d\n", api, rc);
}
static int report(sqlite3 *db, const char *stage, int rc){
  fprintf(stderr, "ERROR %s rc=%d: %s\n", stage, rc, sqlite3_errmsg(db));
  return rc;
}
static int integer(const char *text, int *result){
  char *end = NULL;
  errno = 0;
  long n = strtol(text, &end, 10);
  if(errno || end == text || *end || n < INT_MIN || n > INT_MAX) return 0;
  *result = (int)n;
  return 1;
}
static int valid_text(const char *text){
  return *text && strlen(text) <= 128 && !strpbrk(text, "\t\r\n");
}
static void print_row(sqlite3_stmt *stmt){
  int count = sqlite3_column_count(stmt);
  for(int i=0; i<count; i++){
    if(i) putchar('\t');
    if(sqlite3_column_type(stmt, i) == SQLITE_NULL) fputs("NULL", stdout);
    else fputs((const char *)sqlite3_column_text(stmt, i), stdout);
  }
  putchar('\n');
}

/* 고정 SQL을 준비한 뒤, 데이터만 별도로 바인딩한다. */
static int run(sqlite3 *db, const char *sql, const Value *values, int count){
  sqlite3_stmt *stmt = NULL;
  int rc = sqlite3_prepare_v2(db, sql, -1, &stmt, NULL);
  trace("sqlite3_prepare_v2", rc);
  if(rc != SQLITE_OK) return report(db, "prepare", rc);
  if(!stmt){ fprintf(stderr, "ERROR: empty statement\n"); return SQLITE_ERROR; }
  if(sqlite3_bind_parameter_count(stmt) != count){
    fprintf(stderr, "ERROR: parameter count mismatch\n");
    sqlite3_finalize(stmt);
    return SQLITE_RANGE;
  }
  for(int i=0; i<count; i++){
    if(values[i].type == VALUE_INT){
      rc = sqlite3_bind_int(stmt, i+1, values[i].number);
      trace("sqlite3_bind_int", rc);
    }else if(values[i].type == VALUE_NULL){
      rc = sqlite3_bind_null(stmt, i+1);
      trace("sqlite3_bind_null", rc);
    }else{
      rc = sqlite3_bind_text(stmt, i+1, values[i].text, -1,
                             SQLITE_TRANSIENT);
      trace("sqlite3_bind_text", rc);
    }
    if(rc != SQLITE_OK){
      report(db, "bind", rc);
      sqlite3_finalize(stmt);
      return rc;
    }
  }
  int rows = 0;
  int columns = sqlite3_column_count(stmt);
  if(columns){
    for(int i=0; i<columns; i++){
      if(i) putchar('\t');
      fputs(sqlite3_column_name(stmt, i), stdout);
    }
    putchar('\n');
  }
  while((rc = sqlite3_step(stmt)) == SQLITE_ROW){
    trace("sqlite3_step", rc);
    print_row(stmt);
    rows++;
  }
  trace("sqlite3_step", rc);
  if(rc != SQLITE_DONE) report(db, "step", rc);
  int success = rc == SQLITE_DONE;
  if(success){
    if(columns) printf("rows=%d\n", rows);
    else printf("changes=%d\n", sqlite3_changes(db));
  }
  int final_rc = sqlite3_finalize(stmt);
  trace("sqlite3_finalize", final_rc);
  if(final_rc != SQLITE_OK && success) report(db, "finalize", final_rc);
  return success ? final_rc : rc;
}

static int initialize(sqlite3 *db){
  sqlite3_stmt *stmt = NULL;
  int rc = sqlite3_prepare_v2(db,
    "SELECT 1 FROM sqlite_schema WHERE type='table' AND name='student'",
    -1, &stmt, NULL);
  if(rc != SQLITE_OK) return report(db, "init prepare", rc);
  rc = sqlite3_step(stmt);
  int exists = rc == SQLITE_ROW;
  sqlite3_finalize(stmt);
  if(exists){ puts("기존 student 테이블을 보존했습니다."); return SQLITE_OK; }
  if(rc != SQLITE_DONE) return report(db, "init step", rc);
  const char *seed =
    "BEGIN;"
    "CREATE TABLE department(dept_name TEXT PRIMARY KEY NOT NULL);"
    "CREATE TABLE student("
    "id INTEGER PRIMARY KEY, name TEXT NOT NULL,"
    "dept_name TEXT REFERENCES department(dept_name),"
    "tot_cred INTEGER NOT NULL CHECK(tot_cred BETWEEN 0 AND 200));"
    "INSERT INTO department VALUES('컴퓨터공학'),('수학'),('경영학');"
    "INSERT INTO student VALUES"
    "(1001,'김민지','컴퓨터공학',42),"
    "(1002,'이서준','수학',30),"
    "(1003,'박지우','컴퓨터공학',18),"
    "(1004,'최하린','경영학',54),"
    "(1005,'정도윤',NULL,0);"
    "COMMIT;";
  char *error = NULL;
  rc = sqlite3_exec(db, seed, NULL, NULL, &error);
  if(rc != SQLITE_OK){
    fprintf(stderr, "초기화 오류: %s\n", error ? error : sqlite3_errmsg(db));
    sqlite3_free(error);
    sqlite3_exec(db, "ROLLBACK;", NULL, NULL, NULL);
  }else puts("가상 학생 5명의 실습 DB를 만들었습니다.");
  return rc;
}

/* reset 이후의 값 유지와 clear_bindings 이후의 NULL을 직접 관찰한다. */
static int binding_demo(sqlite3 *db){
  sqlite3_stmt *stmt = NULL;
  int rc = sqlite3_prepare_v2(db, "SELECT ?1 AS text, ?2 AS number;", -1, &stmt, NULL);
  trace("sqlite3_prepare_v2", rc);
  if(rc != SQLITE_OK) return report(db, "prepare", rc);
  rc = sqlite3_bind_text(stmt, 1, "한글", -1, SQLITE_TRANSIENT);
  trace("sqlite3_bind_text", rc);
  if(rc != SQLITE_OK) goto done;
  rc = sqlite3_bind_int(stmt, 2, 42);
  trace("sqlite3_bind_int", rc);
  if(rc != SQLITE_OK) goto done;
  for(int phase=0; phase<3; phase++){
    printf("phase=%d\n", phase+1);
    rc = sqlite3_step(stmt);
    trace("sqlite3_step", rc);
    if(rc != SQLITE_ROW) goto done;
    print_row(stmt);
    rc = sqlite3_step(stmt);
    trace("sqlite3_step", rc);
    if(rc != SQLITE_DONE) goto done;
    rc = sqlite3_reset(stmt);
    trace("sqlite3_reset", rc);
    if(rc != SQLITE_OK) goto done;
    if(phase == 1){
      rc = sqlite3_clear_bindings(stmt);
      trace("sqlite3_clear_bindings", rc);
      if(rc != SQLITE_OK) goto done;
      rc = sqlite3_bind_text(stmt, 1, "새 값", -1, SQLITE_TRANSIENT);
      trace("sqlite3_bind_text", rc);
      if(rc != SQLITE_OK) goto done;
    }
  }
done:
  if(rc != SQLITE_OK) report(db, "binding demo", rc);
  int final_rc = sqlite3_finalize(stmt);
  trace("sqlite3_finalize", final_rc);
  return rc == SQLITE_OK ? final_rc : rc;
}

/* 고정된 SELECT만 준비한다. SQL 실행(sqlite3_step)은 하지 않는다. */
static int parser_demo(sqlite3 *db, const char *mode){
  const char *sql;
  if(strcmp(mode, "ok") == 0) sql = "SELECT name FROM student WHERE id = ?1;";
  else if(strcmp(mode, "syntax") == 0) sql = "SELECT FROM student;";
  else if(strcmp(mode, "name") == 0) sql = "SELECT missing_column FROM student;";
  else { fprintf(stderr, "parser 모드: ok / syntax / name\n"); return SQLITE_MISUSE; }
  if(!sqlite3_compileoption_used("DEBUG")){
    fprintf(stderr, "SQLITE_DEBUG 빌드가 필요합니다.\n"); return SQLITE_MISUSE;
  }
  sqlite3_stmt *stmt = NULL;
  int rc = sqlite3_prepare_v2(db, "SELECT name FROM student LIMIT 0;", -1, &stmt, NULL);
  if(rc != SQLITE_OK) return report(db, "schema warmup", rc);
  sqlite3_finalize(stmt);
  rc = sqlite3_exec(db, "PRAGMA parser_trace=ON;", NULL, NULL, NULL);
  if(rc != SQLITE_OK) return report(db, "parser trace", rc);
  printf("INPUT: %s\n", sql);
  stmt = NULL;
  rc = sqlite3_prepare_v2(db, sql, -1, &stmt, NULL);
  printf("PREPARE rc=%d parameters=%d\n", rc,
         stmt ? sqlite3_bind_parameter_count(stmt) : 0);
  if(rc != SQLITE_OK) fprintf(stderr, "PREPARE ERROR: %s\n", sqlite3_errmsg(db));
  sqlite3_finalize(stmt);
  return rc;
}

static void usage(const char *program){
  fprintf(stderr,
    "사용법: %s DB파일 명령 [값...]\n"
    "  init / version / list / binding-demo\n"
    "  get ID / search 이름\n"
    "  add ID 이름 학과 학점  (학과가 - 이면 NULL)\n"
    "  update ID 학점 / delete ID\n"
    "  parser ok|syntax|name\n"
    "호출 기록: LAB_TRACE=1 환경 변수를 지정하세요.\n", program);
}

int main(int argc, char **argv){
  if(argc < 3){ usage(argv[0]); return 2; }
  trace_enabled = getenv("LAB_TRACE") != NULL;
  const char *cmd = argv[2];
  sqlite3 *db = NULL;
  int flags = SQLITE_OPEN_READWRITE;
  if(strcmp(cmd, "init") == 0) flags |= SQLITE_OPEN_CREATE;
  int rc = sqlite3_open_v2(argv[1], &db, flags, NULL);
  trace("sqlite3_open_v2", rc);
  if(rc != SQLITE_OK){
    fprintf(stderr, "DB 열기 오류: %s\n", db ? sqlite3_errmsg(db) : "메모리 부족");
    sqlite3_close(db); return 1;
  }
  sqlite3_busy_timeout(db, 1500);
  rc = sqlite3_exec(db, "PRAGMA foreign_keys=ON;", NULL, NULL, NULL);
  if(rc != SQLITE_OK){ report(db, "foreign_keys", rc); sqlite3_close(db); return 1; }
  Value values[4];
  int id, credits;
  if(strcmp(cmd, "init") == 0 && argc == 3) rc = initialize(db);
  else if(strcmp(cmd, "version") == 0 && argc == 3){
    printf("SQLite %s\n%s\nSQLITE_DEBUG=%d\n", sqlite3_libversion(),
           sqlite3_sourceid(), sqlite3_compileoption_used("DEBUG"));
  }else if(strcmp(cmd, "list") == 0 && argc == 3){
    rc = run(db, "SELECT id,name,dept_name,tot_cred FROM student ORDER BY id;", NULL, 0);
  }else if(strcmp(cmd, "get") == 0 && argc == 4 && integer(argv[3], &id)){
    values[0] = (Value){VALUE_INT, id, NULL};
    rc = run(db, "SELECT id,name,dept_name,tot_cred FROM student WHERE id=?1;", values, 1);
  }else if(strcmp(cmd, "search") == 0 && argc == 4 && valid_text(argv[3])){
    values[0] = (Value){VALUE_TEXT, 0, argv[3]};
    rc = run(db, "SELECT id,name,dept_name,tot_cred FROM student WHERE name=?1 ORDER BY id;", values, 1);
  }else if(strcmp(cmd, "add") == 0 && argc == 7 && integer(argv[3], &id)
           && valid_text(argv[4]) && valid_text(argv[5]) && integer(argv[6], &credits)){
    values[0] = (Value){VALUE_INT, id, NULL};
    values[1] = (Value){VALUE_TEXT, 0, argv[4]};
    values[2] = (Value){strcmp(argv[5], "-") == 0 ? VALUE_NULL : VALUE_TEXT, 0, argv[5]};
    values[3] = (Value){VALUE_INT, credits, NULL};
    rc = run(db, "INSERT INTO student(id,name,dept_name,tot_cred) VALUES(?1,?2,?3,?4);", values, 4);
  }else if(strcmp(cmd, "update") == 0 && argc == 5 && integer(argv[3], &id) && integer(argv[4], &credits)){
    values[0] = (Value){VALUE_INT, credits, NULL};
    values[1] = (Value){VALUE_INT, id, NULL};
    rc = run(db, "UPDATE student SET tot_cred=?1 WHERE id=?2;", values, 2);
  }else if(strcmp(cmd, "delete") == 0 && argc == 4 && integer(argv[3], &id)){
    values[0] = (Value){VALUE_INT, id, NULL};
    rc = run(db, "DELETE FROM student WHERE id=?1;", values, 1);
  }else if(strcmp(cmd, "binding-demo") == 0 && argc == 3) rc = binding_demo(db);
  else if(strcmp(cmd, "parser") == 0 && argc == 4) rc = parser_demo(db, argv[3]);
  else { usage(argv[0]); rc = SQLITE_MISUSE; }
  int closed = sqlite3_close(db);
  trace("sqlite3_close", closed);
  return rc == SQLITE_OK && closed == SQLITE_OK ? 0 : 1;
}
