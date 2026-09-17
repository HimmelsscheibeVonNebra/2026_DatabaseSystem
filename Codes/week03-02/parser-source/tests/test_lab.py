"""실제 C 프로그램과 고정한 SQLite 엔진을 검증한다."""
import os
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
APP = ROOT / 'build/student_lab'
PROBE = ROOT / 'build/token_probe'

class LabTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='sqlite-week3-test-')
        self.addCleanup(self.temp.cleanup)
        self.db = Path(self.temp.name) / 'test.db'
        self.call('init')

    def call(self, *args, ok=True, trace=False):
        env = os.environ.copy()
        if trace: env['LAB_TRACE'] = '1'
        p = subprocess.run([str(APP), str(self.db), *map(str, args)],
                           text=True, capture_output=True, env=env)
        self.assertEqual(p.returncode == 0, ok, p.stdout + p.stderr)
        return p

    def test_version_and_seed(self):
        out = self.call('version').stdout
        self.assertIn('SQLite 3.53.4', out)
        self.assertIn('bf7c7f30031888f4e796e429ab3978879485813aaca6f641c7b33e4e09459bcc', out)
        self.assertIn('SQLITE_DEBUG=1', out)
        self.assertIn('rows=5', self.call('list').stdout)

    def test_crud_and_apostrophe(self):
        self.assertIn('changes=1', self.call('add', 2001, "O'Brien", '컴퓨터공학', 12).stdout)
        self.assertIn("2001\tO'Brien\t컴퓨터공학\t12", self.call('get', 2001).stdout)
        self.assertIn('rows=1', self.call('search', "O'Brien").stdout)
        self.assertIn('changes=1', self.call('update', 2001, 24).stdout)
        self.assertIn('\t24\n', self.call('get', 2001).stdout)
        self.assertIn('changes=1', self.call('delete', 2001).stdout)
        self.assertIn('rows=0', self.call('get', 2001).stdout)

    def test_injection_is_data(self):
        payload = "x'); DROP TABLE student; --"
        self.call('add', 2002, payload, '-', 0)
        self.assertIn(payload, self.call('search', payload).stdout)
        self.assertIn('rows=6', self.call('list').stdout)

    def test_null_and_constraints(self):
        self.call('add', 2003, '가상학생', '-', 0)
        self.assertIn('\tNULL\t0', self.call('get', 2003).stdout)
        for args, message in [
            (('add',1001,'중복','수학',0),'UNIQUE constraint failed'),
            (('add',2004,'학과오류','없는학과',0),'FOREIGN KEY constraint failed'),
            (('update',1001,201),'CHECK constraint failed')]:
            p=self.call(*args,ok=False,trace=True)
            self.assertIn(message,p.stderr)
            self.assertIn('ERROR step rc=19',p.stderr)
        self.assertIn('\t42\n', self.call('get',1001).stdout)

    def test_no_match_and_invalid_input(self):
        self.assertIn('changes=0',self.call('update',9999,24).stdout)
        self.assertIn('changes=0',self.call('delete',9999).stdout)
        self.call('update','1001x',30,ok=False)
        self.call('update',1001,'99999999999999',ok=False)
        self.call('add',2001,'bad\tname','수학',10,ok=False)
        self.assertIn('\t42\n',self.call('get',1001).stdout)

    def test_init_preserves_existing_data(self):
        self.call('update',1001,60)
        self.assertIn('보존',self.call('init').stdout)
        self.assertIn('\t60\n',self.call('get',1001).stdout)

    def test_missing_database_not_created(self):
        self.db=Path(self.temp.name)/'missing.db'
        self.call('list',ok=False)
        self.assertFalse(self.db.exists())

    def test_binding_reset_and_clear(self):
        self.assertEqual(self.call('binding-demo').stdout,
                         'phase=1\n한글\t42\nphase=2\n한글\t42\nphase=3\n새 값\tNULL\n')

    def test_api_lifecycle(self):
        log=self.call('get',1001,trace=True).stderr
        names=['sqlite3_open_v2','sqlite3_prepare_v2','sqlite3_bind_int',
               'sqlite3_step','sqlite3_finalize','sqlite3_close']
        self.assertEqual([log.index(x) for x in names],sorted(log.index(x) for x in names))
        self.assertIn('rc=100',log)
        self.assertIn('rc=101',log)

    def test_parser_success_and_errors(self):
        before=self.call('list').stdout
        p=self.call('parser','ok')
        self.assertIn("Shift 'SELECT'",p.stdout)
        self.assertIn('expr ::= VARIABLE',p.stdout)
        self.assertIn('PREPARE rc=0 parameters=1',p.stdout)
        p=self.call('parser','syntax',ok=False)
        self.assertIn('syntax error',p.stderr)
        self.assertIn('PREPARE rc=1',p.stdout)
        p=self.call('parser','name',ok=False)
        self.assertIn('no such column: missing_column',p.stderr)
        self.assertEqual(before,self.call('list').stdout)

    def test_real_tokenizer(self):
        p=subprocess.run([str(PROBE)],text=True,capture_output=True,check=True)
        self.assertIn('36\t2\tTK_VARIABLE\t?1',p.stdout)
        p=subprocess.run([str(PROBE),"SELECT '한글';"],text=True,capture_output=True,check=True)
        self.assertIn("7\t8\tTK_STRING\t'한글'",p.stdout)

if __name__=='__main__': unittest.main(verbosity=2)
