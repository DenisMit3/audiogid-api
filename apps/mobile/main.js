import "./style.css";
import maplibregl from "maplibre-gl";

const API_BASE = import.meta.env.VITE_API_BASE || "http://82.202.159.64:8000/v1";
const CITY_SLUG = import.meta.env.VITE_CITY_SLUG || "kaliningrad_city";
const DEFAULT_IMAGE = "https://images.unsplash.com/photo-1464207687429-7505649dae38?auto=format&fit=crop&q=80&w=600";

let map;
let markers = [];
let allTours = [];
let filteredTours = [];
let userLocation = null;

// ===== INITIALIZATION =====
async function init() {
  console.log("AudioGuide App Initializing...");

  // Initialize Map
  initMap();

  // Setup UI
  setupUIInteractions();
  setupSearchFunctionality();

  // Fetch Tours
  await loadTours();
}

// ===== MAP INITIALIZATION =====
function initMap() {
  map = new maplibregl.Map({
    container: "map",
    style: "https://basemaps.cartocdn.com/gl/dark-matter-gl-style/style.json",
    center: [20.5122, 54.7104], // Kaliningrad
    zoom: 13,
    attributionControl: false,
  });

  // Add custom map controls
  map.on("load", () => {
    console.log("Map loaded successfully");
  });
}

// ===== MAP MARKERS =====
function addTourMarkers(tours) {
  // Remove existing markers
  markers.forEach(marker => marker.remove());
  markers = [];

  tours.forEach(tour => {
    if (tour.start_lat && tour.start_lng) {
      const marker = new maplibregl.Marker({ color: '#10b981' })
        .setLngLat([tour.start_lng, tour.start_lat])
        .setPopup(
          new maplibregl.Popup({ offset: 25 }).setHTML(`
            <div style="padding: 8px; max-width: 200px;">
              <strong style="font-size: 14px;">${escapeHtml(tour.title_ru || 'Без названия')}</strong>
              <p style="margin: 4px 0 0; font-size: 12px; color: #666;">
                ⏱️ ${tour.duration_minutes || 0} мин
              </p>
            </div>
          `)
        )
        .addTo(map);
      
      // Click on marker opens tour detail
      marker.getElement().addEventListener('click', () => {
        showTourDetail(tour.id);
      });
      
      markers.push(marker);
    }
  });
}

// ===== FETCH TOURS =====
async function loadTours() {
  try {
    console.log("Loading tours from API...");
    const response = await fetch(`${API_BASE}/public/catalog?city=${CITY_SLUG}`);

    if (!response.ok) {
      throw new Error(`API error: ${response.status}`);
    }

    const tours = await response.json();
    console.log(`Loaded ${tours.length} tours`);

    allTours = Array.isArray(tours) ? tours : [];
    filteredTours = [...allTours];

    renderTours();
    hideLoadingState();
    hideErrorState();
  } catch (error) {
    console.error("Failed to load tours:", error);
    showErrorState();
    hideLoadingState();
  }
}

// ===== RENDER TOURS =====
function renderTours() {
  if (filteredTours.length === 0) {
    showEmptyState();
    return;
  }

  hideEmptyState();

  // Featured (Popular) Tours - sorted by rating
  const featured = [...filteredTours]
    .sort((a, b) => (b.rating || 0) - (a.rating || 0))
    .slice(0, 5);
  renderFeaturedTours(featured);

  // Nearby Tours - sorted by distance if location available
  const nearby = userLocation 
    ? sortByDistance(filteredTours, userLocation.lat, userLocation.lng).slice(0, 3)
    : filteredTours.slice(0, 3);
  renderNearbyTours(nearby);

  // All Tours
  renderAllTours(filteredTours);

  // Add markers to map
  addTourMarkers(filteredTours);
}

function renderFeaturedTours(tours) {
  const container = document.getElementById("featured-tours");
  if (!container) return;

  container.innerHTML = tours
    .map(
      (tour) => `
    <div class="tour-card" data-tour-id="${tour.id}">
      <div
        style="
          background-image: url('${
            tour.cover_image_url ||
            "https://images.unsplash.com/photo-1464207687429-7505649dae38?auto=format&fit=crop&q=80&w=600"
          }');
          width: 100%;
          height: 100%;
          background-size: cover;
          background-position: center;
        "
      ></div>
      <div class="tour-card-info">
        <h3 class="tour-title">${escapeHtml(tour.title_ru || "Untitled")}</h3>
        <div class="tour-meta">
          <span>⏱️ ${tour.duration_minutes || 0} мин</span>
          ${
            tour.rating
              ? `<span class="tour-rating">⭐ ${tour.rating.toFixed(1)}</span>`
              : ""
          }
        </div>
      </div>
    </div>
  `
    )
    .join("");
}

function renderNearbyTours(tours) {
  const container = document.getElementById("nearby-tours");
  if (!container) return;

  container.innerHTML = tours
    .map(
      (tour) => `
    <div class="tour-list-item" data-tour-id="${tour.id}">
      <div
        class="tour-list-thumb"
        style="background-image: url('${
          tour.cover_image_url ||
          "https://images.unsplash.com/photo-1464207687429-7505649dae38?auto=format&fit=crop&q=80&w=200"
        }')"
      ></div>
      <div class="tour-list-info">
        <h3 class="tour-list-title">${escapeHtml(tour.title_ru || "Untitled")}</h3>
        <p class="tour-list-description">
          ${
            tour.description_ru
              ? escapeHtml(tour.description_ru.substring(0, 80) + "...")
              : "Увлекательная экскурсия по городу"
          }
        </p>
        <div class="tour-list-footer">
          <span class="tour-duration">⏱️ ${tour.duration_minutes || 0} мин</span>
          <span class="tour-price">${tour.price || "Бесплатно"}</span>
        </div>
      </div>
    </div>
  `
    )
    .join("");
}

function renderAllTours(tours) {
  const container = document.getElementById("all-tours");
  if (!container) return;

  container.innerHTML = tours
    .map(
      (tour) => `
    <div class="tour-list-item" data-tour-id="${tour.id}">
      <div
        class="tour-list-thumb"
        style="background-image: url('${
          tour.cover_image_url ||
          "https://images.unsplash.com/photo-1464207687429-7505649dae38?auto=format&fit=crop&q=80&w=200"
        }')"
      ></div>
      <div class="tour-list-info">
        <h3 class="tour-list-title">${escapeHtml(tour.title_ru || "Untitled")}</h3>
        <p class="tour-list-description">
          ${
            tour.description_ru
              ? escapeHtml(tour.description_ru.substring(0, 80) + "...")
              : "Увлекательная экскурсия по городу"
          }
        </p>
        <div class="tour-list-footer">
          <span class="tour-duration">⏱️ ${tour.duration_minutes || 0} мин · ${tour.pois_count || 0} точек</span>
          <span class="tour-price">${tour.price || "Бесплатно"}</span>
        </div>
      </div>
    </div>
  `
    )
    .join("");
}

// ===== TOUR DETAIL MODAL =====
function showTourDetail(tourId) {
  const tour = allTours.find((t) => t.id == tourId);

  if (!tour) return;

  const detailContent = `
    <div class="tour-detail">
      <div class="tour-detail-header">
        <img
          src="${
            tour.cover_image_url ||
            "https://images.unsplash.com/photo-1464207687429-7505649dae38?auto=format&fit=crop&q=80&w=600"
          }"
          alt="${escapeHtml(tour.title_ru)}"
          class="tour-detail-image"
        />
      </div>

      <div style="padding: 0 4px;">
        <h2 class="tour-detail-title">${escapeHtml(tour.title_ru || "Untitled")}</h2>

        <div class="tour-detail-section" style="margin-top: 20px;">
          <h3 style="font-size: 16px; font-weight: 700; margin: 0;">Об этой экскурсии</h3>
          <p style="color: var(--text-secondary); font-size: 14px; line-height: 1.6; margin: 8px 0 0 0;">
            ${escapeHtml(tour.description_ru || "Интересная экскурсия с профессиональным гидом.")}
          </p>
        </div>

        <div class="tour-detail-section" style="margin-top: 20px;">
          <h3 style="font-size: 16px; font-weight: 700; margin: 0;">Информация</h3>
          <div class="detail-stat">
            <span>⏱️</span>
            <span>
              <span class="detail-stat-label">Длительность</span>
              <div class="detail-stat-value">${tour.duration_minutes || 0} минут</div>
            </span>
          </div>
          <div class="detail-stat">
            <span>📍</span>
            <span>
              <span class="detail-stat-label">Точки интереса</span>
              <div class="detail-stat-value">${tour.pois_count || 0} точек</div>
            </span>
          </div>
          ${
            tour.rating
              ? `
          <div class="detail-stat">
            <span>⭐</span>
            <span>
              <span class="detail-stat-label">Рейтинг</span>
              <div class="detail-stat-value">${tour.rating.toFixed(1)} / 5</div>
            </span>
          </div>
          `
              : ""
          }
          <div class="detail-stat">
            <span>💰</span>
            <span>
              <span class="detail-stat-label">Стоимость</span>
              <div class="detail-stat-value">${tour.price || "Бесплатно"}</div>
            </span>
          </div>
        </div>

        <button class="cta-button" data-start-tour="${escapeHtml(String(tour.id))}" style="margin-top: 24px;">Начать экскурсию</button>
      </div>
    </div>
  `;

  document.getElementById("tour-detail-inner").innerHTML = detailContent;
  document.getElementById("tour-detail-modal").classList.remove("hidden");
}

function closeTourDetail() {
  document.getElementById("tour-detail-modal").classList.add("hidden");
}

// ===== SEARCH AND FILTER =====
function setupSearchFunctionality() {
  const searchInput = document.getElementById("search-input");
  if (searchInput) {
    const debouncedFilter = debounce((query) => filterTours(query), 300);
    searchInput.addEventListener("input", (e) => {
      const query = e.target.value.toLowerCase().trim();
      debouncedFilter(query);
    });
  }

  document.getElementById("retry-btn")?.addEventListener("click", loadTours);
}

function filterTours(query) {
  if (!query) {
    filteredTours = [...allTours];
  } else {
    filteredTours = allTours.filter(
      (tour) =>
        (tour.title_ru || "").toLowerCase().includes(query) ||
        (tour.description_ru || "").toLowerCase().includes(query)
    );
  }
  renderTours();
}

// ===== UI INTERACTIONS =====
function setupUIInteractions() {
  // Drawer Toggle
  const drawer = document.getElementById("drawer");
  const drawerHandle = drawer.querySelector(".drawer-handle");

  drawer.addEventListener("click", (e) => {
    if (e.target === drawerHandle || e.target.parentElement === drawerHandle) {
      drawer.classList.toggle("expanded");
    }
  });

  // Event Delegation for Tour Cards (fixes onclick in dynamic HTML)
  document.addEventListener("click", (e) => {
    // Handle tour card clicks
    const tourCard = e.target.closest("[data-tour-id]");
    if (tourCard && !e.target.closest(".cta-button")) {
      const tourId = tourCard.getAttribute("data-tour-id");
      showTourDetail(tourId);
      return;
    }

    // Handle "Start Tour" button
    const startBtn = e.target.closest("[data-start-tour]");
    if (startBtn) {
      const tourId = startBtn.getAttribute("data-start-tour");
      startTour(tourId);
      return;
    }
  });

  // Swipe Support for Drawer
  let touchStartY = 0;
  drawer.addEventListener("touchstart", (e) => {
    touchStartY = e.touches[0].clientY;
  });

  drawer.addEventListener("touchmove", (e) => {
    if (!drawer.classList.contains("expanded")) return;

    const currentY = e.touches[0].clientY;
    const diff = touchStartY - currentY;

    if (diff > 50 && drawer.scrollTop === 0) {
      // Swiped up and at top
      return;
    }
  });

  // Geolocation Button
  document.getElementById("locate-btn").addEventListener("click", () => {
    const btn = document.getElementById("locate-btn");
    
    if ("geolocation" in navigator) {
      btn.disabled = true;
      btn.classList.add("loading");
      
      navigator.geolocation.getCurrentPosition(
        (pos) => {
          btn.disabled = false;
          btn.classList.remove("loading");
          
          userLocation = {
            lat: pos.coords.latitude,
            lng: pos.coords.longitude,
          };
          map.flyTo({
            center: [userLocation.lng, userLocation.lat],
            zoom: 15,
          });
          // Re-render tours with distance sorting
          renderTours();
          // Show notification
          showNotification("Местоположение определено");
        },
        (error) => {
          btn.disabled = false;
          btn.classList.remove("loading");
          console.error("Geolocation error:", error);
          showNotification("Не удалось определить местоположение", "error");
        },
        { timeout: 10000, enableHighAccuracy: true }
      );
    } else {
      showNotification("Геолокация не поддерживается", "error");
    }
  });

  // Filter Button
  document.getElementById("filter-btn").addEventListener("click", () => {
    showNotification("Фильтры скоро будут доступны");
  });

  // Menu Button
  document.getElementById("menu-btn").addEventListener("click", () => {
    showNotification("Меню");
  });

  // Modal Close
  document.getElementById("close-modal").addEventListener("click", closeTourDetail);
  document.querySelector(".modal-backdrop")?.addEventListener("click", closeTourDetail);
  
  // Close modal on Escape key
  document.addEventListener("keydown", (e) => {
    if (e.key === "Escape") {
      closeTourDetail();
    }
  });
}

// ===== STATE MANAGEMENT =====
function showLoadingState() {
  // Skeletons are already shown by default
}

function hideLoadingState() {
  // Skeletons will be replaced with content
}

function showEmptyState() {
  document.getElementById("featured-tours").innerHTML = "";
  document.getElementById("nearby-tours").innerHTML = "";
  document.getElementById("all-tours").innerHTML = "";
  document.getElementById("empty-state").classList.remove("hidden");
}

function hideEmptyState() {
  document.getElementById("empty-state").classList.add("hidden");
}

function showErrorState() {
  document.getElementById("error-state").classList.remove("hidden");
}

function hideErrorState() {
  document.getElementById("error-state").classList.add("hidden");
}

// ===== START TOUR =====
function startTour(tourId) {
  const tour = allTours.find((t) => t.id == tourId);
  if (!tour) return;

  console.log("Starting tour:", tourId, tour.title_ru);
  closeTourDetail();
  
  // Center map on tour start point if available
  if (tour.start_lat && tour.start_lng) {
    map.flyTo({
      center: [tour.start_lng, tour.start_lat],
      zoom: 16,
    });
  }
  
  showNotification(`Экскурсия "${tour.title_ru}" запущена!`);
  
  // TODO: Navigate to tour player screen
}

// ===== UTILITIES =====
function escapeHtml(text) {
  if (text == null) return '';
  const map = {
    "&": "&amp;",
    "<": "&lt;",
    ">": "&gt;",
    '"': "&quot;",
    "'": "&#039;",
  };
  return String(text).replace(/[&<>"']/g, (m) => map[m]);
}

function debounce(fn, delay) {
  let timeout;
  return (...args) => {
    clearTimeout(timeout);
    timeout = setTimeout(() => fn(...args), delay);
  };
}

function getDistance(lat1, lng1, lat2, lng2) {
  if (!lat2 || !lng2) return Infinity;
  const R = 6371; // km
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLng = (lng2 - lng1) * Math.PI / 180;
  const a = Math.sin(dLat/2) ** 2 + 
            Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) * 
            Math.sin(dLng/2) ** 2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
}

function sortByDistance(tours, userLat, userLng) {
  if (!userLat || !userLng) return tours;
  return [...tours].sort((a, b) => {
    const distA = getDistance(userLat, userLng, a.start_lat, a.start_lng);
    const distB = getDistance(userLat, userLng, b.start_lat, b.start_lng);
    return distA - distB;
  });
}

function showNotification(message, type = "success") {
  const notification = document.createElement("div");
  notification.textContent = message;
  notification.style.cssText = `
    position: fixed;
    top: calc(20px + var(--safe-top));
    left: 50%;
    transform: translateX(-50%);
    background: ${type === "error" ? "var(--error-color)" : "var(--accent-primary)"};
    color: white;
    padding: 12px 20px;
    border-radius: 12px;
    font-size: 14px;
    font-weight: 600;
    z-index: 999;
    animation: slideDown 0.3s ease;
  `;
  document.body.appendChild(notification);

  setTimeout(() => {
    notification.style.animation = "slideUp 0.3s ease";
    setTimeout(() => notification.remove(), 300);
  }, 2000);
}

// Initialize on DOM Ready
document.addEventListener("DOMContentLoaded", init);

// Add animations (with duplicate check)
if (!document.getElementById('notification-animations')) {
  const style = document.createElement("style");
  style.id = 'notification-animations';
  style.textContent = `
    @keyframes slideDown {
      from {
        transform: translateX(-50%) translateY(-20px);
        opacity: 0;
      }
      to {
        transform: translateX(-50%) translateY(0);
        opacity: 1;
      }
    }

    @keyframes slideUp {
      from {
        transform: translateX(-50%) translateY(0);
        opacity: 1;
      }
      to {
        transform: translateX(-50%) translateY(-20px);
        opacity: 0;
      }
    }
  `;
  document.head.appendChild(style);
}
