import './style.css';
import maplibregl from 'maplibre-gl';

const API_BASE = 'http://82.202.159.64:8000/v1';
const CITY_SLUG = 'kaliningrad_city';

let map;

async function init() {
    // 1. Initialize Map
    map = new maplibregl.Map({
        container: 'map',
        style: 'https://basemaps.cartocdn.com/gl/dark-matter-gl-style/style.json',
        center: [20.5122, 54.7104], // Kaliningrad
        zoom: 13,
        attributionControl: false
    });

    // 2. Fetch Data
    try {
        const response = await fetch(`${API_BASE}/public/catalog?city=${CITY_SLUG}`);
        const tours = await response.json();
        renderTours(tours);
    } catch (err) {
        console.error('Failed to fetch tours:', err);
        document.getElementById('tour-list').innerHTML = '<div class="error">Ошибка загрузки туров</div>';
    }

    // 3. UI Interactions
    setupDrawer();
    setupLocation();
}

function renderTours(tours) {
    const list = document.getElementById('tour-list');
    if (!tours || tours.length === 0) {
        list.innerHTML = '<div class="loading-state">Нет доступных туров</div>';
        return;
    }

    list.innerHTML = tours.map(tour => `
    <div class="tour-card" style="background-image: url('${tour.cover_image_url || 'https://images.unsplash.com/photo-1590076215667-8cdfab516c90?auto=format&fit=crop&q=80&w=600'}')">
      <div class="tour-card-info">
        <h3 class="tour-title">${tour.title_ru}</h3>
        <div class="tour-meta">
          <span>⏱ ${tour.duration_minutes || 0} мин</span>
          <span>📍 ${tour.pois_count || 0} точек</span>
        </div>
      </div>
    </div>
  `).join('');
}

function setupDrawer() {
    const drawer = document.getElementById('drawer');
    let isExpanded = false;

    drawer.addEventListener('click', () => {
        isExpanded = !isExpanded;
        drawer.classList.toggle('expanded', isExpanded);
    });

    // Swipe logic could be added here for touch devices
}

function setupLocation() {
    const btn = document.getElementById('locate-btn');
    btn.addEventListener('click', () => {
        if ("geolocation" in navigator) {
            navigator.geolocation.getCurrentPosition((pos) => {
                map.flyTo({
                    center: [pos.coords.longitude, pos.coords.latitude],
                    zoom: 15
                });
            });
        }
    });
}

document.addEventListener('DOMContentLoaded', init);
