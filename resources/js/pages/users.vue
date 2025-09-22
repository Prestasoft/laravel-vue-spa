<template>
  <div class="container">
    <div class="card">
      <div class="card-header d-flex justify-content-between align-items-center">
        <h5>Administración de Usuarios</h5>
        <button class="btn btn-primary" @click="showCreateModal">
          <fa icon="plus" fixed-width /> Nuevo Usuario
        </button>
      </div>
      <div class="card-body">
        <div class="row mb-3">
          <div class="col-md-6">
            <div class="input-group">
              <input
                type="text"
                class="form-control"
                placeholder="Buscar usuario..."
                v-model="search"
                @keyup.enter="fetchUsers"
              />
              <button class="btn btn-outline-secondary" @click="fetchUsers">
                <fa icon="search" fixed-width />
              </button>
            </div>
          </div>
          <div class="col-md-3 ms-auto">
            <select class="form-select" v-model="perPage" @change="fetchUsers">
              <option value="5">5 por página</option>
              <option value="10">10 por página</option>
              <option value="20">20 por página</option>
              <option value="50">50 por página</option>
            </select>
          </div>
        </div>

        <div class="table-responsive">
          <table class="table table-striped table-hover">
            <thead>
              <tr>
                <th>Nombre</th>
                <th>Email</th>
                <th>Tipo</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="user in users.data" :key="user.id">
                <td>{{ user.name }}</td>
                <td>{{ user.email }}</td>
                <td>
                  <span class="badge" :class="parseInt(user.type) === 1 ? 'bg-primary' : 'bg-secondary'">
                    {{ parseInt(user.type) === 1 ? 'Administrador' : 'Invitado' }}
                  </span>
                </td>
                <td>
                  <button
                    class="btn btn-sm btn-outline-primary me-1"
                    @click="showEditModal(user)"
                    title="Editar"
                  >
                    <fa icon="edit" fixed-width />
                  </button>
                  <button
                    class="btn btn-sm btn-outline-warning me-1"
                    @click="showChangePasswordModal(user)"
                    title="Cambiar contraseña"
                  >
                    <fa icon="key" fixed-width />
                  </button>
                  <button
                    class="btn btn-sm btn-outline-danger"
                    @click="confirmDelete(user)"
                    title="Eliminar"
                  >
                    <fa icon="trash" fixed-width />
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <div class="row">
          <div class="col-md-6">
            <p>
              Mostrando del {{ users.from }} al {{ users.to }} de
              {{ users.total }} registros
            </p>
          </div>
          <div class="col-md-6">
            <nav aria-label="Page navigation">
              <ul class="pagination justify-content-end">
                <li
                  class="page-item"
                  :class="{ disabled: !users.prev_page_url }"
                >
                  <button
                    class="page-link"
                    @click="fetchUsers(users.current_page - 1)"
                    :disabled="!users.prev_page_url"
                  >
                    Anterior
                  </button>
                </li>
                <li
                  v-for="page in users.last_page"
                  :key="page"
                  class="page-item"
                  :class="{ active: page === users.current_page }"
                >
                  <button class="page-link" @click="fetchUsers(page)">
                    {{ page }}
                  </button>
                </li>
                <li
                  class="page-item"
                  :class="{ disabled: !users.next_page_url }"
                >
                  <button
                    class="page-link"
                    @click="fetchUsers(users.current_page + 1)"
                    :disabled="!users.next_page_url"
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

    <div
      class="modal fade"
      id="userModal"
      tabindex="-1"
      aria-hidden="true"
      ref="userModal"
    >
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">
              {{ isEditMode ? "Editar Usuario" : "Nuevo Usuario" }}
            </h5>
            <button
              type="button"
              class="btn-close"
              data-bs-dismiss="modal"
              aria-label="Close"
            ></button>
          </div>
          <div class="modal-body">
            <form @submit.prevent="isEditMode ? updateUser() : createUser()">
              <div class="mb-3">
                <label for="name" class="form-label">Nombre</label>
                <input
                  type="text"
                  class="form-control"
                  id="name"
                  v-model="form.name"
                  required
                />
              </div>
              <div class="mb-3">
                <label for="email" class="form-label">Email</label>
                <input
                  type="email"
                  class="form-control"
                  id="email"
                  v-model="form.email"
                  required
                />
              </div>
              <div class="mb-3" v-if="!isEditMode">
                <label for="password" class="form-label">Contraseña</label>
                <input
                  type="password"
                  class="form-control"
                  id="password"
                  v-model="form.password"
                  required
                />
              </div>
              <div class="mb-3" v-if="!isEditMode">
                <label for="password_confirmation" class="form-label"
                  >Confirmar Contraseña</label
                >
                <input
                  type="password"
                  class="form-control"
                  id="password_confirmation"
                  v-model="form.password_confirmation"
                  required
                />
              </div>
              <div class="mb-3">
                <label for="type" class="form-label">Tipo de Usuario</label>
                <select class="form-select" id="type" v-model="form.type" required>
                  <option value="1">Administrador</option>
                  <option value="2">Invitado</option>
                </select>
              </div>
              <div class="modal-footer">
                <button
                  type="button"
                  class="btn btn-secondary"
                  data-bs-dismiss="modal"
                >
                  Cancelar
                </button>
                <button type="submit" class="btn btn-primary">
                  {{ isEditMode ? "Actualizar" : "Guardar" }}
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>

    <div
      class="modal fade"
      id="changePasswordModal"
      tabindex="-1"
      aria-hidden="true"
      ref="changePasswordModal"
    >
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Cambiar Contraseña</h5>
            <button
              type="button"
              class="btn-close"
              data-bs-dismiss="modal"
              aria-label="Close"
            ></button>
          </div>
          <div class="modal-body">
            <form @submit.prevent="changePassword">
              <div class="mb-3">
                <label for="new_password" class="form-label"
                  >Nueva Contraseña</label
                >
                <input
                  type="password"
                  class="form-control"
                  id="new_password"
                  v-model="passwordForm.password"
                  required
                />
              </div>
              <div class="mb-3">
                <label for="new_password_confirmation" class="form-label"
                  >Confirmar Nueva Contraseña</label
                >
                <input
                  type="password"
                  class="form-control"
                  id="new_password_confirmation"
                  v-model="passwordForm.password_confirmation"
                  required
                />
              </div>
              <div class="modal-footer">
                <button
                  type="button"
                  class="btn btn-secondary"
                  data-bs-dismiss="modal"
                >
                  Cancelar
                </button>
                <button type="submit" class="btn btn-primary">
                  Cambiar Contraseña
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
import Swal from 'sweetalert2';
import { Modal } from 'bootstrap/dist/js/bootstrap.bundle.min.js';

export default {
  data() {
    return {
      users: {
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
      perPage: 10,
      isEditMode: false,
      selectedUser: null,
      form: {
        name: "",
        email: "",
        password: "",
        password_confirmation: "",
        type: 2,
      },
      passwordForm: {
        password: "",
        password_confirmation: "",
      },
      userModal: null,
      changePasswordModal: null,
    };
  },
  mounted() {
    this.userModalElement = document.getElementById('userModal');
    this.changePasswordModalElement = document.getElementById('changePasswordModal');
    
    this.userModal = new Modal(this.userModalElement);
    this.changePasswordModal = new Modal(this.changePasswordModalElement);
    
    this.fetchUsers();
  },
  methods: {
    fetchUsers(page = 1) {
      const params = {
        page: page,
        per_page: this.perPage,
        search: this.search || null,
      };

      const cleanParams = Object.fromEntries(
        Object.entries(params).filter(([_, v]) => v !== null)
      );

      axios.get("/api/users", { params: cleanParams })
        .then((response) => {
          this.users = response.data;
        })
        .catch((error) => {
          console.error(error);
          this.showError("Error al cargar los usuarios");
        });
    },
    showCreateModal() {
      this.isEditMode = false;
      this.resetForm();
      this.userModal.show();
    },
    showEditModal(user) {
      this.isEditMode = true;
      this.selectedUser = user;
      this.form = {
        name: user.name,
        email: user.email,
        password: "",
        password_confirmation: "",
        type: user.type,
      };
      this.userModal.show();
    },
    showChangePasswordModal(user) {
      this.selectedUser = user;
      this.passwordForm = {
        password: "",
        password_confirmation: "",
      };
      this.changePasswordModal.show();
    },
    createUser() {
      axios.post("/api/users", this.form)
        .then((response) => {
          this.showSuccess("Usuario creado exitosamente");
          this.userModal.hide();
          this.fetchUsers();
        })
        .catch((error) => {
          console.error(error);
          if (error.response && error.response.data.errors) {
            let errorMessage = Object.values(error.response.data.errors).join('\n');
            this.showError(errorMessage);
          } else {
            this.showError("Error al crear el usuario");
          }
        });
    },
    updateUser() {
      axios.put(`/api/users/${this.selectedUser.id}`, this.form)
        .then((response) => {
          this.showSuccess("Usuario actualizado exitosamente");
          this.userModal.hide();
          this.fetchUsers();
        })
        .catch((error) => {
          console.error(error);
          if (error.response && error.response.data.errors) {
            let errorMessage = Object.values(error.response.data.errors).join('\n');
            this.showError(errorMessage);
          } else {
            this.showError("Error al actualizar el usuario");
          }
        });
    },
    changePassword() {
      axios.post(`/api/users/${this.selectedUser.id}/change-password`, this.passwordForm)
        .then((response) => {
          this.showSuccess("Contraseña cambiada exitosamente");
          this.changePasswordModal.hide();
        })
        .catch((error) => {
          console.error(error);
          if (error.response && error.response.data.errors) {
            let errorMessage = Object.values(error.response.data.errors).join('\n');
            this.showError(errorMessage);
          } else {
            this.showError("Error al cambiar la contraseña");
          }
        });
    },
    confirmDelete(user) {
      Swal.fire({
        title: '¿Estás seguro?',
        text: "¡No podrás revertir esto!",
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Sí, eliminarlo',
        cancelButtonText: 'Cancelar'
      }).then((result) => {
        if (result.isConfirmed) {
          this.deleteUser(user);
        }
      });
    },
    deleteUser(user) {
      axios.delete(`/api/users/${user.id}`)
        .then((response) => {
          this.showSuccess("Usuario eliminado exitosamente");
          this.fetchUsers();
        })
        .catch((error) => {
          console.error(error);
          this.showError("Error al eliminar el usuario");
        });
    },
    resetForm() {
      this.form = {
        name: "",
        email: "",
        password: "",
        password_confirmation: "",
        type: 2,
      };
    },
    showSuccess(message) {
      Swal.fire({
        icon: 'success',
        title: 'Éxito',
        text: message,
        timer: 2000,
        showConfirmButton: false
      });
    },
    showError(message) {
      Swal.fire({
        icon: 'error',
        title: 'Error',
        text: message,
      });
    }
  },
};
</script>

<style scoped>
.badge {
  font-size: 0.875em;
}

.btn-sm {
  padding: 0.25rem 0.5rem;
}

.page-item.disabled .page-link {
  pointer-events: none;
  opacity: 0.6;
}
</style>