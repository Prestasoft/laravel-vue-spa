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
                  <span class="badge" :class="getUserTypeBadgeClass(user.type)">
                    <i class="bi" :class="getUserTypeIcon(user.type)" ></i> {{ getUserTypeName(user.type) }}
                  </span>
                  <span v-if="user.type == 3" class="ms-2 text-muted">
                    <small>({{ user.votantes_count || 0 }} votantes)</small>
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
                    v-if="currentUserType === 1"
                    class="btn btn-sm btn-outline-info me-1"
                    @click="showPermissionsModal(user)"
                    title="Editar permisos"
                  >
                    <fa icon="shield-alt" fixed-width />
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
              <div class="mb-3" v-if="!isEditMode">
                <label for="cedula" class="form-label">Cédula</label>
                <div class="input-group">
                  <input
                    type="text"
                    class="form-control"
                    id="cedula"
                    v-model="form.cedula"
                    placeholder="00000000000"
                    maxlength="11"
                    @input="form.cedula = form.cedula.replace(/[^0-9]/g, '')"
                  />
                  <button
                    type="button"
                    class="btn btn-outline-secondary"
                    @click="buscarPorCedula"
                    :disabled="!form.cedula || form.cedula.length < 11"
                  >
                    <fa icon="search" /> Buscar
                  </button>
                </div>
                <small v-if="cedulaMessage" :class="cedulaMessageClass">
                  {{ cedulaMessage }}
                </small>
              </div>

              <div v-show="fotoPreview" class="mb-3 text-center">
                <img
                  :src="fotoPreview"
                  alt="Foto del padrón"
                  class="rounded-circle"
                  style="width: 100px; height: 100px; object-fit: cover;"
                  @error="handleImageError"
                />
                <p class="text-muted small mt-2">Foto del padrón</p>
              </div>

              <div class="mb-3">
                <label for="name" class="form-label">Nombre</label>
                <input
                  type="text"
                  class="form-control"
                  id="name"
                  v-model="form.name"
                  required
                  :readonly="nombreReadonly"
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
                  <option v-if="currentUserType === 1" value="1">Administrador</option>
                  <option v-if="currentUserType === 1" value="4">Candidato</option>
                  <option value="3">Coordinador</option>
                  <option v-if="currentUserType === 1" value="2">Invitado</option>
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

    <!-- Modal de Permisos -->
    <div
      class="modal fade"
      id="permissionsModal"
      tabindex="-1"
      aria-hidden="true"
      ref="permissionsModal"
    >
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">
              <fa icon="shield-alt" /> Editar Permisos - {{ selectedUser ? selectedUser.name : '' }}
            </h5>
            <button
              type="button"
              class="btn-close"
              data-bs-dismiss="modal"
              aria-label="Close"
            ></button>
          </div>
          <div class="modal-body">
            <div v-if="permissions">
              <h6 class="text-primary mb-3"><i class="bi bi-people-fill"></i> Permisos de Votantes</h6>
              <div class="row mb-4">
                <div class="col-md-6 mb-2">
                  <div class="form-check form-switch">
                    <input
                      class="form-check-input"
                      type="checkbox"
                      v-model="permissions.can_view_votantes"
                      id="can_view_votantes"
                    >
                    <label class="form-check-label" for="can_view_votantes">
                      Ver votantes
                    </label>
                  </div>
                </div>
                <div class="col-md-6 mb-2">
                  <div class="form-check form-switch">
                    <input
                      class="form-check-input"
                      type="checkbox"
                      v-model="permissions.can_add_votantes"
                      id="can_add_votantes"
                    >
                    <label class="form-check-label" for="can_add_votantes">
                      Agregar votantes
                    </label>
                  </div>
                </div>
                <div class="col-md-6 mb-2">
                  <div class="form-check form-switch">
                    <input
                      class="form-check-input"
                      type="checkbox"
                      v-model="permissions.can_edit_votantes"
                      id="can_edit_votantes"
                    >
                    <label class="form-check-label" for="can_edit_votantes">
                      Editar votantes
                    </label>
                  </div>
                </div>
                <div class="col-md-6 mb-2">
                  <div class="form-check form-switch">
                    <input
                      class="form-check-input"
                      type="checkbox"
                      v-model="permissions.can_delete_votantes"
                      id="can_delete_votantes"
                    >
                    <label class="form-check-label" for="can_delete_votantes">
                      Eliminar votantes
                    </label>
                  </div>
                </div>
              </div>

              <h6 class="text-primary mb-3"><i class="bi bi-person-badge-fill"></i> Permisos de Usuarios</h6>
              <div class="row mb-4">
                <div class="col-md-6 mb-2">
                  <div class="form-check form-switch">
                    <input
                      class="form-check-input"
                      type="checkbox"
                      v-model="permissions.can_view_users"
                      id="can_view_users"
                    >
                    <label class="form-check-label" for="can_view_users">
                      Ver usuarios
                    </label>
                  </div>
                </div>
                <div class="col-md-6 mb-2">
                  <div class="form-check form-switch">
                    <input
                      class="form-check-input"
                      type="checkbox"
                      v-model="permissions.can_add_users"
                      id="can_add_users"
                    >
                    <label class="form-check-label" for="can_add_users">
                      Crear usuarios
                    </label>
                  </div>
                </div>
                <div class="col-md-6 mb-2">
                  <div class="form-check form-switch">
                    <input
                      class="form-check-input"
                      type="checkbox"
                      v-model="permissions.can_edit_users"
                      id="can_edit_users"
                    >
                    <label class="form-check-label" for="can_edit_users">
                      Editar usuarios
                    </label>
                  </div>
                </div>
                <div class="col-md-6 mb-2">
                  <div class="form-check form-switch">
                    <input
                      class="form-check-input"
                      type="checkbox"
                      v-model="permissions.can_delete_users"
                      id="can_delete_users"
                    >
                    <label class="form-check-label" for="can_delete_users">
                      Eliminar usuarios
                    </label>
                  </div>
                </div>
              </div>

              <h6 class="text-primary mb-3"><i class="bi bi-graph-up"></i> Permisos de Reportes</h6>
              <div class="row mb-4">
                <div class="col-md-6 mb-2">
                  <div class="form-check form-switch">
                    <input
                      class="form-check-input"
                      type="checkbox"
                      v-model="permissions.can_view_reports"
                      id="can_view_reports"
                    >
                    <label class="form-check-label" for="can_view_reports">
                      Ver reportes
                    </label>
                  </div>
                </div>
                <div class="col-md-6 mb-2">
                  <div class="form-check form-switch">
                    <input
                      class="form-check-input"
                      type="checkbox"
                      v-model="permissions.can_export_data"
                      id="can_export_data"
                    >
                    <label class="form-check-label" for="can_export_data">
                      Exportar datos
                    </label>
                  </div>
                </div>
              </div>

              <h6 class="text-primary mb-3"><i class="bi bi-star-fill"></i> Permisos Especiales</h6>
              <div class="row">
                <div class="col-md-6 mb-2">
                  <div class="form-check form-switch">
                    <input
                      class="form-check-input"
                      type="checkbox"
                      v-model="permissions.can_view_all_votantes"
                      id="can_view_all_votantes"
                    >
                    <label class="form-check-label" for="can_view_all_votantes">
                      Ver todos los votantes
                    </label>
                  </div>
                </div>
                <div class="col-md-6 mb-2">
                  <div class="form-check form-switch">
                    <input
                      class="form-check-input"
                      type="checkbox"
                      v-model="permissions.can_manage_coordinadores"
                      id="can_manage_coordinadores"
                    >
                    <label class="form-check-label" for="can_manage_coordinadores">
                      Gestionar coordinadores
                    </label>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button
              type="button"
              class="btn btn-secondary"
              data-bs-dismiss="modal"
            >
              Cancelar
            </button>
            <button
              type="button"
              class="btn btn-primary"
              @click="updatePermissions"
            >
              <fa icon="save" /> Guardar Permisos
            </button>
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
      currentUserType: null,
      form: {
        name: "",
        email: "",
        cedula: "",
        password: "",
        password_confirmation: "",
        type: 3,  // Por defecto dirigente para candidatos
      },
      passwordForm: {
        password: "",
        password_confirmation: "",
      },
      userModal: null,
      changePasswordModal: null,
      permissionsModal: null,
      cedulaMessage: "",
      cedulaMessageClass: "",
      fotoPreview: null,
      nombreReadonly: false,
      permissions: null,
    };
  },
  mounted() {
    this.userModalElement = document.getElementById('userModal');
    this.changePasswordModalElement = document.getElementById('changePasswordModal');
    this.permissionsModalElement = document.getElementById('permissionsModal');

    this.userModal = new Modal(this.userModalElement);
    this.changePasswordModal = new Modal(this.changePasswordModalElement);
    this.permissionsModal = new Modal(this.permissionsModalElement);

    this.getCurrentUser();
    this.fetchUsers();
  },
  methods: {
    async getCurrentUser() {
      try {
        const response = await axios.get('/user');
        this.currentUserType = parseInt(response.data.type);
      } catch (error) {
        console.error('Error getting current user:', error);
      }
    },
    fetchUsers(page = 1) {
      const params = {
        page: page,
        per_page: this.perPage,
        search: this.search || null,
      };

      const cleanParams = Object.fromEntries(
        Object.entries(params).filter(([_, v]) => v !== null)
      );

      console.log('Fetching users with params:', cleanParams);

      axios.get("/users", { params: cleanParams })
        .then((response) => {
          console.log('Users response:', response.data);
          this.users = response.data;
        })
        .catch((error) => {
          console.error('Error fetching users:', error);
          if (error.response) {
            console.error('Response data:', error.response.data);
            console.error('Response status:', error.response.status);
          }
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
      axios.post("/users", this.form)
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
      axios.put(`/users/${this.selectedUser.id}`, this.form)
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
      axios.post(`/users/${this.selectedUser.id}/change-password`, this.passwordForm)
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
      axios.delete(`/users/${user.id}`)
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
        cedula: "",
        password: "",
        password_confirmation: "",
        type: this.currentUserType === 4 ? 3 : 2,
      };
      this.cedulaMessage = "";
      this.cedulaMessageClass = "";
      this.fotoPreview = null;
      this.nombreReadonly = false;
    },
    async buscarPorCedula() {
      if (!this.form.cedula || this.form.cedula.length < 11) {
        this.showError("Por favor ingrese una cédula válida de 11 dígitos");
        return;
      }

      try {
        const response = await axios.post('/users/search-cedula', {
          cedula: this.form.cedula
        });

        if (response.data.padron) {
          this.form.name = response.data.padron.nombre_completo;
          this.nombreReadonly = true;
          this.cedulaMessage = "Datos encontrados en el padrón";
          this.cedulaMessageClass = "text-success";

          if (response.data.has_photo) {
            // La foto se cargará cuando se guarde el usuario
            this.fotoPreview = `/api/users/photo-temp/${this.form.cedula}?t=${Date.now()}`;
            console.log('Photo URL set:', this.fotoPreview);
          } else {
            this.fotoPreview = null;
          }
        }
      } catch (error) {
        if (error.response && error.response.status === 422) {
          this.cedulaMessage = error.response.data.error;
          this.cedulaMessageClass = "text-danger";
          if (error.response.data.user) {
            this.showError(`Ya existe un usuario con esta cédula: ${error.response.data.user.name}`);
          }
        } else if (error.response && error.response.status === 404) {
          this.cedulaMessage = "Cédula no encontrada en el padrón";
          this.cedulaMessageClass = "text-warning";
        } else {
          this.showError("Error al buscar la cédula");
        }
      }
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
    },
    getUserTypeName(type) {
      const types = {
        1: 'Administrador',
        2: 'Invitado',
        3: 'Coordinador',
        4: 'Candidato'
      };
      return types[type] || 'Usuario';
    },
    getUserTypeBadgeClass(type) {
      const classes = {
        1: 'bg-danger',
        2: 'bg-secondary',
        3: 'bg-primary',
        4: 'bg-success'
      };
      return classes[type] || 'bg-secondary';
    },
    getUserTypeIcon(type) {
      const icons = {
        1: 'bi-shield-lock',
        2: 'bi-person',
        3: 'bi-people',
        4: 'bi-star-fill'
      };
      return icons[type] || 'bi-person';
    },
    handleImageError() {
      console.log('Error loading image, using default');
      this.fotoPreview = null;
    },
    showPermissionsModal(user) {
      this.selectedUser = user;
      // Cargar permisos actuales del usuario
      this.permissions = {
        can_view_votantes: user.can_view_votantes ?? true,
        can_add_votantes: user.can_add_votantes ?? true,
        can_edit_votantes: user.can_edit_votantes ?? true,
        can_delete_votantes: user.can_delete_votantes ?? true,
        can_view_users: user.can_view_users ?? false,
        can_add_users: user.can_add_users ?? false,
        can_edit_users: user.can_edit_users ?? false,
        can_delete_users: user.can_delete_users ?? false,
        can_view_reports: user.can_view_reports ?? false,
        can_export_data: user.can_export_data ?? false,
        can_view_all_votantes: user.can_view_all_votantes ?? false,
        can_manage_coordinadores: user.can_manage_coordinadores ?? false,
      };
      this.permissionsModal.show();
    },
    async updatePermissions() {
      try {
        const response = await axios.post(`/users/${this.selectedUser.id}/permissions`, {
          permissions: this.permissions
        });

        this.showSuccess('Permisos actualizados exitosamente');
        this.permissionsModal.hide();
        this.fetchUsers();
      } catch (error) {
        console.error(error);
        this.showError('Error al actualizar permisos');
      }
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