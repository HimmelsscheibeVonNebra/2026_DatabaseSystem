// 샘플 5-2: Leaflet 지도 — setView는 [위도, 경도], GeoJSON 좌표는 [경도, 위도]
const map = L.map('map').setView([37.5665, 126.9780], 7);
L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  { attribution: '&copy; OpenStreetMap contributors' }).addTo(map);

fetch('points.geojson').then(r => r.json()).then(data => {
  const layer = L.geoJSON(data, {
    onEachFeature: (f, l) => l.bindPopup(f.properties.name)
  }).addTo(map);
  map.fitBounds(layer.getBounds());           // 점이 다 보이게 범위 맞춤
});
