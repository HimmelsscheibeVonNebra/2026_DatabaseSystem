# 샘플 5-1: PostGIS → GeoJSON 파일 (points.geojson)
import json, psycopg

Q = """SELECT name, ST_AsGeoJSON(geom)
       FROM   public.points
       WHERE  name IS NOT NULL
       LIMIT  200"""

with psycopg.connect() as conn:                 # 접속 정보는 PG* 환경 변수
    features = [{"type": "Feature", "geometry": json.loads(g),
                 "properties": {"name": n}} for n, g in conn.execute(Q)]

fc = {"type": "FeatureCollection", "features": features}
json.dump(fc, open("points.geojson", "w", encoding="utf-8"), ensure_ascii=False)
print(len(features), "features → points.geojson")
