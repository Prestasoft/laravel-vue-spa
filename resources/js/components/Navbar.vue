<template>
  <nav class="navbar navbar-expand-lg navbar-light bg-white">
    <div class="container">
      <router-link :to="{ name: user ? 'home' : 'welcome' }" class="navbar-brand">
        {{ appName }}
      </router-link>

      <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbar">
        <span class="navbar-toggler-icon" />
      </button>

      <div id="navbar" class="collapse navbar-collapse">
        <ul class="navbar-nav">
          <li class="nav-item" v-if="user && user.type != '3' && user.type != '4'">
            <router-link :to="{ name: 'home' }" class="nav-link" active-class="active">
              <i class="bi bi-search me-1"></i>
              Búsqueda
            </router-link>
          </li>
          <li class="nav-item" v-if="user">
            <router-link :to="{ name: 'votantes' }" class="nav-link" active-class="active">
              <i class="bi bi-people-fill me-1"></i>
              Votantes
            </router-link>
          </li>
          <li class="nav-item" v-if="user && (user.type == '1' || user.type == '3' || user.type == '4')">
            <router-link :to="{ name: 'mapa' }" class="nav-link" active-class="active">
              <i class="bi bi-map-fill me-1"></i>
              Mapa
            </router-link>
          </li>
          <li class="nav-item" v-if="user && user.type == '1'">
            <router-link :to="{ name: 'historials' }" class="nav-link" active-class="active">
              <i class="bi bi-clock-history me-1"></i>
              Historial
            </router-link>
          </li>
          <li class="nav-item" v-if="user && (user.type == '1' || user.type == '4')">
            <router-link :to="{ name: 'users' }" class="nav-link" active-class="active">
              <i class="bi bi-person-gear me-1"></i>
              Usuarios
            </router-link>
          </li>
        </ul>

        <ul class="navbar-nav ms-auto">
          <!-- Authenticated -->
          <li v-if="user" class="nav-item dropdown">
            <a class="nav-link dropdown-toggle d-flex align-items-center"
               href="#" @click.prevent="toggleDropdown"
            >
              <div class="user-profile d-flex align-items-center">
                <span :class="getUserTypeBadgeClass(user.type)" class="me-2">
                  <i :class="getUserTypeIcon(user.type)"></i>
                </span>
                <div class="user-info">
                  <span class="user-name">{{ user.name }}</span>
                  <small class="user-type d-block text-muted">{{ getUserTypeName(user.type) }}</small>
                </div>
              </div>
            </a>
            <div :class="['dropdown-menu', 'dropdown-menu-end', 'shadow-lg', { show: dropdownOpen }]"
                 style="position: absolute; right: 0;">
              <div class="dropdown-header bg-light">
                <div class="d-flex align-items-center">
                  <div class="user-avatar me-3">
                    <span :class="getUserTypeBadgeClass(user.type)" class="fs-3">
                      <i :class="getUserTypeIcon(user.type)"></i>
                    </span>
                  </div>
                  <div>
                    <div class="fw-bold">{{ user.name }}</div>
                    <small class="text-muted">{{ user.email }}</small>
                    <div>
                      <span :class="getUserTypeBadgeClass(user.type)" class="badge-sm mt-1">
                        {{ getUserTypeName(user.type) }}
                      </span>
                    </div>
                  </div>
                </div>
              </div>
              <div class="dropdown-divider" />
              <router-link :to="{ name: 'settings' }" class="dropdown-item" v-if="false">
                <i class="bi bi-gear me-2"></i>
                Configuración
              </router-link>
              <button class="dropdown-item text-danger" @click="logout">
                <i class="bi bi-box-arrow-right me-2"></i>
                Cerrar Sesión
              </button>
            </div>
          </li>
          <!-- Guest -->
          <template v-else>
            <li class="nav-item">
              <router-link :to="{ name: 'login' }" class="nav-link" active-class="active">
                Iniciar Sesión
              </router-link>
            </li>
          </template>
        </ul>
      </div>
    </div>
  </nav>
</template>

<script>
import { mapGetters } from 'vuex'
import LocaleDropdown from './LocaleDropdown'

export default {
  components: {
    LocaleDropdown
  },

  data: () => ({
    appName: window.config.appName,
    dropdownOpen: false
  }),

  computed: mapGetters({
    user: 'auth/user'
  }),

  mounted() {
    // Cerrar dropdown al hacer clic fuera
    document.addEventListener('click', this.handleOutsideClick)
  },

  beforeDestroy() {
    document.removeEventListener('click', this.handleOutsideClick)
  },

  methods: {
    toggleDropdown() {
      this.dropdownOpen = !this.dropdownOpen
    },
    handleOutsideClick(event) {
      const dropdown = this.$el.querySelector('.dropdown')
      if (dropdown && !dropdown.contains(event.target)) {
        this.dropdownOpen = false
      }
    },
    async logout () {
      try {
        // Log out the user.
        await this.$store.dispatch('auth/logout')

        // Redirect to login.
        this.$router.push({ name: 'login' })
      } catch (error) {
        console.error('Error durante el logout:', error)
        // Forzar redirección aunque haya error
        this.$router.push({ name: 'login' })
      }
    },
    getUserTypeName(type) {
      const types = {
        1: 'Administrador',
        2: 'Invitado',
        3: 'Dirigente',
        4: 'Candidato'
      };
      return types[type] || 'Usuario';
    },
    getUserTypeBadgeClass(type) {
      const classes = {
        1: 'badge bg-danger',
        2: 'badge bg-secondary',
        3: 'badge bg-primary',
        4: 'badge bg-success'
      };
      return classes[type] || 'badge bg-secondary';
    },
    getUserTypeIcon(type) {
      const icons = {
        1: 'bi-shield-lock',
        2: 'bi-person',
        3: 'bi-people',
        4: 'bi-star-fill'
      };
      return icons[type] || 'bi-person';
    }
  }
}
</script>

<style scoped>
.profile-photo {
  width: 2rem;
  height: 2rem;
  margin: -.375rem 0;
}

.container {
  max-width: 1100px;
}

.user-profile {
  cursor: pointer;
}

.user-info {
  line-height: 1.2;
}

.user-name {
  font-weight: 500;
  color: #333;
}

.user-type {
  font-size: 0.75rem;
  margin-top: -2px;
}

.dropdown {
  position: relative;
}

.dropdown-menu {
  min-width: 280px;
  border: 1px solid rgba(0, 0, 0, 0.1);
  margin-top: 10px;
  display: none;
}

.dropdown-menu.show {
  display: block !important;
}

.dropdown-header {
  padding: 15px;
  border-bottom: 1px solid #e9ecef;
}

.user-avatar {
  width: 50px;
  height: 50px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(0, 0, 0, 0.05);
  border-radius: 50%;
}

.dropdown-item {
  padding: 10px 20px;
  transition: all 0.3s ease;
}

.dropdown-item:hover {
  background-color: #f8f9fa;
  padding-left: 25px;
}

.dropdown-item.text-danger:hover {
  background-color: rgba(220, 53, 69, 0.1);
  color: #dc3545 !important;
}

.badge-sm {
  font-size: 0.75rem;
  padding: 0.25rem 0.5rem;
}

/* Asegurar que el dropdown funcione bien en móviles */
@media (max-width: 576px) {
  .dropdown-menu {
    width: 100%;
    margin-top: 5px;
  }

  .user-type {
    display: none !important;
  }
}
</style>
