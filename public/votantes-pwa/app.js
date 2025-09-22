// Configuración de la aplicación
const API_URL = window.location.hostname === 'localhost'
    ? 'http://localhost/app/api'
    : 'http://198.100.150.217/api';  // Tu API real funcionando

class VotantesApp {
    constructor() {
        this.token = localStorage.getItem('token');
        this.user = null;
        this.votantes = [];
        this.currentPage = 1;
        this.totalPages = 1;
        this.colegios = [];
        this.currentCedula = null;
        this.init();
    }

    init() {
        if (this.token) {
            this.checkAuth();
        } else {
            this.showScreen('loginScreen');
        }
        this.attachEventListeners();
    }

    attachEventListeners() {
        // Login form
        document.getElementById('loginForm').addEventListener('submit', (e) => {
            e.preventDefault();
            this.login();
        });

        // Buscar en padrón
        document.getElementById('buscarPadronForm').addEventListener('submit', (e) => {
            e.preventDefault();
            this.buscarEnPadron();
        });

        // Agregar votante
        document.getElementById('agregarVotanteForm').addEventListener('submit', (e) => {
            e.preventDefault();
            this.agregarVotante();
        });

        // Search
        document.getElementById('searchInput').addEventListener('keypress', (e) => {
            if (e.key === 'Enter') {
                this.searchVotantes();
            }
        });
    }

    async checkAuth() {
        try {
            const response = await this.apiCall('/user');
            if (response.ok) {
                this.user = await response.json();
                this.showMainApp();
            } else {
                this.showScreen('loginScreen');
            }
        } catch (error) {
            this.showScreen('loginScreen');
        }
    }

    async login() {
        const email = document.getElementById('email').value;
        const password = document.getElementById('password').value;

        this.showLoading('loginBtnText', 'loginLoader');

        try {
            const response = await fetch(`${API_URL}/login`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json',
                },
                body: JSON.stringify({ email, password })
            });

            // Verificar si la respuesta es JSON
            const contentType = response.headers.get("content-type");
            if (!contentType || !contentType.includes("application/json")) {
                console.error('API Error: La respuesta no es JSON. Posible problema de ruta.');
                this.showToast('Error: La API no está configurada correctamente', 'error');
                return;
            }

            const data = await response.json();

            if (response.ok) {
                this.token = data.access_token;
                this.user = data.user;
                localStorage.setItem('token', this.token);
                this.showMainApp();
            } else {
                this.showToast(data.message || 'Error al iniciar sesión', 'error');
            }
        } catch (error) {
            console.error('Login error:', error);
            this.showToast('Error de conexión con el servidor', 'error');
        } finally {
            this.hideLoading('loginBtnText', 'loginLoader');
        }
    }

    async logout() {
        try {
            await this.apiCall('/logout', 'POST');
        } catch (error) {
            // Ignorar errores
        }
        localStorage.removeItem('token');
        this.token = null;
        this.user = null;
        window.location.reload();
    }

    showMainApp() {
        document.getElementById('userName').textContent = this.user.name;
        this.showScreen('mainApp');
        this.loadVotantes();
        this.loadColegios();
        this.loadEstadisticas();
    }

    async loadVotantes(reset = false) {
        if (reset) {
            this.currentPage = 1;
            this.votantes = [];
        }

        try {
            const search = document.getElementById('searchInput').value;
            const params = new URLSearchParams({
                page: this.currentPage,
                per_page: 20,
                ...(search && { search })
            });

            const response = await this.apiCall(`/votantes?${params}`);
            const data = await response.json();

            if (reset) {
                this.votantes = data.data;
            } else {
                this.votantes = [...this.votantes, ...data.data];
            }

            this.totalPages = data.last_page;
            this.renderVotantes();

            const loadMoreBtn = document.getElementById('loadMoreBtn');
            if (this.currentPage < this.totalPages) {
                loadMoreBtn.classList.remove('d-none');
            } else {
                loadMoreBtn.classList.add('d-none');
            }
        } catch (error) {
            this.showToast('Error al cargar votantes', 'error');
        }
    }

    renderVotantes() {
        const container = document.getElementById('votantesList');

        if (this.votantes.length === 0) {
            container.innerHTML = `
                <div class="text-center py-5">
                    <i class="bi bi-people text-muted" style="font-size: 4rem;"></i>
                    <p class="text-muted mt-3">No hay votantes registrados</p>
                    <button class="btn btn-primary" onclick="app.switchTab('agregar')">
                        <i class="bi bi-person-plus"></i> Agregar el primero
                    </button>
                </div>
            `;
            return;
        }

        container.innerHTML = this.votantes.map(votante => `
            <div class="votante-card">
                <div class="d-flex align-items-center">
                    <div class="votante-avatar ${votante.activo ? 'bg-success' : 'bg-secondary'}">
                        ${this.getNombreCompleto(votante).charAt(0).toUpperCase()}
                    </div>
                    <div class="flex-grow-1 ms-3">
                        <h6 class="mb-0">${this.getNombreCompleto(votante)}</h6>
                        <small class="text-muted">Cédula: ${votante.cedula}</small>
                        ${votante.telefono ? `<br><small>Tel: ${votante.telefono}</small>` : ''}
                        ${votante.colegio_nombre ? `<br><small>Colegio: ${votante.colegio_nombre}</small>` : ''}
                        ${votante.mesa ? `<br><small>Mesa: ${votante.mesa}</small>` : ''}
                    </div>
                    <div class="text-end">
                        <span class="badge ${votante.activo ? 'bg-success' : 'bg-secondary'}">
                            ${votante.activo ? 'Activo' : 'Inactivo'}
                        </span>
                        <div class="mt-2">
                            <button class="btn btn-sm btn-outline-danger" onclick="app.eliminarVotante(${votante.id})">
                                <i class="bi bi-trash"></i>
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        `).join('');
    }

    getNombreCompleto(votante) {
        if (votante.padron_data) {
            return `${votante.padron_data.Nombres || ''} ${votante.padron_data.Apellido1 || ''} ${votante.padron_data.Apellido2 || ''}`.trim();
        }
        return 'Sin nombre';
    }

    async buscarEnPadron() {
        const cedula = document.getElementById('cedulaBuscar').value;

        if (cedula.length !== 11) {
            this.showToast('La cédula debe tener 11 dígitos', 'warning');
            return;
        }

        this.showLoadingOverlay();

        try {
            // Usar el endpoint /search que ya funciona en tu servidor
            const response = await this.apiCall(`/search?cedula=${cedula}`);
            const data = await response.json();

            if (response.ok && data.padron) {
                this.currentCedula = cedula;
                this.renderPadronResult({
                    padron: data.padron,
                    ya_registrado: false // Verificar si ya está en lista de votantes
                });
            } else {
                this.showToast(data.message || 'Cédula no encontrada', 'error');
                document.getElementById('padronResult').innerHTML = '';
                document.getElementById('agregarVotanteForm').classList.add('d-none');
            }
        } catch (error) {
            this.showToast('Error al buscar en padrón', 'error');
        } finally {
            this.hideLoadingOverlay();
        }
    }

    renderPadronResult(data) {
        const container = document.getElementById('padronResult');
        const form = document.getElementById('agregarVotanteForm');

        const alertClass = data.ya_registrado ? 'alert-warning' : 'alert-success';
        const icon = data.ya_registrado ? 'exclamation-triangle' : 'check-circle';
        const message = data.ya_registrado ? 'Ya está en tu lista' : 'Encontrado en el padrón';

        // Ajustar según la estructura de tu API real
        const padron = data.padron;
        const nombre = padron.Nombres || '';
        const apellido1 = padron.Apellido1 || '';
        const apellido2 = padron.Apellido2 || '';
        const sexo = padron.sexo || padron.Sexo || '';
        const colegio = padron.colegio || padron.Colegio || '';

        container.innerHTML = `
            <div class="alert ${alertClass} d-flex align-items-center">
                <i class="bi bi-${icon} me-2"></i>
                <div>
                    <strong>${message}</strong><br>
                    Nombre: ${nombre} ${apellido1} ${apellido2}<br>
                    ${sexo ? `Sexo: ${sexo}<br>` : ''}
                    ${colegio ? `Colegio: ${colegio}<br>` : ''}
                    ${padron.LugarNacimiento ? `Lugar de Nacimiento: ${padron.LugarNacimiento}<br>` : ''}
                </div>
            </div>
        `;

        if (!data.ya_registrado) {
            form.classList.remove('d-none');
            if (padron.IdColegio || padron.colegio_id) {
                document.getElementById('colegioSelect').value = padron.IdColegio || padron.colegio_id;
            }
        } else {
            form.classList.add('d-none');
        }
    }

    async agregarVotante() {
        if (!this.currentCedula) return;

        const votante = {
            cedula: this.currentCedula,
            colegio_id: document.getElementById('colegioSelect').value || null,
            mesa: document.getElementById('mesaInput').value || null,
            telefono: document.getElementById('telefonoInput').value || null,
            direccion: document.getElementById('direccionInput').value || null,
            observaciones: document.getElementById('observacionesInput').value || null
        };

        this.showLoadingOverlay();

        try {
            const response = await this.apiCall('/votantes', 'POST', votante);
            const data = await response.json();

            if (response.ok) {
                this.showToast('Votante agregado exitosamente', 'success');
                this.switchTab('votantes');
                this.loadVotantes(true);
                this.loadEstadisticas();
                this.resetAgregarForm();
            } else {
                this.showToast(data.message || 'Error al agregar votante', 'error');
            }
        } catch (error) {
            this.showToast('Error al agregar votante', 'error');
        } finally {
            this.hideLoadingOverlay();
        }
    }

    resetAgregarForm() {
        document.getElementById('buscarPadronForm').reset();
        document.getElementById('agregarVotanteForm').reset();
        document.getElementById('agregarVotanteForm').classList.add('d-none');
        document.getElementById('padronResult').innerHTML = '';
        this.currentCedula = null;
    }

    async eliminarVotante(id) {
        if (!confirm('¿Está seguro de eliminar este votante?')) return;

        try {
            const response = await this.apiCall(`/votantes/${id}`, 'DELETE');

            if (response.ok) {
                this.showToast('Votante eliminado', 'success');
                this.votantes = this.votantes.filter(v => v.id !== id);
                this.renderVotantes();
                this.loadEstadisticas();
            } else {
                this.showToast('Error al eliminar', 'error');
            }
        } catch (error) {
            this.showToast('Error al eliminar', 'error');
        }
    }

    async loadColegios() {
        try {
            const response = await this.apiCall('/colegios');
            this.colegios = await response.json();

            const select = document.getElementById('colegioSelect');
            select.innerHTML = '<option value="">Seleccione un colegio</option>' +
                this.colegios.map(c => `<option value="${c.id}">${c.nombre}</option>`).join('');
        } catch (error) {
            console.error('Error al cargar colegios:', error);
        }
    }

    async loadEstadisticas() {
        try {
            const response = await this.apiCall('/votantes/estadisticas');
            const stats = await response.json();

            document.getElementById('statTotal').textContent = stats.total || 0;
            document.getElementById('statActivos').textContent = stats.activos || 0;
            document.getElementById('statInactivos').textContent = stats.inactivos || 0;

            // Renderizar gráfico de colegios
            if (stats.por_colegio && stats.por_colegio.length > 0) {
                const container = document.getElementById('colegiosChart');
                container.innerHTML = stats.por_colegio.map(item => {
                    const percentage = ((item.total / stats.total) * 100).toFixed(1);
                    return `
                        <div class="mb-3">
                            <div class="d-flex justify-content-between mb-1">
                                <span>${item.colegio || 'Sin colegio'}</span>
                                <span>${item.total} (${percentage}%)</span>
                            </div>
                            <div class="progress">
                                <div class="progress-bar" style="width: ${percentage}%"></div>
                            </div>
                        </div>
                    `;
                }).join('');
            }
        } catch (error) {
            console.error('Error al cargar estadísticas:', error);
        }
    }

    async exportarVotantes() {
        try {
            const response = await this.apiCall('/votantes/exportar?formato=csv');
            const blob = await response.blob();
            const url = window.URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = 'votantes.csv';
            a.click();
            this.showToast('Lista exportada', 'success');
        } catch (error) {
            this.showToast('Error al exportar', 'error');
        }
    }

    searchVotantes() {
        this.loadVotantes(true);
    }

    loadMore() {
        this.currentPage++;
        this.loadVotantes();
    }

    switchTab(tabName) {
        // Update nav links
        document.querySelectorAll('.nav-link').forEach(link => {
            if (link.dataset.tab === tabName) {
                link.classList.add('active');
            } else {
                link.classList.remove('active');
            }
        });

        // Update tab panes
        document.querySelectorAll('.tab-pane').forEach(pane => {
            pane.classList.remove('active');
        });
        document.getElementById(`${tabName}Tab`).classList.add('active');

        // Load data if needed
        if (tabName === 'estadisticas') {
            this.loadEstadisticas();
        }
    }

    // Utility functions
    showScreen(screenId) {
        document.querySelectorAll('.screen').forEach(screen => {
            screen.classList.remove('active');
        });
        document.getElementById(screenId).classList.add('active');
    }

    showToast(message, type = 'info') {
        const toast = document.getElementById('toast');
        const toastMessage = document.getElementById('toastMessage');

        toast.className = `toast text-bg-${type === 'error' ? 'danger' : type === 'success' ? 'success' : type === 'warning' ? 'warning' : 'primary'}`;
        toastMessage.textContent = message;

        const bsToast = new bootstrap.Toast(toast);
        bsToast.show();
    }

    showLoading(textId, loaderId) {
        document.getElementById(textId).classList.add('d-none');
        document.getElementById(loaderId).classList.remove('d-none');
    }

    hideLoading(textId, loaderId) {
        document.getElementById(textId).classList.remove('d-none');
        document.getElementById(loaderId).classList.add('d-none');
    }

    showLoadingOverlay() {
        document.getElementById('loadingOverlay').classList.remove('d-none');
    }

    hideLoadingOverlay() {
        document.getElementById('loadingOverlay').classList.add('d-none');
    }

    async apiCall(endpoint, method = 'GET', body = null) {
        const options = {
            method,
            headers: {
                'Authorization': `Bearer ${this.token}`,
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            }
        };

        if (body && method !== 'GET') {
            options.body = JSON.stringify(body);
        }

        return fetch(`${API_URL}${endpoint}`, options);
    }
}

// Inicializar la aplicación
const app = new VotantesApp();