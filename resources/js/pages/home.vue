<template>
  <div class="container my-5">
    <div class="row justify-content-center">
      <div class="col-lg-10">
        <div class="card shadow-sm">
          <div class="card-header bg-secondary text-white text-center">
            <h3>Búsqueda por Cédula</h3>
          </div>
          <div class="card-body">
            <!-- Input de búsqueda -->
            <div class="form-group mb-4">
              <label for="cedulaInput" class="form-label">Cédula</label>
              <input
                id="cedulaInput"
                v-model="cedula"
                type="text"
                class="form-control"
                placeholder="Ingresa la cédula"
              />
            </div>

            <!-- Botón de búsqueda -->
            <div class="d-grid">
              <button
                @click="searchPadron"
                class="btn btn-primary btn-lg"
                :disabled="loading"
              >
                <span v-if="loading" class="spinner-border spinner-border-sm me-2"></span>
                Buscar
              </button>
            </div>

            <!-- Mensaje de error -->
            <div v-if="error" class="alert alert-danger mt-4 text-center">
              {{ error }}
            </div>

            <!-- Resultados -->
            <div v-if="padron && foto" class="mt-5">
              <h4 class="text-center mb-4">Resultados de la Búsqueda</h4>
              
              <!-- Foto centrada -->
              <div class="text-center">
                <img
                  v-if="foto.Imagen"
                  :src="'data:image/jpeg;base64,' + foto.Imagen"
                  alt="Foto"
                  class="img-fluid rounded mb-4"
                  style="max-height: 300px;"
                />
                <p v-else class="text-muted">No se encontró foto</p>
              </div>

              <!-- Información del padrón -->
              <div class="row">
                <!-- Primera columna -->
                <div class="col-md-6">
                  <ul class="list-group">
                    <li class="list-group-item">
                      <strong>Cédula:</strong> {{ padron.Cedula }}
                    </li>
                    <li class="list-group-item">
                      <strong>Nombres:</strong> {{ padron.nombres }}
                    </li>
                    <li class="list-group-item">
                      <strong>Primer Apellido:</strong> {{ padron.apellido1 }}
                    </li>
                    <li class="list-group-item">
                      <strong>Segundo Apellido:</strong> {{ padron.apellido2 }}
                    </li>
                    <li class="list-group-item">
                      <strong>Fecha de Nacimiento:</strong> {{ formattedFechaNacimiento }}
                    </li>
                    <li class="list-group-item">
                      <strong>Sexo:</strong> {{ padron.sexo }}
                    </li>
                  </ul>
                </div>

                <!-- Segunda columna -->
                <div class="col-md-6">
                  <ul class="list-group">
                    <li class="list-group-item">
                      <strong>Nacionalidad:</strong> {{ padron.nacionalidad }}
                    </li>
                    <li class="list-group-item">
                      <strong>Estado Civil:</strong> {{ padron.estado_civil }}
                    </li>
                    <li class="list-group-item">
                      <strong>Colegio:</strong> {{ padron.colegio }}
                    </li>
                    <li class="list-group-item">
                      <strong>Municipio:</strong> {{ padron.municipio }}
                    </li>
                    <li class="list-group-item">
                      <strong>Provincia:</strong> {{ padron.provincia }}
                    </li>
                    <li class="list-group-item">
                      <strong>Zona:</strong> {{ padron.zona }}
                    </li>
                  </ul>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from "axios";
import dayjs from "dayjs";

export default {
  data() {
    return {
      cedula: "",
      loading: false,
      padron: null,
      foto: null,
      error: null,
    };
  },
  computed: {
    formattedFechaNacimiento() {
      if (this.padron?.FechaNacimiento) {
        return dayjs(this.padron.FechaNacimiento).format("YYYY/MM/DD");
      }
      return "No disponible";
    },
  },
  methods: {
    async searchPadron() {
      if (!this.cedula) {
        this.error = "Por favor, ingresa una cédula.";
        return;
      }

      this.loading = true;
      this.error = null;
      this.padron = null;
      this.foto = null;

      try {
        const response = await axios.get("/search", {
          params: { cedula: this.cedula },
        });
        this.padron = response.data.padron;
        this.foto = response.data.foto;
      } catch (error) {
        if (error.response && error.response.data.message) {
          this.error = error.response.data.message;
        } else {
          this.error = "Ocurrió un error al realizar la búsqueda.";
        }
      } finally {
        this.loading = false;
      }
    },
  },
};
</script>

<style>
.card {
  border-radius: 1rem;
}

.card-header {
  border-top-left-radius: 1rem;
  border-top-right-radius: 1rem;
}

.card-footer {
  border-bottom-left-radius: 1rem;
  border-bottom-right-radius: 1rem;
}

.img-fluid {
  object-fit: cover;
}
</style>
