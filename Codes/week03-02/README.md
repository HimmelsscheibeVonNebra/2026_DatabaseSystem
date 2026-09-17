# 3주차 2차시 · 3-tier CRUD와 코드 해설

실습 코드와 SQLite 내부 소스 분석 도구를 별도 폴더로 구분합니다.

## 3-tier 애플리케이션 실습

[실행 안내](app/README.md) · [코드 해설](app/CODE_WALKTHROUGH.md) · [학생 실습지](app/WORKSHEET.md)

Python 3.10 이상이 필요합니다. 이 README가 있는 폴더에서 실행합니다.

```sh
cd app
python3 server.py
```

Windows에서는 `python3` 대신 `py -3`을 사용합니다. 브라우저에서 http://127.0.0.1:8765/ 를 엽니다. 첫 실행 시 `app/data/week3.db`를 만들고 가상 학생 5명을 준비합니다.

화면·Python 서버·SQLite의 논리적 3계층을 살펴보고, `app.js`, `server.py`, `service.py`, `repository.py`의 코드를 따라갑니다. SQLite 엔진은 서버 프로세스 안에서 실행됩니다.

## 별도 SQLite Parser 분석

[소스 분석 안내](parser-source/README.md)

`parser-source` 폴더에서 `python3 setup.py`를 실행합니다. Python과 C 컴파일러가 필요하며 macOS, Linux, Windows WSL을 지원합니다. 동봉한 SQLite 3.53.4 공식 아카이브의 해시를 확인한 뒤 관찰 도구를 빌드합니다.

웹 실습의 Python 내장 SQLite와 별도 빌드한 분석 도구의 실행 환경을 구분합니다. 내부 Parser 설명과 과제는 애플리케이션 실습과 분리합니다.

[강의 슬라이드](../../Presentations/week03-02/README.md)
