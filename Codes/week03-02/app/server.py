"""수업용 로컬 HTTP 서버. Python 3.10+, 외부 패키지 없음."""
import argparse
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import json
from pathlib import Path
import re
import sqlite3
from urllib.parse import parse_qs, urlsplit
from repository import Repository
from service import Service, InputError, NotFound

ROOT = Path(__file__).resolve().parent

class Handler(BaseHTTPRequestHandler):
    def send(self, status, value, content_type='application/json; charset=utf-8'):
        data = json.dumps(value, ensure_ascii=False).encode() if isinstance(value, dict) else value
        self.send_response(status)
        self.send_header('Content-Type', content_type)
        self.send_header('Content-Length', str(len(data)))
        self.send_header('Cache-Control', 'no-store')
        self.send_header('X-Content-Type-Options', 'nosniff')
        self.send_header('Content-Security-Policy', "default-src 'self'; frame-ancestors 'none'")
        self.end_headers()
        self.wfile.write(data)

    def dispatch(self):
        # localhost 수업 서버의 동일 출처 요청만 처리한다.
        host = self.headers.get('Host', '')
        allowed = {f'127.0.0.1:{self.server.server_port}', f'localhost:{self.server.server_port}'}
        if host not in allowed or self.headers.get('Origin') not in (None, 'http://' + host):
            self.send(403, {'ok': False, 'error': '동일 출처 요청만 허용합니다.', 'stage': 'HTTP'})
            return
        url = urlsplit(self.path)
        files = {'/': ('index.html', 'text/html'), '/app.js': ('app.js', 'text/javascript'), '/style.css': ('style.css', 'text/css')}
        if self.command == 'GET' and url.path in files:
            name, mime = files[url.path]
            self.send(200, (ROOT / 'static' / name).read_bytes(), mime + '; charset=utf-8')
            return
        if self.command == 'GET' and url.path == '/api/info':
            self.send(200, {'ok': True, 'sqlite_version': sqlite3.sqlite_version, 'tiers': ['브라우저', 'Python 서버', 'SQLite DB']})
            return
        route = re.fullmatch(r'/api/students(?:/([0-9]+))?', url.path)
        if not route:
            self.send(404, {'ok': False, 'error': '경로를 찾을 수 없습니다.', 'stage': 'HTTP'})
            return
        sid = int(route[1]) if route[1] else None
        if (self.command == 'POST' and sid is not None) or (self.command in ('PATCH', 'DELETE') and sid is None):
            self.send(405, {'ok': False, 'error': '메서드와 경로가 맞지 않습니다.', 'stage': 'HTTP'})
            return
        try:
            body = None
            if self.command in ('POST', 'PATCH'):
                if self.headers.get('Content-Type', '').split(';')[0] != 'application/json':
                    self.send(415, {'ok': False, 'error': 'application/json이 필요합니다.', 'stage': 'HTTP'})
                    return
                length = int(self.headers.get('Content-Length', '0'))
                if not 0 < length <= 8192:
                    raise InputError('요청 본문은 1~8192바이트여야 합니다.')
                body = json.loads(self.rfile.read(length))
            query = parse_qs(url.query, keep_blank_values=True)
            if set(query) - {'name'} or len(query.get('name', [])) > 1:
                raise InputError('검색에는 name을 한 번만 사용합니다.')
            result = self.server.service.run(self.command, sid, body, query.get('name', [None])[0])
            result.update(ok=True)
            self.send(201 if self.command == 'POST' else 200, result)
        except (InputError, ValueError, UnicodeDecodeError) as error:
            self.send(404 if isinstance(error, NotFound) else 400,
                      {'ok': False, 'error': str(error), 'stage': '애플리케이션'})
        except sqlite3.IntegrityError as error:
            self.send(409, {'ok': False, 'error': str(error), 'stage': '데이터베이스'})
        except sqlite3.OperationalError:
            self.send(503, {'ok': False, 'error': 'DB를 사용할 수 없습니다. 잠시 후 다시 실행하세요.', 'stage': '데이터베이스'})

    do_GET = do_POST = do_PATCH = do_DELETE = dispatch

def make_server(db_path, port=8765):
    repository = Repository(db_path)
    repository.initialize()
    server = ThreadingHTTPServer(('127.0.0.1', port), Handler)
    server.service = Service(repository)
    return server

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--port', type=int, default=8765)
    parser.add_argument('--db', type=Path, default=ROOT / 'data' / 'week3.db')
    args = parser.parse_args()
    server = make_server(args.db, args.port)
    print(f'수업 화면: http://127.0.0.1:{server.server_port}/', flush=True)
    print(f'SQLite {sqlite3.sqlite_version} / DB: {args.db.resolve()}', flush=True)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()
