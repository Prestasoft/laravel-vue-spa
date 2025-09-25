<template>
  <div class="login-wrapper">
    <div class="login-container">
      <div class="login-background">
        <!-- Patrón de fondo con colores dominicanos -->
        <div class="flag-pattern">
          <div class="stripe stripe-red"></div>
          <div class="stripe stripe-white"></div>
          <div class="stripe stripe-blue"></div>
          <div class="stripe stripe-white"></div>
          <div class="stripe stripe-red"></div>
        </div>
        <div class="bg-overlay"></div>
      </div>

      <div class="login-content">
        <div class="login-card">
          <div class="login-header">
            <div class="logo-container">
              <div class="logo-circle">
                <i class="bi bi-shield-fill"></i>
              </div>
            </div>
            <h2 class="login-title">Sistema para Gestión de Votantes</h2>
            <p class="login-subtitle">República Dominicana</p>
            <div class="flag-divider">
              <span class="flag-line flag-line-red"></span>
              <span class="flag-line flag-line-white"></span>
              <span class="flag-line flag-line-blue"></span>
            </div>
          </div>

          <form @submit.prevent="login" @keydown="form.onKeydown($event)" class="login-form">
            <!-- Email -->
            <div class="form-group">
              <label class="form-label">
                <i class="bi bi-envelope-fill"></i>
                Correo Electrónico
              </label>
              <input
                v-model="form.email"
                :class="{ 'is-invalid': form.errors.has('email') }"
                class="form-control form-control-lg"
                type="email"
                name="email"
                placeholder="usuario@ejemplo.com"
                required
                autofocus
              >
              <has-error :form="form" field="email" />
            </div>

            <!-- Password -->
            <div class="form-group">
              <label class="form-label">
                <i class="bi bi-lock-fill"></i>
                Contraseña
              </label>
              <div class="password-input-container">
                <input
                  v-model="form.password"
                  :class="{ 'is-invalid': form.errors.has('password') }"
                  class="form-control form-control-lg"
                  :type="showPassword ? 'text' : 'password'"
                  name="password"
                  placeholder="••••••••"
                  required
                >
                <button
                  type="button"
                  class="password-toggle"
                  @click="showPassword = !showPassword"
                >
                  <i :class="showPassword ? 'bi bi-eye-slash' : 'bi bi-eye'"></i>
                </button>
              </div>
              <has-error :form="form" field="password" />
            </div>

            <!-- Remember Me & Forgot Password -->
            <div class="form-options">
              <div class="custom-control custom-checkbox">
                <input
                  v-model="remember"
                  type="checkbox"
                  class="form-check-input"
                  id="remember"
                  name="remember"
                >
                <label class="form-check-label" for="remember">
                  Recordarme
                </label>
              </div>
              <router-link :to="{ name: 'password.request' }" class="forgot-link">
                ¿Olvidó su contraseña?
              </router-link>
            </div>

            <!-- Submit Button -->
            <button
              type="submit"
              class="btn-login"
              :disabled="form.busy"
            >
              <span v-if="!form.busy">
                <i class="bi bi-box-arrow-in-right me-2"></i>
                Iniciar Sesión
              </span>
              <span v-else>
                <span class="spinner-border spinner-border-sm me-2"></span>
                Ingresando...
              </span>
            </button>

            <!-- User Type Badges -->
            <div class="user-types-info">
              <div class="info-badges">
                <span class="badge-type admin">
                  <i class="bi bi-shield-lock"></i> Admin
                </span>
                <span class="badge-type candidato">
                  <i class="bi bi-star-fill"></i> Candidato
                </span>
                <span class="badge-type dirigente">
                  <i class="bi bi-people"></i> Dirigente
                </span>
                <span class="badge-type guest">
                  <i class="bi bi-person"></i> Invitado
                </span>
              </div>
            </div>
          </form>

          <div class="login-footer">
            <div class="flag-icon-container">
              <div class="flag-icon">
                <div class="flag-stripe red"></div>
                <div class="flag-stripe white"></div>
                <div class="flag-stripe blue"></div>
                <div class="flag-stripe white"></div>
                <div class="flag-stripe red"></div>
              </div>
            </div>
            <p class="copyright">
              © {{ new Date().getFullYear() }} Sistema de Gestión de Votantes
              <br>
              <small>República Dominicana</small>
            </p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import Form from 'vform'
import Cookies from 'js-cookie'

export default {
  middleware: 'guest',

  metaInfo () {
    return { title: 'Iniciar Sesión - Sistema de Gestión de Votantes' }
  },

  data: () => ({
    form: new Form({
      email: '',
      password: ''
    }),
    remember: false,
    showPassword: false
  }),

  mounted() {
    // Ocultar el navbar cuando se monta este componente
    const navbar = document.querySelector('nav.navbar');
    if (navbar) {
      navbar.style.display = 'none';
    }
    // Agregar clase al body para estilos especiales
    document.body.classList.add('login-page');
  },

  beforeDestroy() {
    // Mostrar el navbar cuando se destruye este componente
    const navbar = document.querySelector('nav.navbar');
    if (navbar) {
      navbar.style.display = '';
    }
    // Remover clase del body
    document.body.classList.remove('login-page');
  },

  methods: {
    async login () {
      try {
        // Submit the form.
        const { data } = await this.form.post('/login')

        // Save the token.
        this.$store.dispatch('auth/saveToken', {
          token: data.token,
          remember: this.remember
        })

        // Fetch the user.
        await this.$store.dispatch('auth/fetchUser')

        // Redirect based on user type
        this.redirect()
      } catch (error) {
        console.error('Login error:', error)
      }
    },

    redirect () {
      const user = this.$store.getters['auth/user']
      const intendedUrl = Cookies.get('intended_url')

      if (intendedUrl) {
        Cookies.remove('intended_url')
        this.$router.push({ path: intendedUrl })
      } else {
        // Redirect based on user type
        if (user) {
          if (user.type == 3) { // Dirigente
            this.$router.push({ name: 'votantes' })
          } else {
            this.$router.push({ name: 'home' })
          }
        } else {
          this.$router.push({ name: 'home' })
        }
      }
    }
  }
}
</script>

<style>
/* Estilos globales cuando estamos en la página de login */
.login-page {
  overflow: hidden;
}

.login-page #app {
  height: 100vh;
}
</style>

<style scoped>
.login-wrapper {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: 9999;
}

.login-container {
  width: 100vw;
  height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  overflow: hidden;
}

.login-background {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  overflow: hidden;
}

.flag-pattern {
  position: absolute;
  width: 100%;
  height: 100%;
  display: flex;
  transform: rotate(-15deg) scale(1.5);
  opacity: 0.3;
}

.stripe {
  flex: 1;
  height: 100%;
}

.stripe-red {
  background: #CE1126;
}

.stripe-white {
  background: #FFFFFF;
}

.stripe-blue {
  background: #002D62;
}

.bg-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(135deg, rgba(0,45,98,0.95) 0%, rgba(206,17,38,0.95) 100%);
}

.login-content {
  position: relative;
  z-index: 1;
  width: 100%;
  max-width: 450px;
  padding: 20px;
}

.login-card {
  background: white;
  border-radius: 20px;
  box-shadow: 0 25px 60px rgba(0, 0, 0, 0.4);
  overflow: hidden;
  animation: slideUp 0.5s ease-out;
}

@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(40px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.login-header {
  text-align: center;
  padding: 40px 30px 30px;
  background: linear-gradient(135deg, #002D62 0%, #0052A5 100%);
  color: white;
  position: relative;
}

.logo-container {
  margin-bottom: 20px;
}

.logo-circle {
  width: 80px;
  height: 80px;
  background: white;
  border-radius: 50%;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  font-size: 35px;
  color: #CE1126;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
}

.login-title {
  font-size: 28px;
  font-weight: 700;
  margin-bottom: 5px;
  text-shadow: 2px 2px 4px rgba(0,0,0,0.2);
}

.login-subtitle {
  font-size: 16px;
  opacity: 0.95;
  margin-bottom: 15px;
}

.flag-divider {
  display: flex;
  justify-content: center;
  gap: 3px;
  margin-top: 15px;
}

.flag-line {
  height: 3px;
  width: 30px;
  border-radius: 2px;
}

.flag-line-red {
  background: #CE1126;
}

.flag-line-white {
  background: white;
}

.flag-line-blue {
  background: #FFD700;
}

.login-form {
  padding: 30px;
}

.form-group {
  margin-bottom: 25px;
}

.form-label {
  display: block;
  margin-bottom: 8px;
  font-weight: 600;
  color: #002D62;
  font-size: 14px;
}

.form-label i {
  margin-right: 5px;
  color: #CE1126;
}

.form-control {
  border: 2px solid #e1e8ed;
  border-radius: 10px;
  padding: 12px 15px;
  font-size: 15px;
  transition: all 0.3s;
  background: #f8f9fa;
}

.form-control:focus {
  border-color: #002D62;
  background: white;
  box-shadow: 0 0 0 0.2rem rgba(0, 45, 98, 0.1);
}

.form-control.is-invalid {
  border-color: #CE1126;
  background: #fff5f5;
}

.password-input-container {
  position: relative;
}

.password-toggle {
  position: absolute;
  right: 15px;
  top: 50%;
  transform: translateY(-50%);
  border: none;
  background: none;
  color: #6c757d;
  cursor: pointer;
  padding: 5px;
  transition: color 0.3s;
}

.password-toggle:hover {
  color: #002D62;
}

.form-options {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 25px;
  flex-wrap: wrap;
  gap: 10px;
}

.form-check-input {
  cursor: pointer;
  border-color: #002D62;
}

.form-check-input:checked {
  background-color: #CE1126;
  border-color: #CE1126;
}

.form-check-label {
  font-size: 14px;
  color: #6c757d;
  cursor: pointer;
  margin-left: 5px;
}

.forgot-link {
  font-size: 14px;
  color: #002D62;
  text-decoration: none;
  font-weight: 500;
  transition: color 0.3s;
}

.forgot-link:hover {
  color: #CE1126;
  text-decoration: underline;
}

.btn-login {
  width: 100%;
  padding: 14px;
  border: none;
  border-radius: 10px;
  font-size: 16px;
  font-weight: 600;
  color: white;
  background: linear-gradient(135deg, #CE1126 0%, #8B0000 100%);
  cursor: pointer;
  transition: all 0.3s;
  box-shadow: 0 4px 15px rgba(206, 17, 38, 0.3);
}

.btn-login:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(206, 17, 38, 0.4);
  background: linear-gradient(135deg, #8B0000 0%, #CE1126 100%);
}

.btn-login:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}

.user-types-info {
  margin-top: 25px;
  padding-top: 25px;
  border-top: 1px solid #e1e8ed;
}

.info-badges {
  display: flex;
  justify-content: center;
  gap: 10px;
  flex-wrap: wrap;
}

.badge-type {
  padding: 5px 12px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 600;
  display: inline-flex;
  align-items: center;
  gap: 5px;
}

.badge-type.admin {
  background: rgba(206, 17, 38, 0.1);
  color: #CE1126;
}

.badge-type.candidato {
  background: rgba(40, 167, 69, 0.1);
  color: #28a745;
}

.badge-type.dirigente {
  background: rgba(0, 45, 98, 0.1);
  color: #002D62;
}

.badge-type.guest {
  background: rgba(108, 117, 125, 0.1);
  color: #6c757d;
}

.login-footer {
  padding: 20px;
  background: #f8f9fa;
  text-align: center;
  border-top: 1px solid #e1e8ed;
}

.flag-icon-container {
  margin-bottom: 15px;
}

.flag-icon {
  display: inline-flex;
  gap: 2px;
  padding: 5px;
  background: white;
  border-radius: 5px;
  box-shadow: 0 2px 5px rgba(0,0,0,0.1);
}

.flag-stripe {
  width: 6px;
  height: 20px;
}

.flag-stripe.red {
  background: #CE1126;
}

.flag-stripe.white {
  background: #f8f9fa;
}

.flag-stripe.blue {
  background: #002D62;
}

.copyright {
  margin: 0;
  color: #6c757d;
  font-size: 13px;
}

/* Responsive */
@media (max-width: 576px) {
  .login-content {
    padding: 10px;
  }

  .login-form {
    padding: 20px;
  }

  .login-title {
    font-size: 24px;
  }

  .form-options {
    flex-direction: column;
    align-items: stretch;
  }

  .flag-pattern {
    transform: rotate(-15deg) scale(2);
  }
}

/* Loading animation */
.spinner-border {
  width: 1rem;
  height: 1rem;
  border-width: 0.15em;
}

/* Invalid feedback animation */
.invalid-feedback {
  display: block;
  margin-top: 5px;
  font-size: 13px;
  color: #CE1126;
  animation: shake 0.3s;
}

@keyframes shake {
  0%, 100% { transform: translateX(0); }
  25% { transform: translateX(-5px); }
  75% { transform: translateX(5px); }
}
</style>