"""공식 SQLite 3.53.4 검증 및 수업용 디버그 빌드. 외부 Python 패키지 없음."""
from pathlib import Path
import hashlib
import platform
import shutil
import subprocess
import urllib.request
import zipfile

ROOT=Path(__file__).resolve().parent
VERSION='3.53.4'
SOURCE_ID='2026-07-24 19:02:57 bf7c7f30031888f4e796e429ab3978879485813aaca6f641c7b33e4e09459bcc'
ARCHIVES={
 'sqlite-amalgamation-3530400.zip':'628a44cfe82c66aed1ccbbe85a562d2e33ebe64b3288981ed76285612227934e',
 'sqlite-src-3530400.zip':'b834d474b9b393d85a9e3ee4cc11f1329e007e9376a424ee740796f5c4bda3a8',
}
def main():
    if platform.system() not in {'Darwin','Linux'}:
        raise SystemExit('macOS 또는 Linux/WSL에서 실행하세요.')
    compiler=shutil.which('cc')
    if not compiler: raise SystemExit('C 컴파일러 cc가 필요합니다. README.md를 참고하세요.')
    for name,expected in ARCHIVES.items():
        archive=ROOT/'vendor/archives'/name
        archive.parent.mkdir(parents=True,exist_ok=True)
        if not archive.exists():
            print('공식 소스 다운로드:',name,flush=True)
            with urllib.request.urlopen('https://www.sqlite.org/2026/'+name,timeout=90) as response:
                raw=response.read()
            if hashlib.sha3_256(raw).hexdigest()!=expected: raise RuntimeError('체크섬 불일치')
            archive.write_bytes(raw)
        if hashlib.sha3_256(archive.read_bytes()).hexdigest()!=expected:
            raise RuntimeError('체크섬 불일치: '+name)
        with zipfile.ZipFile(archive) as source:
            for member in source.infolist():
                rel=Path(member.filename)
                if rel.is_absolute() or '..' in rel.parts: raise RuntimeError('잘못된 압축 경로')
                if name.startswith('sqlite-src'):
                    keep=len(rel.parts)>1 and (rel.parts[1]=='src' or rel.parts[1] in {'VERSION','manifest.uuid','LICENSE.md','README.md'} or member.filename.endswith(('/tool/lemon.c','/tool/lempar.c')))
                    if not keep: continue
                if not member.is_dir():
                    destination=ROOT/'vendor'/rel
                    destination.parent.mkdir(parents=True,exist_ok=True)
                    destination.write_bytes(source.read(member))
    amalg=ROOT/'vendor/sqlite-amalgamation-3530400'
    build=ROOT/'build'
    build.mkdir(exist_ok=True)
    flags=['-O0','-g','-DSQLITE_DEBUG','-DSQLITE_THREADSAFE=1','-DSQLITE_OMIT_LOAD_EXTENSION=1','-I'+str(amalg)]
    links=['-lm','-lpthread']
    print('SQLite 3.53.4 및 실습 프로그램 빌드 중...',flush=True)
    subprocess.run([compiler,*flags,str(ROOT/'student_lab.c'),str(amalg/'sqlite3.c'),*links,'-o',str(build/'student_lab')],check=True)
    subprocess.run([compiler,*flags,str(ROOT/'token_probe.c'),*links,'-o',str(build/'token_probe')],check=True)
    data=ROOT/'data'
    data.mkdir(exist_ok=True)
    database=data/'week3.db'
    if not database.exists():
        subprocess.run([str(build/'student_lab'),str(database),'init'],check=True)
    else: print('기존 실습 DB를 보존했습니다.')
    result=subprocess.run([str(build/'student_lab'),str(database),'version'],check=True,capture_output=True,text=True)
    if 'SQLite '+VERSION not in result.stdout or SOURCE_ID not in result.stdout or 'SQLITE_DEBUG=1' not in result.stdout:
        raise RuntimeError('실행 버전/source ID/디버그 옵션 불일치')
    print(result.stdout,end='')
    print('준비 완료: ./build/student_lab data/week3.db list')

if __name__=='__main__': main()
