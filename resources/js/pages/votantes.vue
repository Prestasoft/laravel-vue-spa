<template>
  <div class="votantes-container">
    <!-- Header con Estadísticas -->
    <div class="statistics-section mb-4">
      <div class="row g-3">
        <div class="col-12 col-sm-6 col-md-3">
          <div class="stat-card stat-card-primary">
            <div class="stat-icon">
              <i class="bi bi-people-fill"></i>
            </div>
            <div class="stat-content">
              <h3>{{ totalVotantes }}</h3>
              <p>Total Votantes</p>
            </div>
          </div>
        </div>
        <div class="col-12 col-sm-6 col-md-3">
          <div class="stat-card stat-card-success">
            <div class="stat-icon">
              <i class="bi bi-check-circle-fill"></i>
            </div>
            <div class="stat-content">
              <h3>{{ votantesActivos }}</h3>
              <p>Activos</p>
            </div>
          </div>
        </div>
        <div class="col-12 col-sm-6 col-md-3">
          <div class="stat-card stat-card-info">
            <div class="stat-icon">
              <i class="bi bi-calendar-check-fill"></i>
            </div>
            <div class="stat-content">
              <h3>{{ votantesHoy }}</h3>
              <p>Registrados Hoy</p>
            </div>
          </div>
        </div>
        <div class="col-12 col-sm-6 col-md-3">
          <div class="stat-card stat-card-warning">
            <div class="stat-icon">
              <i class="bi bi-exclamation-triangle-fill"></i>
            </div>
            <div class="stat-content">
              <h3>{{ votantesSinContacto }}</h3>
              <p>Sin Teléfono</p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Búsqueda Principal -->
    <div class="search-section mb-4">
      <div class="card shadow-sm border-0">
        <div class="card-header bg-gradient-primary text-white">
          <div class="d-flex justify-content-between align-items-center">
            <h5 class="mb-0">
              <i class="bi bi-search me-2"></i>
              Búsqueda y Registro de Votantes
            </h5>
            <button class="btn btn-light btn-sm" @click="toggleFilters">
              <i class="bi bi-funnel"></i>
              {{ showFilters ? 'Ocultar' : 'Mostrar' }} Filtros
            </button>
          </div>
        </div>
        <div class="card-body">
          <form @submit.prevent="buscarVotante" class="search-form">
            <div class="row g-3">
              <div class="col-12 col-md-9">
                <div class="input-group input-group-lg">
                  <span class="input-group-text bg-white">
                    <i class="bi bi-credit-card-2-front"></i>
                  </span>
                  <input
                    v-model="cedulaBusqueda"
                    type="text"
                    class="form-control"
                    placeholder="Ingrese cédula para buscar (ej: 40220259879)"
                    required
                    maxlength="11"
                    @input="formatCedula"
                  >
                </div>
              </div>
              <div class="col-12 col-md-3">
                <button class="btn btn-primary btn-lg w-100" type="submit" :disabled="buscando">
                  <span v-if="!buscando">
                    <i class="bi bi-search me-2"></i>Buscar
                  </span>
                  <span v-else>
                    <span class="spinner-border spinner-border-sm me-2"></span>Buscando...
                  </span>
                </button>
              </div>
            </div>
          </form>

          <!-- Filtros Avanzados -->
          <div v-show="showFilters" class="filters-section mt-4">
            <div class="row g-3">
              <div class="col-12 col-md-3">
                <label class="form-label small text-muted">Colegio Electoral</label>
                <select v-model="filtroColegioId" class="form-select" @change="cargarVotantes">
                  <option value="">Todos los colegios</option>
                  <option v-for="colegio in colegios" :key="colegio.id" :value="colegio.id">
                    {{ colegio.nombre }}
                  </option>
                </select>
              </div>
              <div class="col-12 col-md-3">
                <label class="form-label small text-muted">Mesa Electoral</label>
                <input
                  v-model="filtroMesa"
                  type="text"
                  class="form-control"
                  placeholder="Ej: 001"
                  @change="cargarVotantes"
                >
              </div>
              <div class="col-12 col-md-3">
                <label class="form-label small text-muted">Estado</label>
                <select v-model="filtroActivo" class="form-select" @change="cargarVotantes">
                  <option value="">Todos</option>
                  <option value="1">Activos</option>
                  <option value="0">Inactivos</option>
                </select>
              </div>
              <div class="col-12 col-md-3">
                <label class="form-label small text-muted">Provincia</label>
                <select v-model="filtroProvincia" class="form-select" @change="cargarVotantes">
                  <option value="">Todas las provincias</option>
                  <option v-for="provincia in provincias" :key="provincia" :value="provincia">
                    {{ provincia }}
                  </option>
                </select>
              </div>
              <div v-if="isAdmin || isCandidato" class="col-12 col-md-4">
                <label class="form-label small text-muted">
                  <i class="bi bi-person-badge-fill text-primary"></i> Filtrar por Coordinador
                </label>
                <select v-model="filtroDirigenteId" class="form-select" @change="cargarVotantes">
                  <option value="">Todos los coordinadores</option>
                  <option v-if="isAdmin" value="null">Sin coordinador asignado</option>
                  <option v-if="isAdmin" disabled>──────────────────</option>
                  <option v-for="dirigente in dirigentes" :key="dirigente.id" :value="dirigente.id">
                    {{ dirigente.name }} ({{ dirigente.votantes_count || 0 }} votantes)
                  </option>
                </select>
              </div>
            </div>
          </div>

          <!-- Resultado de búsqueda -->
          <div v-if="resultadoBusqueda" class="mt-4">
            <div class="result-card">
              <div class="row align-items-center">
                <div class="col-12 col-md-3 text-center mb-3 mb-md-0">
                  <img
                    v-if="resultadoBusqueda.foto && resultadoBusqueda.foto.Imagen"
                    :src="'data:image/jpeg;base64,' + resultadoBusqueda.foto.Imagen"
                    alt="Foto"
                    class="img-fluid rounded-circle shadow"
                    style="max-width: 200px;"
                  >
                  <div v-else class="photo-placeholder rounded-circle mx-auto shadow">
                    <i class="bi bi-person-circle"></i>
                  </div>
                </div>
                <div class="col-12 col-md-6">
                  <h4 class="mb-3 text-primary">
                    {{ resultadoBusqueda.padron.nombres }}
                    {{ resultadoBusqueda.padron.apellido1 }}
                    {{ resultadoBusqueda.padron.apellido2 }}
                  </h4>
                  <div class="info-grid">
                    <div class="info-item">
                      <i class="bi bi-credit-card text-muted"></i>
                      <span>{{ resultadoBusqueda.padron.Cedula }}</span>
                    </div>
                    <div class="info-item">
                      <i class="bi bi-calendar text-muted"></i>
                      <span>{{ formatDate(resultadoBusqueda.padron.FechaNacimiento) }}</span>
                    </div>
                    <div class="info-item">
                      <i class="bi bi-gender-ambiguous text-muted"></i>
                      <span>{{ resultadoBusqueda.padron.sexo }}</span>
                    </div>
                    <div class="info-item">
                      <i class="bi bi-building text-muted"></i>
                      <span>{{ resultadoBusqueda.padron.colegio }}</span>
                    </div>
                    <div class="info-item">
                      <i class="bi bi-inbox text-muted"></i>
                      <span>Mesa: {{ resultadoBusqueda.padron.mesa || 'No asignada' }}</span>
                    </div>
                    <div class="info-item">
                      <i class="bi bi-geo-alt text-muted"></i>
                      <span>{{ resultadoBusqueda.padron.municipio }}, {{ resultadoBusqueda.padron.provincia }}</span>
                    </div>
                  </div>
                </div>
                <div class="col-12 col-md-3 text-center">
                  <div v-if="!votanteExiste && (!resultadoBusqueda.registrado_por_otro || !resultadoBusqueda.registrado_por_otro.existe)">
                    <button
                      @click="agregarVotante"
                      class="btn btn-success btn-lg mb-2 w-100"
                      :disabled="agregando"
                    >
                      <i class="bi bi-person-plus-fill me-2"></i>
                      {{ agregando ? 'Agregando...' : 'Agregar a Lista' }}
                    </button>
                    <button
                      @click="mostrarModalGps"
                      class="btn btn-info btn-sm w-100"
                      title="Agregar con ubicación GPS"
                    >
                      <i class="bi bi-geo-alt me-2"></i>
                      Agregar con Ubicación
                    </button>
                  </div>
                  <div v-else-if="votanteExiste" class="alert alert-info mb-0">
                    <i class="bi bi-check-circle-fill"></i>
                    Ya está en tu lista
                  </div>
                  <div v-else-if="resultadoBusqueda.registrado_por_otro && resultadoBusqueda.registrado_por_otro.existe" class="alert alert-warning mb-0">
                    <i class="bi bi-exclamation-triangle-fill"></i>
                    <div>Ya registrado por:</div>
                    <strong>{{ resultadoBusqueda.registrado_por_otro.usuario }}</strong>
                    <div class="small">{{ resultadoBusqueda.registrado_por_otro.tipo }}</div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div v-if="errorBusqueda" class="alert alert-danger mt-3">
            <i class="bi bi-exclamation-triangle-fill me-2"></i>
            {{ errorBusqueda }}
          </div>
        </div>
      </div>
    </div>

    <!-- Lista de Votantes -->
    <div class="votantes-list-section">
      <div class="card shadow-sm border-0">
        <div class="card-header bg-gradient-secondary text-white">
          <div class="d-flex justify-content-between align-items-center flex-wrap">
            <h5 class="mb-0">
              <i class="bi bi-people-fill me-2"></i>
              Lista de Votantes Registrados
            </h5>
            <div class="header-actions d-flex gap-2 mt-2 mt-md-0">
              <button class="btn btn-light btn-sm" @click="exportarExcel">
                <i class="bi bi-file-earmark-excel"></i>
                Exportar Excel
              </button>
              <button class="btn btn-light btn-sm" @click="imprimirLista">
                <i class="bi bi-printer"></i>
                Imprimir
              </button>
            </div>
          </div>
        </div>
        <div class="card-body">
          <!-- Búsqueda rápida -->
          <div class="row mb-3">
            <div class="col-12 col-md-6 col-lg-4">
              <div class="input-group">
                <span class="input-group-text">
                  <i class="bi bi-search"></i>
                </span>
                <input
                  v-model="filtro"
                  type="text"
                  class="form-control"
                  placeholder="Buscar por nombre, cédula o teléfono..."
                  @keyup="buscarVotantes"
                >
              </div>
            </div>
          </div>

          <!-- Tabla Responsiva -->
          <div class="table-responsive">
            <table class="table table-hover align-middle">
              <thead class="table-light">
                <tr>
                  <th class="text-center">Foto</th>
                  <th>Cédula</th>
                  <th>Nombre Completo</th>
                  <th class="d-none d-md-table-cell">Teléfono</th>
                  <th v-if="isAdmin || isCandidato" class="d-none d-lg-table-cell">
                    <i class="bi bi-person-badge-fill text-primary me-1"></i>Coordinador
                  </th>
                  <th class="d-none d-lg-table-cell">Colegio</th>
                  <th class="d-none d-lg-table-cell">Mesa</th>
                  <th>Estado</th>
                  <th class="text-center">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="votante in votantes" :key="votante.id">
                  <td class="text-center">
                    <img
                      v-if="fotosCargadas[votante.cedula]"
                      :src="'data:image/jpeg;base64,' + fotosCargadas[votante.cedula]"
                      alt="Foto"
                      class="rounded-circle cursor-pointer"
                      style="width: 40px; height: 40px; object-fit: cover; cursor: pointer;"
                      @click="verDetalles(votante)"
                    >
                    <div v-else class="photo-placeholder-sm rounded-circle mx-auto cursor-pointer" @click="verDetalles(votante)" style="cursor: pointer;">
                      <i class="bi bi-person"></i>
                    </div>
                  </td>
                  <td class="fw-bold text-primary cursor-pointer" @click="verDetalles(votante)" style="cursor: pointer;">{{ votante.cedula }}</td>
                  <td @click="verDetalles(votante)" style="cursor: pointer;">
                    <div class="d-flex align-items-center">
                      <div>
                        <div class="fw-semibold text-primary">
                          {{ votante.padron_data ? votante.padron_data.nombres : '-' }}
                        </div>
                        <small class="text-muted">
                          {{ votante.padron_data ? `${votante.padron_data.apellido1} ${votante.padron_data.apellido2}` : '-' }}
                        </small>
                      </div>
                    </div>
                  </td>
                  <td class="d-none d-md-table-cell">
                    <span v-if="votante.telefono" class="badge bg-light text-dark">
                      <i class="bi bi-telephone"></i> {{ votante.telefono }}
                    </span>
                    <span v-else class="text-muted">Sin teléfono</span>
                  </td>
                  <td v-if="isAdmin || isCandidato" class="d-none d-lg-table-cell">
                    <div v-if="votante.dirigente" class="d-flex align-items-center">
                      <span class="badge bg-primary">
                        <i class="bi bi-person-badge-fill me-1"></i>
                        {{ votante.dirigente.name }}
                      </span>
                    </div>
                    <span v-else class="badge bg-secondary">Sin asignar</span>
                  </td>
                  <td class="d-none d-lg-table-cell">
                    <small>{{ votante.colegio_nombre || '-' }}</small>
                  </td>
                  <td class="d-none d-lg-table-cell">
                    <span class="badge bg-info">Mesa {{ votante.mesa || 'N/A' }}</span>
                  </td>
                  <td>
                    <span :class="'badge ' + (votante.activo ? 'bg-success' : 'bg-secondary')">
                      {{ votante.activo ? 'Activo' : 'Inactivo' }}
                    </span>
                  </td>
                  <td>
                    <div class="d-flex gap-1">
                      <button
                        v-if="votante.latitud && votante.longitud"
                        @click="abrirEnMaps(votante)"
                        class="btn btn-success btn-sm"
                        title="Ver en Google Maps"
                      >
                        <i class="bi bi-geo-alt-fill"></i>
                      </button>
                      <button
                        @click="editarVotante(votante)"
                        class="btn btn-primary btn-sm"
                        title="Editar información"
                      >
                        <i class="bi bi-pencil-square"></i>
                      </button>
                      <button
                        @click="eliminarVotante(votante)"
                        class="btn btn-danger btn-sm"
                        title="Eliminar votante"
                      >
                        <i class="bi bi-trash3"></i>
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>

            <div v-if="votantes.length === 0" class="text-center py-5">
              <i class="bi bi-inbox" style="font-size: 3rem; color: #dee2e6;"></i>
              <p class="text-muted mt-2">No se encontraron votantes</p>
            </div>
          </div>

          <!-- Paginación -->
          <div v-if="totalPages > 1" class="d-flex justify-content-between align-items-center mt-4 flex-wrap">
            <div class="text-muted mb-2 mb-md-0">
              Mostrando {{ (currentPage - 1) * perPage + 1 }} - {{ Math.min(currentPage * perPage, totalVotantes) }} de {{ totalVotantes }} registros
            </div>
            <nav>
              <ul class="pagination mb-0">
                <li class="page-item" :class="{ disabled: currentPage === 1 }">
                  <a class="page-link" @click="cambiarPagina(currentPage - 1)" href="#">
                    <i class="bi bi-chevron-left"></i>
                  </a>
                </li>
                <li
                  v-for="page in displayPages"
                  :key="page"
                  class="page-item"
                  :class="{ active: page === currentPage }"
                >
                  <a class="page-link" @click="cambiarPagina(page)" href="#">{{ page }}</a>
                </li>
                <li class="page-item" :class="{ disabled: currentPage === totalPages }">
                  <a class="page-link" @click="cambiarPagina(currentPage + 1)" href="#">
                    <i class="bi bi-chevron-right"></i>
                  </a>
                </li>
              </ul>
            </nav>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Edición -->
    <div v-if="showEditModal" class="modal fade show" style="display: block;" tabindex="-1">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header bg-primary text-white">
            <h5 class="modal-title">
              <i class="bi bi-pencil-square me-2"></i>
              Editar Información del Votante
            </h5>
            <button type="button" class="btn-close btn-close-white" @click="cerrarModal"></button>
          </div>
          <div class="modal-body">
            <div v-if="votanteEditando">
              <div class="row mb-3">
                <div class="col-md-6">
                  <label class="form-label">Cédula</label>
                  <input type="text" class="form-control" :value="votanteEditando.cedula" disabled>
                </div>
                <div class="col-md-6">
                  <label class="form-label">Nombre Completo</label>
                  <input type="text" class="form-control"
                    :value="votanteEditando.padron_data ?
                    `${votanteEditando.padron_data.nombres} ${votanteEditando.padron_data.apellido1} ${votanteEditando.padron_data.apellido2}` :
                    '-'" disabled>
                </div>
              </div>
              <div class="row mb-3">
                <div class="col-md-6">
                  <label class="form-label">Teléfono <span class="text-danger">*</span></label>
                  <input
                    v-model="formEdit.telefono"
                    type="tel"
                    class="form-control"
                    placeholder="809-555-1234"
                  >
                </div>
                <div class="col-md-6">
                  <label class="form-label">Mesa Electoral</label>
                  <input
                    v-model="formEdit.mesa"
                    type="text"
                    class="form-control"
                    placeholder="001"
                  >
                </div>
              </div>
              <div class="mb-3">
                <label class="form-label">Dirección</label>
                <div class="input-group">
                  <textarea
                    v-model="formEdit.direccion"
                    class="form-control"
                    rows="2"
                    placeholder="Dirección completa"
                  ></textarea>
                  <button
                    type="button"
                    class="btn btn-outline-info"
                    @click="capturarGpsParaEdicion"
                    title="Capturar ubicación GPS actual"
                  >
                    <i class="bi bi-geo-alt-fill"></i>
                    <span class="d-none d-md-inline ms-1">GPS</span>
                  </button>
                </div>
                <div v-if="formEdit.latitud && formEdit.longitud" class="mt-2">
                  <small class="text-success">
                    <i class="bi bi-check-circle me-1"></i>
                    Ubicación GPS capturada: {{ formEdit.latitud.toFixed(6) }}, {{ formEdit.longitud.toFixed(6) }}
                  </small>
                </div>
              </div>
              <div class="mb-3">
                <label class="form-label">Observaciones</label>
                <textarea
                  v-model="formEdit.observaciones"
                  class="form-control"
                  rows="3"
                  placeholder="Notas adicionales sobre el votante"
                ></textarea>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="cerrarModal">
              <i class="bi bi-x-circle me-2"></i>Cancelar
            </button>
            <button type="button" class="btn btn-primary" @click="guardarCambios" :disabled="guardando">
              <i class="bi bi-check-circle me-2"></i>
              {{ guardando ? 'Guardando...' : 'Guardar Cambios' }}
            </button>
          </div>
        </div>
      </div>
    </div>
    <div v-if="showEditModal" class="modal-backdrop fade show"></div>

    <!-- Modal de Detalles -->
    <div v-if="showDetailsModal" class="modal fade show" style="display: block;" tabindex="-1">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header bg-info text-white">
            <h5 class="modal-title">
              <i class="bi bi-info-circle me-2"></i>
              Detalles del Votante
            </h5>
            <button type="button" class="btn-close btn-close-white" @click="cerrarDetalles"></button>
          </div>
          <div class="modal-body" v-if="votanteDetalle">
            <div class="row">
              <div class="col-md-4 text-center mb-4">
                <img
                  v-if="fotosCargadas[votanteDetalle.cedula]"
                  :src="'data:image/jpeg;base64,' + fotosCargadas[votanteDetalle.cedula]"
                  alt="Foto"
                  class="img-fluid rounded-circle shadow mb-3"
                  style="max-width: 200px;"
                >
                <div v-else class="photo-placeholder rounded-circle mx-auto shadow mb-3">
                  <i class="bi bi-person-circle"></i>
                </div>
                <h5>{{ votanteDetalle.padron_data ? votanteDetalle.padron_data.nombres : '-' }}</h5>
                <p class="text-muted">
                  {{ votanteDetalle.padron_data ? votanteDetalle.padron_data.apellido1 : '' }}
                  {{ votanteDetalle.padron_data ? votanteDetalle.padron_data.apellido2 : '' }}
                </p>
              </div>
              <div class="col-md-8">
                <table class="table table-borderless">
                  <tbody>
                    <tr>
                      <th width="40%">Cédula:</th>
                      <td>{{ votanteDetalle.cedula }}</td>
                    </tr>
                    <tr>
                      <th>Fecha de Nacimiento:</th>
                      <td>{{ votanteDetalle.padron_data ? formatDate(votanteDetalle.padron_data.FechaNacimiento) : '-' }}</td>
                    </tr>
                    <tr>
                      <th>Sexo:</th>
                      <td>{{ votanteDetalle.padron_data ? votanteDetalle.padron_data.sexo : '-' }}</td>
                    </tr>
                    <tr>
                      <th>Estado Civil:</th>
                      <td>{{ votanteDetalle.padron_data ? votanteDetalle.padron_data.estado_civil : '-' }}</td>
                    </tr>
                    <tr>
                      <th>Nacionalidad:</th>
                      <td>{{ votanteDetalle.padron_data ? votanteDetalle.padron_data.nacionalidad : '-' }}</td>
                    </tr>
                    <tr>
                      <th>Teléfono:</th>
                      <td>
                        <span v-if="votanteDetalle.telefono" class="badge bg-success">
                          <i class="bi bi-telephone"></i> {{ votanteDetalle.telefono }}
                        </span>
                        <span v-else class="text-muted">No registrado</span>
                      </td>
                    </tr>
                    <tr v-if="isAdmin && votanteDetalle.dirigente">
                      <th>Agregado por:</th>
                      <td>
                        <span class="badge bg-primary">
                          <i class="bi bi-person-badge-fill"></i> {{ votanteDetalle.dirigente.name }}
                        </span>
                      </td>
                    </tr>
                    <tr>
                      <th>Colegio Electoral:</th>
                      <td>{{ votanteDetalle.colegio_nombre || '-' }}</td>
                    </tr>
                    <tr>
                      <th>Mesa Electoral:</th>
                      <td>
                        <span class="badge bg-info">Mesa {{ votanteDetalle.mesa || 'N/A' }}</span>
                      </td>
                    </tr>
                    <tr>
                      <th>Municipio:</th>
                      <td>{{ votanteDetalle.padron_data ? votanteDetalle.padron_data.municipio : '-' }}</td>
                    </tr>
                    <tr>
                      <th>Provincia:</th>
                      <td>{{ votanteDetalle.padron_data ? votanteDetalle.padron_data.provincia : '-' }}</td>
                    </tr>
                    <tr>
                      <th>Dirección:</th>
                      <td>{{ votanteDetalle.direccion || 'No registrada' }}</td>
                    </tr>
                    <tr>
                      <th>Observaciones:</th>
                      <td>{{ votanteDetalle.observaciones || 'Sin observaciones' }}</td>
                    </tr>
                    <tr>
                      <th>Fecha de Registro:</th>
                      <td>{{ formatDateTime(votanteDetalle.fecha_registro) }}</td>
                    </tr>
                    <tr>
                      <th>Estado:</th>
                      <td>
                        <span :class="'badge ' + (votanteDetalle.activo ? 'bg-success' : 'bg-secondary')">
                          {{ votanteDetalle.activo ? 'Activo' : 'Inactivo' }}
                        </span>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="cerrarDetalles">
              <i class="bi bi-x-circle me-2"></i>Cerrar
            </button>
          </div>
        </div>
      </div>
    </div>
    <div v-if="showDetailsModal" class="modal-backdrop fade show"></div>

    <!-- Modal de GPS -->
    <div v-if="showGpsModal" class="modal fade show" style="display: block;" tabindex="-1">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header bg-info text-white">
            <h5 class="modal-title">
              <i class="bi bi-geo-alt-fill me-2"></i>
              Capturar Ubicación GPS
            </h5>
            <button type="button" class="btn-close btn-close-white" @click="cerrarModalGps"></button>
          </div>
          <div class="modal-body">
            <div v-if="!gpsPermissionGranted && !capturingGps" class="text-center py-4">
              <i class="bi bi-geo-alt" style="font-size: 4rem; color: #17a2b8;"></i>
              <h4 class="mt-3">Capturar Ubicación GPS</h4>
              <p class="text-muted">
                Para capturar la ubicación GPS del votante, necesitamos acceso a la ubicación de tu dispositivo.
              </p>
              <button @click="solicitarPermisoGps" class="btn btn-info btn-lg mb-3">
                <i class="bi bi-geo-alt-fill me-2"></i>
                Obtener Ubicación Automática
              </button>

              <div class="mt-3">
                <button @click="mostrarIngresoManual" class="btn btn-outline-secondary">
                  <i class="bi bi-pencil-square me-2"></i>
                  Ingresar Coordenadas Manualmente
                </button>
              </div>

              <!-- Ingreso manual de coordenadas -->
              <div v-if="mostrarManual" class="mt-4 text-start">
                <hr>
                <h5>Ingreso Manual de Coordenadas</h5>
                <p class="text-muted small">
                  Puedes obtener las coordenadas desde Google Maps haciendo clic derecho en la ubicación
                </p>
                <div class="row">
                  <div class="col-md-6">
                    <label class="form-label">Latitud</label>
                    <input
                      v-model.number="gpsManual.latitud"
                      type="number"
                      step="0.000001"
                      class="form-control"
                      placeholder="Ej: 18.735693"
                      min="-90"
                      max="90"
                    >
                  </div>
                  <div class="col-md-6">
                    <label class="form-label">Longitud</label>
                    <input
                      v-model.number="gpsManual.longitud"
                      type="number"
                      step="0.000001"
                      class="form-control"
                      placeholder="Ej: -70.162651"
                      min="-180"
                      max="180"
                    >
                  </div>
                </div>
                <button
                  @click="confirmarManual"
                  class="btn btn-success mt-3"
                  :disabled="!gpsManual.latitud || !gpsManual.longitud"
                >
                  <i class="bi bi-check-circle me-2"></i>
                  Confirmar Coordenadas
                </button>
              </div>
            </div>

            <div v-if="capturingGps" class="text-center py-4">
              <div class="spinner-border text-info" style="width: 3rem; height: 3rem;">
                <span class="visually-hidden">Obteniendo ubicación...</span>
              </div>
              <h4 class="mt-3">Obteniendo Ubicación...</h4>
              <p class="text-muted">
                Por favor espere mientras capturamos su ubicación actual
              </p>
            </div>

            <div v-if="gpsError" class="alert alert-danger">
              <div class="d-flex justify-content-between align-items-start">
                <div v-html="gpsError"></div>
                <button @click="reintentar" class="btn btn-sm btn-danger ms-3">
                  <i class="bi bi-arrow-clockwise"></i> Reintentar
                </button>
              </div>
            </div>

            <div v-if="gpsData.latitud && gpsData.longitud && !capturingGps" class="gps-result">
              <div class="alert alert-success">
                <i class="bi bi-check-circle-fill me-2"></i>
                Ubicación capturada exitosamente
              </div>

              <div class="row">
                <div class="col-md-6">
                  <div class="info-card">
                    <label class="text-muted small">Latitud</label>
                    <div class="fw-bold">{{ gpsData.latitud.toFixed(6) }}°</div>
                  </div>
                </div>
                <div class="col-md-6">
                  <div class="info-card">
                    <label class="text-muted small">Longitud</label>
                    <div class="fw-bold">{{ gpsData.longitud.toFixed(6) }}°</div>
                  </div>
                </div>
              </div>

              <div class="mt-3">
                <label class="form-label">Descripción de la ubicación (opcional)</label>
                <input
                  v-model="gpsData.direccion_gps"
                  type="text"
                  class="form-control"
                  placeholder="Ej: Casa amarilla frente al colmado"
                >
              </div>

              <div v-if="gpsData.accuracy" class="mt-2">
                <small class="text-muted">
                  <i class="bi bi-info-circle me-1"></i>
                  Precisión: ±{{ Math.round(gpsData.accuracy) }} metros
                </small>
              </div>

              <!-- Vista previa del mapa -->
              <div class="mt-3">
                <iframe
                  :src="`https://www.google.com/maps?q=${gpsData.latitud},${gpsData.longitud}&output=embed`"
                  width="100%"
                  height="300"
                  style="border:0; border-radius: 8px;"
                  allowfullscreen=""
                  loading="lazy"
                ></iframe>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="cerrarModalGps">
              <i class="bi bi-x-circle me-2"></i>Cancelar
            </button>
            <button
              v-if="gpsData.latitud && gpsData.longitud"
              type="button"
              class="btn btn-success"
              @click="confirmarGpsYAgregar"
              :disabled="agregando"
            >
              <i class="bi bi-check-circle me-2"></i>
              {{ agregando ? 'Agregando...' : 'Agregar con Ubicación' }}
            </button>
          </div>
        </div>
      </div>
    </div>
    <div v-if="showGpsModal" class="modal-backdrop fade show"></div>
  </div>
</template>

<script>
import axios from 'axios'
import dayjs from 'dayjs'
import Swal from 'sweetalert2'

export default {
  middleware: 'auth',

  data() {
    return {
      // Búsqueda
      cedulaBusqueda: '',
      buscando: false,
      resultadoBusqueda: null,
      errorBusqueda: null,
      votanteExiste: false,
      agregando: false,

      // Lista de votantes
      votantes: [],
      totalVotantes: 0,
      currentPage: 1,
      totalPages: 1,
      filtro: '',
      perPage: 10,

      // GPS
      showGpsModal: false,
      capturingGps: false,
      gpsData: {
        latitud: null,
        longitud: null,
        direccion_gps: '',
        accuracy: null
      },
      gpsError: null,
      votanteParaGps: null,
      mostrarManual: false,
      gpsManual: {
        latitud: null,
        longitud: null
      },

      // Filtros
      showFilters: false,
      filtroColegioId: '',
      filtroMesa: '',
      filtroActivo: '',
      filtroProvincia: '',
      filtroDirigenteId: '',

      // Estadísticas
      votantesActivos: 0,
      votantesHoy: 0,
      votantesSinContacto: 0,

      // Listas para selectores
      colegios: [],
      provincias: [],
      dirigentes: [],

      // Usuario actual
      user: null,
      isAdmin: false,
      isCandidato: false,

      // Modales
      showEditModal: false,
      showDetailsModal: false,
      votanteEditando: null,
      votanteDetalle: null,
      guardando: false,
      formEdit: {
        telefono: '',
        mesa: '',
        direccion: '',
        latitud: null,
        longitud: null,
        direccion_gps: '',
        observaciones: ''
      },

      // Fotos
      fotosCargadas: {},

      // Permisos GPS
      gpsPermissionGranted: false
    }
  },

  computed: {
    displayPages() {
      const pages = []
      const maxPages = 5
      let start = Math.max(1, this.currentPage - 2)
      let end = Math.min(this.totalPages, start + maxPages - 1)

      if (end - start < maxPages - 1) {
        start = Math.max(1, end - maxPages + 1)
      }

      for (let i = start; i <= end; i++) {
        pages.push(i)
      }

      return pages
    }
  },

  mounted() {
    this.obtenerUsuarioActual().then(() => {
      this.cargarVotantes()
      this.cargarEstadisticas()
      this.cargarColegios()
      this.cargarDirigentes()
    })
  },

  methods: {
    formatCedula(event) {
      // Formatear cédula mientras se escribe
      let value = event.target.value.replace(/\D/g, '')
      this.cedulaBusqueda = value
    },

    toggleFilters() {
      this.showFilters = !this.showFilters
    },

    async buscarVotante() {
      if (!this.cedulaBusqueda) return

      this.buscando = true
      this.errorBusqueda = null
      this.resultadoBusqueda = null
      this.votanteExiste = false

      try {
        const response = await axios.get(`/votantes/buscar/${this.cedulaBusqueda}`)

        this.resultadoBusqueda = response.data
        this.votanteExiste = response.data.ya_registrado

        // Verificar si está registrado por otro usuario
        if (response.data.registrado_por_otro && response.data.registrado_por_otro.existe) {
          const info = response.data.registrado_por_otro
          Swal.fire({
            icon: 'warning',
            title: '¡Votante ya registrado!',
            html: `
              <div class="text-start">
                <p>Este votante ya fue agregado por:</p>
                <div class="alert alert-warning">
                  <strong>${info.tipo}:</strong> ${info.usuario}<br>
                  <small>Fecha de registro: ${this.formatDateTime(info.fecha_registro)}</small>
                </div>
              </div>
            `,
            confirmButtonText: 'Entendido',
            confirmButtonColor: '#ffc107'
          })
        }
      } catch (error) {
        this.errorBusqueda = error.response?.data?.message || 'No se encontró la cédula'
      } finally {
        this.buscando = false
      }
    },

    async agregarVotante() {
      if (!this.resultadoBusqueda) return

      this.agregando = true
      try {
        const votante = {
          cedula: this.resultadoBusqueda.padron.Cedula,
          colegio_id: this.resultadoBusqueda.padron.colegio_id,
          mesa: this.resultadoBusqueda.padron.mesa // Incluir la mesa (CodigoColegio)
        }

        await axios.post('/votantes', votante)

        Swal.fire({
          icon: 'success',
          title: 'Votante agregado',
          text: 'El votante ha sido registrado exitosamente',
          timer: 2000,
          showConfirmButton: false
        })

        this.votanteExiste = true
        this.cargarVotantes()
        this.cargarEstadisticas()
      } catch (error) {
        Swal.fire({
          icon: 'error',
          title: 'Error',
          text: error.response?.data?.message || 'Error al agregar votante'
        })
      } finally {
        this.agregando = false
      }
    },

    async cargarVotantes() {
      try {
        const params = {
          page: this.currentPage,
          per_page: this.perPage,
          search: this.filtro
        }

        if (this.filtroColegioId) params.colegio_id = this.filtroColegioId
        if (this.filtroMesa) params.mesa = this.filtroMesa
        if (this.filtroActivo !== '') params.activo = this.filtroActivo
        if (this.filtroDirigenteId) {
          params.dirigente_id = this.filtroDirigenteId
          console.log('Filtrando por dirigente:', this.filtroDirigenteId)
        }

        const response = await axios.get('/votantes', { params })

        this.votantes = response.data.data
        this.totalVotantes = response.data.total
        this.totalPages = response.data.last_page
        this.currentPage = response.data.current_page

        // Cargar fotos
        this.votantes.forEach(votante => {
          this.cargarFoto(votante.cedula)
        })

        // Extraer provincias únicas
        const provinciasSet = new Set()
        this.votantes.forEach(v => {
          if (v.padron_data && v.padron_data.provincia) {
            provinciasSet.add(v.padron_data.provincia)
          }
        })
        this.provincias = Array.from(provinciasSet).sort()
      } catch (error) {
        console.error('Error al cargar votantes:', error)
      }
    },

    async cargarFoto(cedula) {
      if (this.fotosCargadas[cedula]) return

      try {
        const response = await axios.get(`/votantes/foto/${cedula}`)
        if (response.data.success && response.data.imagen) {
          this.$set(this.fotosCargadas, cedula, response.data.imagen)
        }
      } catch (error) {
        // Silenciar error de fotos
      }
    },

    async cargarEstadisticas() {
      try {
        const response = await axios.get('/votantes/estadisticas')
        const data = response.data

        this.votantesActivos = data.activos || 0
        this.votantesHoy = data.ultimos_30_dias && data.ultimos_30_dias.find(d =>
          dayjs(d.fecha).isSame(dayjs(), 'day')
        )?.total || 0

        // Contar votantes sin teléfono
        const votantesResponse = await axios.get('/votantes', {
          params: { per_page: 1000 }
        })
        this.votantesSinContacto = votantesResponse.data.data.filter(v => !v.telefono).length
      } catch (error) {
        console.error('Error al cargar estadísticas:', error)
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

    async cargarDirigentes() {
      // Admins y candidatos pueden ver coordinadores
      if (!this.isAdmin && !this.isCandidato) return

      try {
        const response = await axios.get('/votantes/dirigentes')
        this.dirigentes = response.data
        console.log('Coordinadores cargados:', this.dirigentes)
      } catch (error) {
        console.error('Error al cargar coordinadores:', error)
      }
    },

    async obtenerUsuarioActual() {
      try {
        const response = await axios.get('/user')
        this.user = response.data
        this.isAdmin = this.user.type == 1 || this.user.type == '1'
        this.isCandidato = this.user.type == 4 || this.user.type == '4'
        console.log('Usuario actual:', this.user, 'Es admin:', this.isAdmin, 'Es candidato:', this.isCandidato)
      } catch (error) {
        console.error('Error al obtener usuario:', error)
      }
    },

    buscarVotantes() {
      this.currentPage = 1
      this.cargarVotantes()
    },

    cambiarPagina(page) {
      if (page >= 1 && page <= this.totalPages) {
        this.currentPage = page
        this.cargarVotantes()
      }
    },

    editarVotante(votante) {
      this.votanteEditando = votante
      this.formEdit = {
        telefono: votante.telefono || '',
        mesa: votante.mesa || '',
        direccion: votante.direccion || '',
        latitud: votante.latitud || null,
        longitud: votante.longitud || null,
        direccion_gps: votante.direccion_gps || '',
        observaciones: votante.observaciones || ''
      }
      this.showEditModal = true
    },

    async guardarCambios() {
      if (!this.votanteEditando) return

      this.guardando = true
      try {
        await axios.put(`/votantes/${this.votanteEditando.id}`, this.formEdit)

        Swal.fire({
          icon: 'success',
          title: 'Actualizado',
          text: 'Los datos han sido actualizados correctamente',
          timer: 2000,
          showConfirmButton: false
        })

        this.cerrarModal()
        this.cargarVotantes()
      } catch (error) {
        Swal.fire({
          icon: 'error',
          title: 'Error',
          text: error.response?.data?.message || 'Error al actualizar'
        })
      } finally {
        this.guardando = false
      }
    },

    cerrarModal() {
      this.showEditModal = false
      this.votanteEditando = null
      this.formEdit = {
        telefono: '',
        mesa: '',
        direccion: '',
        latitud: null,
        longitud: null,
        direccion_gps: '',
        observaciones: ''
      }
    },

    verDetalles(votante) {
      this.votanteDetalle = votante
      this.showDetailsModal = true
      // Asegurar que la foto esté cargada
      this.cargarFoto(votante.cedula)
    },

    cerrarDetalles() {
      this.showDetailsModal = false
      this.votanteDetalle = null
    },

    async eliminarVotante(votante) {
      const result = await Swal.fire({
        title: '¿Está seguro?',
        text: `¿Desea eliminar a ${votante.padron_data ? votante.padron_data.nombres : 'este votante'} de su lista?`,
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#d33',
        cancelButtonColor: '#3085d6',
        confirmButtonText: 'Sí, eliminar',
        cancelButtonText: 'Cancelar'
      })

      if (result.isConfirmed) {
        try {
          await axios.delete(`/votantes/${votante.id}`)

          Swal.fire({
            icon: 'success',
            title: 'Eliminado',
            text: 'El votante ha sido eliminado',
            timer: 2000,
            showConfirmButton: false
          })

          this.cargarVotantes()
          this.cargarEstadisticas()
        } catch (error) {
          Swal.fire({
            icon: 'error',
            title: 'Error',
            text: error.response?.data?.message || 'Error al eliminar'
          })
        }
      }
    },

    async exportarExcel() {
      try {
        const response = await axios.get('/votantes/exportar', {
          params: { formato: 'csv' },
          responseType: 'blob'
        })

        const url = window.URL.createObjectURL(new Blob([response.data]))
        const link = document.createElement('a')
        link.href = url
        link.setAttribute('download', `votantes_${dayjs().format('YYYY-MM-DD')}.csv`)
        document.body.appendChild(link)
        link.click()
        link.remove()
      } catch (error) {
        Swal.fire({
          icon: 'error',
          title: 'Error',
          text: 'Error al exportar los datos'
        })
      }
    },

    imprimirLista() {
      window.print()
    },

    formatDate(date) {
      return dayjs(date).format('DD/MM/YYYY')
    },

    formatDateTime(date) {
      return dayjs(date).format('DD/MM/YYYY HH:mm')
    },

    getEstadoColor(activo) {
      return activo ? 'success' : 'secondary'
    },

    // Métodos GPS
    mostrarModalGps() {
      this.showGpsModal = true
      this.gpsError = null
      this.gpsData = {
        latitud: null,
        longitud: null,
        direccion_gps: '',
        accuracy: null
      }
    },

    cerrarModalGps() {
      this.showGpsModal = false
      this.gpsError = null
      this.capturingGps = false
    },

    async solicitarPermisoGps() {
      // Verificar si estamos en HTTPS (requerido para geolocalización en muchos navegadores)
      if (location.protocol !== 'https:' && location.hostname !== 'localhost') {
        this.gpsError = `
          <div class="text-start">
            <strong>⚠️ Conexión no segura detectada</strong><br>
            <p class="mt-2">La geolocalización requiere una conexión HTTPS.</p>
            <p class="mb-0">Por favor, accede al sitio usando: <br>
            <code>https://${location.hostname}</code></p>
          </div>
        `
        return
      }

      if (!navigator.geolocation) {
        this.gpsError = 'Tu navegador no soporta geolocalización. Intenta con Chrome, Firefox o Safari.'
        return
      }

      this.capturingGps = true
      this.gpsError = null

      // Primero intentar obtener permisos si la API está disponible
      if (navigator.permissions) {
        try {
          const permissionStatus = await navigator.permissions.query({ name: 'geolocation' })
          console.log('Estado del permiso:', permissionStatus.state)

          if (permissionStatus.state === 'denied') {
            this.capturingGps = false
            this.gpsError = `
              <div class="text-start">
                <strong>📍 Permiso de ubicación bloqueado</strong><br>
                <p class="mt-2 mb-1">Para habilitar la ubicación:</p>
                <ol class="text-start mb-0">
                  <li>Haz clic en el icono de candado 🔒 en la barra de direcciones</li>
                  <li>Busca "Ubicación" y cámbialo a "Permitir"</li>
                  <li>Recarga la página y vuelve a intentar</li>
                </ol>
                <p class="mt-2 mb-0"><small>En móvil: Ve a Configuración > Sitios web > Ubicación</small></p>
              </div>
            `
            return
          }
        } catch (e) {
          console.log('API de permisos no disponible:', e)
        }
      }

      try {
        const position = await new Promise((resolve, reject) => {
          navigator.geolocation.getCurrentPosition(
            resolve,
            reject,
            {
              enableHighAccuracy: true,
              timeout: 15000, // Aumentado a 15 segundos
              maximumAge: 0
            }
          )
        })

        this.gpsData.latitud = position.coords.latitude
        this.gpsData.longitud = position.coords.longitude
        this.gpsData.accuracy = position.coords.accuracy
        this.gpsPermissionGranted = true
        this.capturingGps = false
      } catch (error) {
        this.capturingGps = false
        console.error('Error GPS:', error)

        switch(error.code) {
          case 1: // PERMISSION_DENIED
            this.gpsError = `
              <div class="text-start">
                <strong>📍 Permiso denegado</strong><br>
                <p class="mt-2 mb-1">Para activar la ubicación:</p>
                <div class="alert alert-info mt-2 mb-0">
                  <strong>En PC/Laptop:</strong><br>
                  • Chrome: Configuración > Privacidad > Configuración de sitios > Ubicación<br>
                  • Firefox: Configuración > Privacidad > Permisos > Ubicación<br>
                  • Edge: Configuración > Cookies y permisos > Ubicación
                </div>
                <div class="alert alert-info mt-2 mb-0">
                  <strong>En Android:</strong><br>
                  • Configuración > Aplicaciones > [Tu navegador] > Permisos > Ubicación<br>
                  • Activa "Ubicación" y selecciona "Permitir solo al usar la app"
                </div>
                <div class="alert alert-info mt-2 mb-0">
                  <strong>En iPhone/iPad:</strong><br>
                  • Configuración > [Tu navegador] > Ubicación > Permitir
                </div>
              </div>
            `
            break
          case 2: // POSITION_UNAVAILABLE
            this.gpsError = `
              <div class="text-start">
                <strong>📍 Ubicación no disponible</strong><br>
                <p class="mt-2 mb-1">Por favor verifica:</p>
                <ul class="mb-0">
                  <li>Que el GPS esté activado en tu dispositivo</li>
                  <li>Que tengas buena señal (intenta cerca de una ventana)</li>
                  <li>Que no estés en modo avión</li>
                </ul>
              </div>
            `
            break
          case 3: // TIMEOUT
            this.gpsError = `
              <div class="text-start">
                <strong>⏱️ Tiempo de espera agotado</strong><br>
                <p class="mt-2 mb-0">La señal GPS es débil. Por favor:</p>
                <ul class="mb-0">
                  <li>Muévete a un área abierta o cerca de una ventana</li>
                  <li>Espera unos segundos e intenta de nuevo</li>
                </ul>
              </div>
            `
            break
          default:
            this.gpsError = 'Error desconocido al obtener ubicación. Código: ' + error.code
        }
      }
    },

    reintentar() {
      this.solicitarPermisoGps()
    },

    async confirmarGpsYAgregar() {
      if (!this.resultadoBusqueda || !this.gpsData.latitud || !this.gpsData.longitud) return

      this.agregando = true
      try {
        const votante = {
          cedula: this.resultadoBusqueda.padron.Cedula,
          colegio_id: this.resultadoBusqueda.padron.colegio_id,
          mesa: this.resultadoBusqueda.padron.mesa,
          latitud: this.gpsData.latitud,
          longitud: this.gpsData.longitud,
          direccion_gps: this.gpsData.direccion_gps || `GPS: ${this.gpsData.latitud.toFixed(6)}, ${this.gpsData.longitud.toFixed(6)}`
        }

        await axios.post('/votantes', votante)

        Swal.fire({
          icon: 'success',
          title: 'Votante agregado con ubicación',
          text: 'El votante ha sido registrado con su ubicación GPS',
          timer: 2000,
          showConfirmButton: false
        })

        this.votanteExiste = true
        this.cerrarModalGps()
        this.cargarVotantes()
        this.cargarEstadisticas()
      } catch (error) {
        Swal.fire({
          icon: 'error',
          title: 'Error',
          text: error.response?.data?.message || 'Error al agregar votante'
        })
      } finally {
        this.agregando = false
      }
    },

    async capturarGpsParaEdicion() {
      if (!navigator.geolocation) {
        Swal.fire({
          icon: 'warning',
          title: 'No disponible',
          text: 'Tu navegador no soporta geolocalización'
        })
        return
      }

      const { isConfirmed } = await Swal.fire({
        title: 'Capturar Ubicación GPS',
        text: '¿Deseas capturar la ubicación GPS actual?',
        icon: 'question',
        showCancelButton: true,
        confirmButtonText: 'Sí, capturar',
        cancelButtonText: 'Cancelar',
        confirmButtonColor: '#17a2b8'
      })

      if (!isConfirmed) return

      Swal.fire({
        title: 'Obteniendo ubicación...',
        html: 'Por favor espera mientras capturamos tu ubicación',
        allowOutsideClick: false,
        didOpen: () => {
          Swal.showLoading()
        }
      })

      try {
        const position = await new Promise((resolve, reject) => {
          navigator.geolocation.getCurrentPosition(
            resolve,
            reject,
            {
              enableHighAccuracy: true,
              timeout: 10000,
              maximumAge: 0
            }
          )
        })

        this.formEdit.latitud = position.coords.latitude
        this.formEdit.longitud = position.coords.longitude
        this.formEdit.direccion_gps = `GPS: ${position.coords.latitude.toFixed(6)}, ${position.coords.longitude.toFixed(6)}`

        Swal.fire({
          icon: 'success',
          title: 'Ubicación capturada',
          text: `Coordenadas: ${position.coords.latitude.toFixed(6)}, ${position.coords.longitude.toFixed(6)}`,
          timer: 2000,
          showConfirmButton: false
        })
      } catch (error) {
        let errorMessage = 'Error al obtener la ubicación'
        switch(error.code) {
          case error.PERMISSION_DENIED:
            errorMessage = 'Permiso de ubicación denegado'
            break
          case error.POSITION_UNAVAILABLE:
            errorMessage = 'Ubicación no disponible'
            break
          case error.TIMEOUT:
            errorMessage = 'Tiempo de espera agotado'
            break
        }
        Swal.fire({
          icon: 'error',
          title: 'Error',
          text: errorMessage
        })
      }
    },

    abrirEnMaps(votante) {
      if (votante.latitud && votante.longitud) {
        const url = `https://www.google.com/maps/search/?api=1&query=${votante.latitud},${votante.longitud}`
        window.open(url, '_blank')
      }
    },

    mostrarIngresoManual() {
      this.mostrarManual = true
      this.gpsManual = {
        latitud: null,
        longitud: null
      }
    },

    confirmarManual() {
      if (!this.gpsManual.latitud || !this.gpsManual.longitud) return

      // Validar rangos
      if (this.gpsManual.latitud < -90 || this.gpsManual.latitud > 90) {
        Swal.fire({
          icon: 'error',
          title: 'Error',
          text: 'La latitud debe estar entre -90 y 90'
        })
        return
      }

      if (this.gpsManual.longitud < -180 || this.gpsManual.longitud > 180) {
        Swal.fire({
          icon: 'error',
          title: 'Error',
          text: 'La longitud debe estar entre -180 y 180'
        })
        return
      }

      // Asignar las coordenadas manuales
      this.gpsData.latitud = this.gpsManual.latitud
      this.gpsData.longitud = this.gpsManual.longitud
      this.gpsData.accuracy = null
      this.gpsPermissionGranted = true
      this.mostrarManual = false

      Swal.fire({
        icon: 'success',
        title: 'Coordenadas ingresadas',
        text: 'Las coordenadas han sido registradas exitosamente',
        timer: 2000,
        showConfirmButton: false
      })
    }
  }
}
</script>

<style scoped>
.votantes-container {
  padding: 20px;
}

/* Tarjetas de estadísticas */
.stat-card {
  background: white;
  border-radius: 12px;
  padding: 20px;
  display: flex;
  align-items: center;
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
  transition: transform 0.3s, box-shadow 0.3s;
  border: 1px solid #f0f0f0;
}

.stat-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 4px 16px rgba(0,0,0,0.12);
}

.stat-icon {
  width: 60px;
  height: 60px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  margin-right: 15px;
}

.stat-card-primary .stat-icon {
  background: rgba(13, 110, 253, 0.1);
  color: #0d6efd;
}

.stat-card-success .stat-icon {
  background: rgba(25, 135, 84, 0.1);
  color: #198754;
}

.stat-card-info .stat-icon {
  background: rgba(13, 202, 240, 0.1);
  color: #0dcaf0;
}

.stat-card-warning .stat-icon {
  background: rgba(255, 193, 7, 0.1);
  color: #ffc107;
}

.stat-content h3 {
  margin: 0;
  font-size: 28px;
  font-weight: 700;
  color: #2c3e50;
}

.stat-content p {
  margin: 0;
  color: #6c757d;
  font-size: 14px;
}

/* Headers con gradiente */
.bg-gradient-primary {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.bg-gradient-secondary {
  background: linear-gradient(135deg, #667eea 0%, #4c9aff 100%);
}

/* Tarjetas mejoradas */
.card {
  border-radius: 12px;
  overflow: hidden;
}

.card-header {
  padding: 15px 20px;
  font-weight: 500;
}

/* Formulario de búsqueda */
.search-form .input-group-lg .form-control {
  font-size: 1.1rem;
  padding: 12px 20px;
  border-radius: 8px;
}

.search-form .btn-lg {
  padding: 12px 30px;
  font-weight: 500;
  border-radius: 8px;
}

/* Resultado de búsqueda */
.result-card {
  background: #f8f9fa;
  border-radius: 12px;
  padding: 25px;
  border: 1px solid #e9ecef;
}

.photo-placeholder {
  width: 200px;
  height: 200px;
  background: #e9ecef;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 80px;
  color: #adb5bd;
}

.photo-placeholder-sm {
  width: 40px;
  height: 40px;
  background: #e9ecef;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
  color: #adb5bd;
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 10px;
}

.info-item {
  display: flex;
  align-items: center;
  gap: 8px;
}

.info-item i {
  width: 20px;
}

/* Filtros */
.filters-section {
  padding-top: 20px;
  border-top: 1px solid #e9ecef;
  animation: slideDown 0.3s ease;
}

@keyframes slideDown {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* Tabla mejorada */
.table th {
  font-weight: 600;
  text-transform: uppercase;
  font-size: 0.85rem;
  letter-spacing: 0.5px;
  color: #6c757d;
  border-bottom-width: 2px;
}

.table tbody tr {
  transition: background-color 0.2s;
}

.table tbody tr:hover {
  background-color: rgba(0,0,0,0.02);
}

/* Elementos clickeables */
.cursor-pointer {
  cursor: pointer !important;
  transition: color 0.2s, transform 0.2s;
}

.cursor-pointer:hover {
  color: #0056b3 !important;
}

td.cursor-pointer:hover {
  text-decoration: underline;
}

img.cursor-pointer:hover,
.photo-placeholder-sm.cursor-pointer:hover {
  transform: scale(1.1);
  box-shadow: 0 2px 8px rgba(0,0,0,0.2);
}

/* Botones profesionales mejorados */
.btn {
  font-weight: 500;
  transition: all 0.3s;
}

.btn-primary, .btn-danger {
  border: none;
  font-weight: 600;
  transition: all 0.3s ease;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.btn-primary {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
  background: linear-gradient(135deg, #5a67d8 0%, #6b4299 100%);
}

.btn-danger {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
}

.btn-danger:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(245, 87, 108, 0.4);
  background: linear-gradient(135deg, #ed6ea0 0%, #ec3838 100%);
}

.btn-sm {
  padding: 0.375rem 0.75rem;
  font-size: 0.875rem;
  border-radius: 6px;
}

/* Gap entre botones */
.gap-1 {
  gap: 0.5rem;
}

.btn-group .btn {
  padding: 4px 10px;
}

/* Paginación */
.pagination {
  gap: 5px;
}

.page-link {
  border: none;
  border-radius: 8px;
  color: #6c757d;
  padding: 8px 14px;
  transition: all 0.3s;
}

.page-link:hover {
  background-color: #e9ecef;
  color: #495057;
}

.page-item.active .page-link {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

/* Modales mejorados */
.modal-content {
  border-radius: 12px;
  border: none;
}

.modal-header {
  border-bottom: 1px solid rgba(0,0,0,0.1);
}

.modal-footer {
  border-top: 1px solid rgba(0,0,0,0.1);
}

/* Responsive */
@media (max-width: 768px) {
  .votantes-container {
    padding: 10px;
  }

  .stat-card {
    margin-bottom: 10px;
  }

  .info-grid {
    grid-template-columns: 1fr;
  }

  .table {
    font-size: 0.9rem;
  }

  .btn-group .btn {
    padding: 2px 6px;
    font-size: 0.85rem;
  }

  .header-actions {
    width: 100%;
    justify-content: center;
  }
}

/* Print styles */
@media print {
  .statistics-section,
  .search-section,
  .header-actions,
  .btn-group,
  .pagination,
  .modal {
    display: none !important;
  }

  .card {
    border: 1px solid #000 !important;
    box-shadow: none !important;
  }

  .table {
    font-size: 10pt;
  }
}

/* Loading animation */
.spinner-border-sm {
  width: 1rem;
  height: 1rem;
  border-width: 0.2em;
}

/* Badge styles */
.badge {
  padding: 0.35em 0.65em;
  font-weight: 500;
}

/* GPS Modal Styles */
.info-card {
  background: #f8f9fa;
  padding: 15px;
  border-radius: 8px;
  margin-bottom: 15px;
}

.info-card label {
  display: block;
  margin-bottom: 5px;
}

.gps-result {
  animation: fadeIn 0.5s;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* Botón de GPS verde */
.btn-success {
  background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
  border: none;
}

.btn-success:hover {
  background: linear-gradient(135deg, #218838 0%, #1aa179 100%);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(40, 167, 69, 0.4);
}

/* Botón info */
.btn-info {
  background: linear-gradient(135deg, #17a2b8 0%, #138496 100%);
  border: none;
  color: white;
}

.btn-info:hover {
  background: linear-gradient(135deg, #138496 0%, #117a8b 100%);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(23, 162, 184, 0.4);
}

.btn-outline-info {
  border-color: #17a2b8;
  color: #17a2b8;
}

.btn-outline-info:hover {
  background-color: #17a2b8;
  border-color: #17a2b8;
  color: white;
}

/* Spinner personalizado */
.spinner-border {
  animation: spinner-border .75s linear infinite;
}

@keyframes spinner-border {
  to {
    transform: rotate(360deg);
  }
}

/* Vista del mapa en modal */
.modal-body iframe {
  box-shadow: 0 2px 8px rgba(0,0,0,0.15);
}
</style>