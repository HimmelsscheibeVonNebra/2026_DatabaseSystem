/* 내부 토크나이저 관찰 전용. 제품 코드에서 내부 API에 의존하면 안 된다. */
#include "sqlite3.c"
#include <stdio.h>
#include <string.h>

static const char *kind(int type){
  switch(type){
    case TK_SELECT: return "TK_SELECT";
    case TK_FROM: return "TK_FROM";
    case TK_WHERE: return "TK_WHERE";
    case TK_ID: return "TK_ID";
    case TK_VARIABLE: return "TK_VARIABLE";
    case TK_EQ: return "TK_EQ";
    case TK_INTEGER: return "TK_INTEGER";
    case TK_STRING: return "TK_STRING";
    case TK_SPACE: return "TK_SPACE";
    case TK_COMMENT: return "TK_COMMENT";
    case TK_SEMI: return "TK_SEMI";
    case TK_ILLEGAL: return "TK_ILLEGAL";
    default: return "OTHER";
  }
}
int main(int argc, char **argv){
  const char *sql = argc == 2 ? argv[1] : "SELECT name FROM student WHERE id = ?1;";
  if(argc > 2 || strlen(sql) > 1024){
    fprintf(stderr, "사용법: token_probe [1024바이트 이하 SQL]\n"); return 2;
  }
  printf("SQLite %s / 실제 sqlite3GetToken 결과\n", sqlite3_libversion());
  puts("offset\tbytes\ttype\tlexeme");
  for(sqlite3_int64 offset=0; sql[offset];){
    int type;
    sqlite3_int64 bytes = sqlite3GetToken((const unsigned char *)sql+offset, &type);
    if(bytes <= 0) return 1;
    printf("%lld\t%lld\t%s\t%.*s\n", offset, bytes, kind(type), (int)bytes, sql+offset);
    offset += bytes;
  }
  return 0;
}
