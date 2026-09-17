const $ = (id) => document.getElementById(id);
const pretty = (value) => JSON.stringify(value, null, 2);
let busy = false;
function status(message, error = false) {
  $('status').textContent = message;
  $('status').classList.toggle('error', error);
}
async function request(method, path, body, show = true) {
  const options = {method, headers: {}};
  if (body !== undefined) {
    options.headers['Content-Type'] = 'application/json';
    options.body = JSON.stringify(body);
  }
  if (show) {
    $('request').textContent = `${method} ${path}\n${body === undefined ? '(본문 없음)' : pretty(body)}`;
    $('response').textContent = '응답 대기 중…';
    $('database').textContent = '—';
  }
  const response = await fetch(path, options);
  const data = await response.json();
  if (show) {
    $('response').textContent = `HTTP ${response.status}\n${pretty(data)}`;
    $('database').textContent = data.database
      ? `SQL\n${data.database.sql}\n\n매개변수\n${pretty(data.database.parameters)}`
      : `실패 단계: ${data.stage ?? 'HTTP'}\n${data.error ?? '오류'}`;
  }
  if (!response.ok) throw new Error(`HTTP ${response.status} · ${data.error}`);
  return data;
}
function render(rows) {
  $('students').replaceChildren();
  $('count').textContent = `${rows.length}명`;
  for (const row of rows) {
    const tr = document.createElement('tr');
    for (const key of ['id', 'name', 'dept_name', 'tot_cred']) {
      const td = document.createElement('td');
      if (key === 'id') {
        const button = document.createElement('button');
        button.className = 'secondary';
        button.textContent = row.id;
        button.setAttribute('aria-label', `${row.id} 학생 선택`);
        button.onclick = () => { $('target-id').value = row.id; status(`${row.id} 학생을 선택했습니다.`); };
        td.append(button);
      } else td.textContent = row[key] === null ? '미정 (NULL)' : row[key];
      tr.append(td);
    }
    $('students').append(tr);
  }
}
async function list(show = true, name) {
  const data = await request('GET', '/api/students' + (name === undefined ? '' : '?name=' + encodeURIComponent(name)), undefined, show);
  render(data.rows);
  return data;
}
async function action(work) {
  if (busy) return;
  busy = true;
  try { await work(); } catch (error) { status(error.message, true); }
  finally { busy = false; }
}
$('add-form').onsubmit = (event) => {
  event.preventDefault();
  action(async () => {
    const form = new FormData(event.target);
    await request('POST', '/api/students', {id: Number(form.get('id')), name: form.get('name'), dept_name: form.get('dept_name') || null, tot_cred: Number(form.get('tot_cred'))});
    await list(false);
    status('등록 완료 · changes=1');
  });
};
$('edit-form').onsubmit = (event) => {
  event.preventDefault();
  action(async () => {
    const form = new FormData(event.target);
    await request('PATCH', '/api/students/' + Number(form.get('id')), {tot_cred: Number(form.get('tot_cred'))});
    await list(false);
    status('수정 완료 · changes=1');
  });
};
$('delete').onclick = () => {
  const id = Number($('target-id').value);
  if (!Number.isInteger(id) || id < 1) { status('대상 학번을 확인하세요.', true); return; }
  if (!confirm(`${id} 학생을 삭제할까요?`)) return;
  action(async () => {
    await request('DELETE', '/api/students/' + id);
    await list(false);
    status('삭제 완료 · changes=1');
  });
};
$('refresh').onclick = () => action(async () => { await list(); status('전체 목록을 조회했습니다.'); });
$('search-form').onsubmit = (event) => {
  event.preventDefault();
  action(async () => { await list(true, $('search-name').value); status('이름이 정확히 일치하는 학생을 조회했습니다.'); });
};
action(async () => {
  const info = await request('GET', '/api/info', undefined, false);
  $('version').textContent = `실행 버전: SQLite ${info.sqlite_version}`;
  await list();
  status('준비 완료 · 실습을 시작하세요.');
});
