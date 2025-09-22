<template>
  <div class="container">
    <div class="card">
      <div class="card-header">
        <h5>Historial de Búsquedas</h5>
      </div>
      <div class="card-body">
        <div class="row mb-3">
          <div class="col-md-6">
            <div class="input-group">
              <input
                type="text"
                class="form-control"
                placeholder="Buscar en historial..."
                v-model="search"
                @keyup.enter="fetchLogs"
              />
              <button class="btn btn-outline-secondary" @click="fetchLogs">
                <fa icon="search" fixed-width />
              </button>
            </div>
          </div>
          <div class="col-md-3 ms-auto">
            <select class="form-select" v-model="perPage" @change="fetchLogs">
              <option value="10">10 por página</option>
              <option value="25">25 por página</option>
              <option value="50">50 por página</option>
              <option value="100">100 por página</option>
            </select>
          </div>
        </div>

        <div class="table-responsive">
          <table class="table table-striped table-hover">
            <thead>
              <tr>
                <th>Fecha</th>
                <th>Usuario</th>
                <th>Búsqueda</th>
                <th>Resultados</th>
                <th>Duración</th>
                <th>IP</th>
                <th>Dispositivo</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="log in logs.data" :key="log.id">
                <td>{{ log.formatted_search_date }}</td>
                <td>
                  <span v-if="log.user">
                    {{ log.user.name }}
                  </span>
                  <span v-else class="text-muted">Anónimo</span>
                </td>
                <td>{{ log.SearchQuery }}</td>
                <td>
                  <span class="badge" :class="log.SearchResultCount > 0 ? 'bg-success' : 'bg-danger'">
                    {{ log.SearchResultCount }} resultado(s)
                  </span>
                </td>
                <td>{{ log.duration_seconds }}</td>
                <td>{{ log.IPAddress }}</td>
                <td>{{ truncateDeviceInfo(log.DeviceInfo) }}</td>
              </tr>
            </tbody>
          </table>
        </div>

        <div class="row">
          <div class="col-md-6">
            <p>
              Mostrando del {{ logs.from }} al {{ logs.to }} de
              {{ logs.total }} registros
            </p>
          </div>
          <div class="col-md-6">
            <nav aria-label="Page navigation">
              <ul class="pagination justify-content-end">
                <li class="page-item" :class="{ disabled: !logs.prev_page_url }">
                  <button
                    class="page-link"
                    @click="fetchLogs(logs.current_page - 1)"
                    :disabled="!logs.prev_page_url"
                  >
                    Anterior
                  </button>
                </li>
                <li
                  v-for="page in logs.last_page"
                  :key="page"
                  class="page-item"
                  :class="{ active: page === logs.current_page }"
                >
                  <button class="page-link" @click="fetchLogs(page)">
                    {{ page }}
                  </button>
                </li>
                <li class="page-item" :class="{ disabled: !logs.next_page_url }">
                  <button
                    class="page-link"
                    @click="fetchLogs(logs.current_page + 1)"
                    :disabled="!logs.next_page_url"
                  >
                    Siguiente
                  </button>
                </li>
              </ul>
            </nav>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';

export default {
  data() {
    return {
      logs: {
        data: [],
        current_page: 1,
        from: 1,
        to: 1,
        total: 0,
        last_page: 1,
        prev_page_url: null,
        next_page_url: null
      },
      search: "",
      perPage: 15,
    };
  },
  mounted() {
    this.fetchLogs();
  },
  methods: {
    fetchLogs(page = 1) {
      const params = {
        page: page,
        per_page: this.perPage,
        search: this.search || null,
      };

      // Limpiar parámetros vacíos
      const cleanParams = Object.fromEntries(
        Object.entries(params).filter(([_, v]) => v !== null)
      );

      axios.get("/api/search-logs", { params: cleanParams })
        .then((response) => {
          this.logs = response.data;
        })
        .catch((error) => {
          console.error(error);
          this.showError("Error al cargar el historial");
        });
    },
    truncateDeviceInfo(info) {
      if (!info) return '';
      return info.length > 30 ? info.substring(0, 30) + '...' : info;
    },
    showError(message) {
      this.$swal({
        icon: 'error',
        title: 'Error',
        text: message,
      });
    }
  }
};
</script>

<style scoped>
.badge {
  font-size: 0.875em;
}

.page-item.disabled .page-link {
  pointer-events: none;
  opacity: 0.6;
}
</style>