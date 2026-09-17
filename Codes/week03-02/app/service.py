"""애플리케이션 계층: 입력 검증과 CRUD 처리 규칙."""
class InputError(ValueError):
    pass

class NotFound(ValueError):
    pass

def integer(value, label, minimum, maximum):
    if type(value) is not int or not minimum <= value <= maximum:
        raise InputError(f'{label}: {minimum}~{maximum} 범위의 정수가 필요합니다.')
    return value

def text(value, label, limit=80):
    if not isinstance(value, str) or not value.strip() or len(value) > limit or '\x00' in value:
        raise InputError(f'{label}: 1~{limit}자의 문자열이 필요합니다.')
    return value

class Service:
    def __init__(self, repository):
        self.repository = repository

    def run(self, method, student_id=None, body=None, name=None):
        if student_id is not None:
            integer(student_id, '학번', 1, 2147483647)
        if method == 'GET':
            if student_id is None:
                return self.repository.list(text(name, '검색 이름') if name is not None else None)
            result = self.repository.get(student_id)
            if not result['rows']:
                raise NotFound('해당 학생이 없습니다.')
            return result
        if method in ('POST', 'PATCH'):
            if not isinstance(body, dict):
                raise InputError('JSON 객체가 필요합니다.')
            required = {'id', 'name', 'dept_name', 'tot_cred'} if method == 'POST' else {'tot_cred'}
            if set(body) != required:
                raise InputError('요청 필드가 맞지 않습니다: ' + ', '.join(sorted(required)))
            credits = integer(body['tot_cred'], '이수 학점', 0, 200)
            if method == 'POST':
                sid = integer(body['id'], '학번', 1, 2147483647)
                name = text(body['name'], '이름')
                dept = body['dept_name']
                if dept is not None:
                    dept = text(dept, '학과')
                return self.repository.add((sid, name, dept, credits))
            result = self.repository.update(student_id, credits)
        elif method == 'DELETE':
            result = self.repository.delete(student_id)
        else:
            raise InputError('지원하지 않는 요청입니다.')
        if not result['changes']:
            raise NotFound('해당 학생이 없습니다.')
        return result
