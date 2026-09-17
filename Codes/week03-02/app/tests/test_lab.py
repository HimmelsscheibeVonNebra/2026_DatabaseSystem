import json
from pathlib import Path
import sqlite3
import sys
import tempfile
import threading
import unittest
from urllib.request import Request, urlopen
from urllib.error import HTTPError
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from server import make_server

class LabTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.path = Path(self.temp.name) / 'test.db'
        self.server = make_server(self.path, 0)
        self.thread = threading.Thread(target=self.server.serve_forever, daemon=True)
        self.thread.start()
        self.url = f'http://127.0.0.1:{self.server.server_port}'

    def tearDown(self):
        self.server.shutdown()
        self.server.server_close()
        self.thread.join()
        self.temp.cleanup()

    def call(self, method, path='/api/students', body=None, headers=None):
        data = json.dumps(body).encode() if body is not None else None
        request = Request(self.url + path, data, {'Content-Type': 'application/json', **(headers or {})}, method=method)
        try:
            response = urlopen(request)
        except HTTPError as error:
            response = error
        with response:
            return response.status, json.load(response)

    def add(self, **changes):
        return self.call('POST', body={'id': 2001, 'name': "O'Brien", 'dept_name': '컴퓨터공학', 'tot_cred': 12, **changes})

    def test_crud_and_binding(self):
        self.assertEqual(len(self.call('GET')[1]['rows']), 5)
        status, result = self.add()
        self.assertEqual(status, 201)
        self.assertNotIn("O'Brien", result['database']['sql'])
        self.assertEqual(result['database']['parameters'][1], "O'Brien")
        self.assertEqual(self.call('GET', '/api/students/2001')[1]['rows'][0]['name'], "O'Brien")
        self.assertEqual(self.call('PATCH', '/api/students/2001', {'tot_cred': 24})[0], 200)
        self.assertEqual(self.call('GET', '/api/students/2001')[1]['rows'][0]['tot_cred'], 24)
        self.assertEqual(self.call('DELETE', '/api/students/2001')[0], 200)
        self.assertEqual(self.call('GET', '/api/students/2001')[0], 404)
        self.assertEqual(self.call('DELETE', '/api/students/2001')[0], 404)

    def test_constraints_and_no_partial_write(self):
        self.assertEqual(self.add(id=1001)[0], 409)
        self.assertEqual(self.add(dept_name='없는학과')[0], 409)
        self.assertEqual(self.call('PATCH', '/api/students/1001', {'tot_cred': 201})[0], 400)
        self.assertEqual(self.call('GET', '/api/students/1001')[1]['rows'][0]['tot_cred'], 42)
        self.assertEqual(len(self.call('GET')[1]['rows']), 5)
        with sqlite3.connect(self.path) as db:
            with self.assertRaises(sqlite3.IntegrityError):
                db.execute('UPDATE student SET tot_cred=201 WHERE id=1001')

    def test_null_and_sql_like_name(self):
        from urllib.parse import quote
        name = "x' OR 1=1 -- <script>"
        self.assertEqual(self.add(name=name, dept_name=None)[0], 201)
        result = self.call('GET', '/api/students?name=' + quote(name))[1]
        self.assertEqual(len(result['rows']), 1)
        self.assertIsNone(result['rows'][0]['dept_name'])
        self.assertEqual(self.add(id=2002, dept_name='NULL')[0], 409)

    def test_input_validation(self):
        for values in [{'id': True}, {'name': ''}, {'tot_cred': 1.5}, {'id': -1}, {'dept_name': 4}]:
            self.assertEqual(self.add(**values)[0], 400)
        self.assertEqual(self.call('PATCH', '/api/students/1001', {'other': 1})[0], 400)
        self.assertEqual(self.call('POST', body=['wrong'])[0], 400)
        self.assertEqual(self.call('GET', '/api/students?name=a&name=b')[0], 400)

    def test_restart_keeps_data(self):
        self.add()
        self.server.service.repository.initialize()
        self.assertEqual(len(self.call('GET')[1]['rows']), 6)
        for row in self.call('GET')[1]['rows']:
            self.call('DELETE', '/api/students/' + str(row['id']))
        self.server.service.repository.initialize()
        self.assertEqual(self.call('GET')[1]['rows'], [])

    def test_http_boundaries(self):
        self.assertEqual(self.call('POST', '/api/students/1001', {})[0], 405)
        self.assertEqual(self.call('DELETE')[0], 405)
        self.assertEqual(self.call('GET', '/api/missing')[0], 404)
        self.assertEqual(self.call('POST', body={}, headers={'Origin': 'http://example.invalid'})[0], 403)
        self.assertEqual(self.call('POST', body={}, headers={'Content-Type': 'text/plain'})[0], 415)
        self.assertEqual(self.call('GET', headers={'Host': 'example.invalid'})[0], 403)
        for path in ['/', '/app.js', '/style.css']:
            with urlopen(self.url + path) as response:
                self.assertEqual(response.status, 200)

if __name__ == '__main__':
    unittest.main()
