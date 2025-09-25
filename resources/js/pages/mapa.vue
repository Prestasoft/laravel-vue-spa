<template>
  <div class="mapa-container">
    <!-- Header con estadísticas -->
    <div class="map-header mb-3">
      <div class="row align-items-center">
        <div class="col-md-6">
          <h3 class="mb-0">
            <i class="bi bi-map-fill me-2"></i>
            Mapa de Votantes
          </h3>
        </div>
        <div class="col-md-6 text-end">
          <div class="d-inline-flex align-items-center gap-3">
            <span class="badge bg-primary fs-6">
              <i class="bi bi-geo-alt-fill me-1"></i>
              {{ votantesConGps }} con ubicación
            </span>
            <span class="badge bg-secondary fs-6">
              <i class="bi bi-people-fill me-1"></i>
              {{ totalVotantes }} total
            </span>
          </div>
        </div>
      </div>
    </div>

    <!-- Controles del mapa -->
    <div class="map-controls mb-3">
      <div class="card shadow-sm">
        <div class="card-body">
          <div class="row g-3">
            <!-- Filtro por coordinador -->
            <div v-if="isCandidato || isAdmin" class="col-md-4">
              <label class="form-label small text-muted">Filtrar por Coordinador</label>
              <select v-model="filtroCoordinador" @change="cargarVotantesGps" class="form-select">
                <option value="">Todos los coordinadores</option>
                <option v-for="coord in coordinadores" :key="coord.id" :value="coord.id">
                  {{ coord.name }} ({{ coord.votantes_count || 0 }} votantes)
                </option>
              </select>
            </div>

            <!-- Filtro por colegio -->
            <div class="col-md-4">
              <label class="form-label small text-muted">Filtrar por Colegio</label>
              <select v-model="filtroColegio" @change="cargarVotantesGps" class="form-select">
                <option value="">Todos los colegios</option>
                <option v-for="colegio in colegios" :key="colegio.id" :value="colegio.id">
                  {{ colegio.nombre }}
                </option>
              </select>
            </div>

            <!-- Búsqueda -->
            <div class="col-md-4">
              <label class="form-label small text-muted">Buscar votante</label>
              <div class="input-group">
                <span class="input-group-text"><i class="bi bi-search"></i></span>
                <input
                  v-model="busqueda"
                  type="text"
                  class="form-control"
                  placeholder="Nombre o cédula..."
                  @input="filtrarMarcadores"
                >
              </div>
            </div>
          </div>

          <div class="row mt-3">
            <div class="col-12">
              <div class="btn-group" role="group">
                <button @click="centrarMapa" class="btn btn-outline-primary btn-sm">
                  <i class="bi bi-geo-alt me-1"></i> Centrar Mapa
                </button>
                <button @click="toggleClusters" class="btn btn-outline-secondary btn-sm">
                  <i class="bi bi-diagram-3 me-1"></i>
                  {{ mostrarClusters ? 'Ocultar' : 'Mostrar' }} Agrupación
                </button>
                <button @click="exportarKML" class="btn btn-outline-success btn-sm">
                  <i class="bi bi-download me-1"></i> Exportar KML
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Mapa -->
    <div class="card shadow-sm">
      <div class="card-body p-0">
        <div id="mapa-votantes" class="map-container"></div>
      </div>
    </div>

    <!-- Leyenda -->
    <div class="map-legend">
      <h6>Leyenda</h6>
      <div class="legend-item">
        <span class="legend-color" style="background: #28a745;"></span>
        <span>Mis votantes</span>
      </div>
      <div v-if="isCandidato" class="legend-item">
        <span class="legend-color" style="background: #007bff;"></span>
        <span>Votantes de coordinadores</span>
      </div>
      <div class="legend-item">
        <span class="legend-color" style="background: #ffc107;"></span>
        <span>Sin teléfono</span>
      </div>
    </div>

    <!-- Modal de detalles del votante -->
    <div v-if="votanteSeleccionado" class="modal fade show" style="display: block;" tabindex="-1">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header bg-primary text-white">
            <h5 class="modal-title">
              <i class="bi bi-person-badge-fill me-2"></i>
              Información del Votante
            </h5>
            <button type="button" class="btn-close btn-close-white" @click="cerrarDetalle"></button>
          </div>
          <div class="modal-body">
            <div class="row">
              <!-- Foto y datos básicos -->
              <div class="col-md-4 text-center">
                <img
                  v-if="votanteSeleccionado.foto_base64"
                  :src="'data:image/jpeg;base64,' + votanteSeleccionado.foto_base64"
                  class="img-fluid rounded-circle shadow mb-3"
                  style="max-width: 150px;"
                >
                <div v-else class="photo-placeholder rounded-circle mx-auto mb-3">
                  <i class="bi bi-person-circle"></i>
                </div>
                <h5>{{ votanteSeleccionado.nombre_completo }}</h5>
                <p class="text-muted">Cédula: {{ votanteSeleccionado.cedula }}</p>
              </div>

              <!-- Información detallada -->
              <div class="col-md-8">
                <table class="table table-sm">
                  <tbody>
                    <tr>
                      <th width="40%">Teléfono:</th>
                      <td>
                        <span v-if="votanteSeleccionado.telefono" class="badge bg-success">
                          <i class="bi bi-telephone"></i> {{ votanteSeleccionado.telefono }}
                        </span>
                        <span v-else class="text-muted">No registrado</span>
                      </td>
                    </tr>
                    <tr>
                      <th>Colegio Electoral:</th>
                      <td>{{ votanteSeleccionado.colegio_nombre || '-' }}</td>
                    </tr>
                    <tr>
                      <th>Mesa:</th>
                      <td>{{ votanteSeleccionado.mesa || '-' }}</td>
                    </tr>
                    <tr>
                      <th>Dirección:</th>
                      <td>{{ votanteSeleccionado.direccion || votanteSeleccionado.direccion_gps || '-' }}</td>
                    </tr>
                    <tr>
                      <th>Coordenadas:</th>
                      <td>
                        <code>{{ votanteSeleccionado.latitud.toFixed(6) }}, {{ votanteSeleccionado.longitud.toFixed(6) }}</code>
                        <button
                          @click="abrirEnGoogleMaps(votanteSeleccionado)"
                          class="btn btn-sm btn-outline-success ms-2"
                        >
                          <i class="bi bi-map"></i> Ver en Maps
                        </button>
                      </td>
                    </tr>
                    <tr>
                      <th>Agregado por:</th>
                      <td>
                        <span class="badge bg-info">
                          <i class="bi bi-person-badge"></i> {{ votanteSeleccionado.dirigente_nombre }}
                        </span>
                      </td>
                    </tr>
                    <tr>
                      <th>Fecha de registro:</th>
                      <td>{{ formatDate(votanteSeleccionado.fecha_registro) }}</td>
                    </tr>
                    <tr v-if="votanteSeleccionado.gps_capturado_en">
                      <th>GPS capturado:</th>
                      <td>{{ formatDate(votanteSeleccionado.gps_capturado_en) }}</td>
                    </tr>
                    <tr v-if="votanteSeleccionado.observaciones">
                      <th>Observaciones:</th>
                      <td>{{ votanteSeleccionado.observaciones }}</td>
                    </tr>
                  </tbody>
                </table>

                <div class="d-flex gap-2 mt-3">
                  <button @click="editarVotante(votanteSeleccionado)" class="btn btn-primary">
                    <i class="bi bi-pencil-square me-1"></i> Editar
                  </button>
                  <button @click="llamarVotante(votanteSeleccionado)" class="btn btn-success" v-if="votanteSeleccionado.telefono">
                    <i class="bi bi-telephone me-1"></i> Llamar
                  </button>
                </div>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="cerrarDetalle">
              <i class="bi bi-x-circle me-1"></i> Cerrar
            </button>
          </div>
        </div>
      </div>
    </div>
    <div v-if="votanteSeleccionado" class="modal-backdrop fade show"></div>
  </div>
</template>

<script>
import axios from 'axios'
import dayjs from 'dayjs'

export default {
  middleware: 'auth',

  data() {
    return {
      mapa: null,
      marcadores: [],
      marcadoresLayer: null,
      clusterGroup: null,
      votantes: [],
      votanteSeleccionado: null,
      totalVotantes: 0,
      votantesConGps: 0,

      // Filtros
      filtroCoordinador: '',
      filtroColegio: '',
      busqueda: '',
      mostrarClusters: true,

      // Listas
      coordinadores: [],
      colegios: [],

      // Usuario
      user: null,
      isAdmin: false,
      isCandidato: false,

      // Centro del mapa (República Dominicana)
      centerLat: 18.735693,
      centerLng: -70.162651,
      defaultZoom: 8
    }
  },

  mounted() {
    this.obtenerUsuarioActual().then(() => {
      this.inicializarMapa()
      this.cargarDatos()
    })
  },

  beforeDestroy() {
    if (this.mapa) {
      this.mapa.remove()
    }
  },

  methods: {
    async obtenerUsuarioActual() {
      try {
        const response = await axios.get('/user')
        this.user = response.data
        this.isAdmin = this.user.type == 1 || this.user.type == '1'
        this.isCandidato = this.user.type == 4 || this.user.type == '4'
      } catch (error) {
        console.error('Error al obtener usuario:', error)
      }
    },

    inicializarMapa() {
      // Inicializar Leaflet
      this.mapa = L.map('mapa-votantes').setView([this.centerLat, this.centerLng], this.defaultZoom)

      // Agregar capa de OpenStreetMap
      L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '© OpenStreetMap contributors',
        maxZoom: 19
      }).addTo(this.mapa)

      // Inicializar grupo de clusters
      this.clusterGroup = L.markerClusterGroup({
        maxClusterRadius: 50,
        spiderfyOnMaxZoom: true,
        showCoverageOnHover: true,
        zoomToBoundsOnClick: true,
        iconCreateFunction: (cluster) => {
          const count = cluster.getChildCount()
          let size = 'small'
          let className = 'marker-cluster-small'

          if (count > 10) {
            size = 'medium'
            className = 'marker-cluster-medium'
          }
          if (count > 50) {
            size = 'large'
            className = 'marker-cluster-large'
          }

          return L.divIcon({
            html: `<div><span>${count}</span></div>`,
            className: `marker-cluster ${className}`,
            iconSize: L.point(40, 40)
          })
        }
      })

      this.mapa.addLayer(this.clusterGroup)
    },

    async cargarDatos() {
      await Promise.all([
        this.cargarCoordinadores(),
        this.cargarColegios(),
        this.cargarVotantesGps()
      ])
    },

    async cargarCoordinadores() {
      if (!this.isAdmin && !this.isCandidato) return

      try {
        const response = await axios.get('/votantes/dirigentes')
        this.coordinadores = response.data
      } catch (error) {
        console.error('Error al cargar coordinadores:', error)
      }
    },

    async cargarColegios() {
      try {
        const response = await axios.get('/colegios')
        this.colegios = response.data.map(c => ({
          id: c.IDColegio,
          nombre: c.Descripcion
        }))
      } catch (error) {
        console.error('Error al cargar colegios:', error)
      }
    },

    async cargarVotantesGps() {
      try {
        const params = {
          con_gps: true
        }

        if (this.filtroCoordinador) {
          params.dirigente_id = this.filtroCoordinador
        }

        if (this.filtroColegio) {
          params.colegio_id = this.filtroColegio
        }

        const response = await axios.get('/votantes/mapa', { params })
        this.votantes = response.data.votantes
        this.totalVotantes = response.data.total
        this.votantesConGps = response.data.con_gps

        this.actualizarMarcadores()
      } catch (error) {
        console.error('Error al cargar votantes:', error)
      }
    },

    actualizarMarcadores() {
      // Limpiar marcadores existentes
      this.clusterGroup.clearLayers()
      this.marcadores = []

      // Crear marcadores para cada votante
      this.votantes.forEach(votante => {
        if (!votante.latitud || !votante.longitud) return

        // Determinar color del marcador
        let markerColor = 'green' // Por defecto
        if (!votante.telefono) {
          markerColor = 'orange'
        }
        if (this.isCandidato && votante.dirigente_id !== this.user.id) {
          markerColor = 'blue' // Votantes de coordinadores
        }

        // Crear icono personalizado con foto si está disponible
        let iconHtml = ''
        if (votante.foto_base64) {
          iconHtml = `
            <div class="custom-marker-icon" style="background-color: ${markerColor}">
              <img src="data:image/jpeg;base64,${votante.foto_base64}" alt="">
            </div>
          `
        } else {
          iconHtml = `
            <div class="custom-marker-icon no-photo" style="background-color: ${markerColor}">
              <i class="bi bi-person-fill"></i>
            </div>
          `
        }

        const customIcon = L.divIcon({
          className: 'custom-marker',
          html: iconHtml,
          iconSize: [40, 40],
          iconAnchor: [20, 40],
          popupAnchor: [0, -40]
        })

        const marker = L.marker([votante.latitud, votante.longitud], { icon: customIcon })

        // Crear popup con información básica
        const popupContent = `
          <div class="marker-popup">
            <h6>${votante.nombre_completo}</h6>
            <p class="mb-1"><strong>Cédula:</strong> ${votante.cedula}</p>
            <p class="mb-1"><strong>Teléfono:</strong> ${votante.telefono || 'No registrado'}</p>
            <p class="mb-1"><strong>Agregado por:</strong> ${votante.dirigente_nombre}</p>
            <button class="btn btn-sm btn-primary mt-2" onclick="window.verDetalleVotante(${votante.id})">
              <i class="bi bi-info-circle"></i> Ver detalles
            </button>
          </div>
        `

        marker.bindPopup(popupContent)

        // Guardar referencia al votante en el marcador
        marker.votanteData = votante

        this.marcadores.push(marker)
        this.clusterGroup.addLayer(marker)
      })

      // Hacer función global para el popup
      window.verDetalleVotante = (id) => {
        const votante = this.votantes.find(v => v.id === id)
        if (votante) {
          this.mostrarDetalle(votante)
        }
      }
    },

    filtrarMarcadores() {
      if (!this.busqueda) {
        this.actualizarMarcadores()
        return
      }

      const busqueda = this.busqueda.toLowerCase()

      this.clusterGroup.clearLayers()

      this.marcadores.forEach(marker => {
        const votante = marker.votanteData
        const coincide = votante.nombre_completo.toLowerCase().includes(busqueda) ||
                         votante.cedula.includes(busqueda)

        if (coincide) {
          this.clusterGroup.addLayer(marker)
        }
      })
    },

    mostrarDetalle(votante) {
      this.votanteSeleccionado = votante
    },

    cerrarDetalle() {
      this.votanteSeleccionado = null
    },

    centrarMapa() {
      this.mapa.setView([this.centerLat, this.centerLng], this.defaultZoom)
    },

    toggleClusters() {
      this.mostrarClusters = !this.mostrarClusters

      if (this.mostrarClusters) {
        // Reagrupar marcadores
        this.mapa.removeLayer(this.clusterGroup)
        this.mapa.addLayer(this.clusterGroup)
      } else {
        // Mostrar marcadores individuales
        this.mapa.removeLayer(this.clusterGroup)
        this.marcadores.forEach(marker => {
          marker.addTo(this.mapa)
        })
      }
    },

    abrirEnGoogleMaps(votante) {
      const url = `https://www.google.com/maps/search/?api=1&query=${votante.latitud},${votante.longitud}`
      window.open(url, '_blank')
    },

    editarVotante(votante) {
      this.$router.push('/votantes')
    },

    llamarVotante(votante) {
      if (votante.telefono) {
        window.location.href = `tel:${votante.telefono}`
      }
    },

    exportarKML() {
      // Crear contenido KML
      let kml = `<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
<Document>
<name>Votantes GPS</name>`

      this.votantes.forEach(votante => {
        if (votante.latitud && votante.longitud) {
          kml += `
<Placemark>
  <name>${votante.nombre_completo}</name>
  <description>
    Cédula: ${votante.cedula}
    Teléfono: ${votante.telefono || 'N/A'}
    Agregado por: ${votante.dirigente_nombre}
  </description>
  <Point>
    <coordinates>${votante.longitud},${votante.latitud},0</coordinates>
  </Point>
</Placemark>`
        }
      })

      kml += `
</Document>
</kml>`

      // Descargar archivo
      const blob = new Blob([kml], { type: 'application/vnd.google-earth.kml+xml' })
      const url = window.URL.createObjectURL(blob)
      const link = document.createElement('a')
      link.href = url
      link.download = `votantes_${dayjs().format('YYYY-MM-DD')}.kml`
      document.body.appendChild(link)
      link.click()
      link.remove()
    },

    formatDate(date) {
      return dayjs(date).format('DD/MM/YYYY HH:mm')
    }
  }
}
</script>

<style>
/* Importar Leaflet CSS - Agregar en el head del HTML */
@import url('https://unpkg.com/leaflet@1.9.4/dist/leaflet.css');
@import url('https://unpkg.com/leaflet.markercluster@1.5.3/dist/MarkerCluster.css');
@import url('https://unpkg.com/leaflet.markercluster@1.5.3/dist/MarkerCluster.Default.css');

.mapa-container {
  padding: 20px;
}

.map-container {
  height: 600px;
  width: 100%;
  border-radius: 8px;
  position: relative;
}

/* Estilos de marcadores personalizados */
.custom-marker-icon {
  width: 40px;
  height: 40px;
  border-radius: 50% 50% 50% 0;
  border: 3px solid white;
  box-shadow: 0 3px 10px rgba(0,0,0,0.3);
  transform: rotate(-45deg);
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  position: relative;
}

.custom-marker-icon img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transform: rotate(45deg);
  border-radius: 50%;
}

.custom-marker-icon.no-photo {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.custom-marker-icon.no-photo i {
  color: white;
  font-size: 20px;
  transform: rotate(45deg);
}

/* Popup personalizado */
.marker-popup {
  min-width: 200px;
}

.marker-popup h6 {
  color: #333;
  margin-bottom: 10px;
  font-weight: 600;
}

.marker-popup p {
  margin: 5px 0;
  font-size: 14px;
}

/* Leyenda del mapa */
.map-legend {
  position: absolute;
  bottom: 30px;
  right: 30px;
  background: white;
  padding: 15px;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.2);
  z-index: 1000;
}

.map-legend h6 {
  margin: 0 0 10px 0;
  font-weight: 600;
}

.legend-item {
  display: flex;
  align-items: center;
  margin: 5px 0;
}

.legend-color {
  width: 20px;
  height: 20px;
  border-radius: 50%;
  margin-right: 8px;
  border: 2px solid white;
  box-shadow: 0 2px 4px rgba(0,0,0,0.2);
}

/* Clusters personalizados */
.marker-cluster {
  background-clip: padding-box;
  border-radius: 50%;
}

.marker-cluster div {
  width: 100%;
  height: 100%;
  text-align: center;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  color: white;
}

.marker-cluster-small {
  background-color: rgba(110, 204, 57, 0.6);
}

.marker-cluster-small div {
  background-color: rgba(110, 204, 57, 0.8);
}

.marker-cluster-medium {
  background-color: rgba(240, 194, 12, 0.6);
}

.marker-cluster-medium div {
  background-color: rgba(240, 194, 12, 0.8);
}

.marker-cluster-large {
  background-color: rgba(241, 128, 23, 0.6);
}

.marker-cluster-large div {
  background-color: rgba(241, 128, 23, 0.8);
}

/* Foto placeholder */
.photo-placeholder {
  width: 150px;
  height: 150px;
  background: #e9ecef;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 60px;
  color: #adb5bd;
}

/* Responsivo */
@media (max-width: 768px) {
  .map-container {
    height: 400px;
  }

  .map-legend {
    bottom: 10px;
    right: 10px;
    padding: 10px;
  }
}
</style>