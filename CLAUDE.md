# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Laravel-Vue SPA application that manages user authentication and searches in a SQL Server database (Padron). The application uses JWT for authentication, Vue 2 for the frontend, and connects to multiple SQL Server databases.

## Commands

### Development
- `npm run dev` - Run development server with hot reload
- `npm run watch` - Watch files for changes
- `npm run build` - Build for production
- `npm run eslint` - Run ESLint with autofix for JavaScript and Vue files

### Testing
- `vendor/bin/phpunit` - Run unit and feature tests
- `php artisan dusk` - Run browser tests

### Laravel Artisan
- `php artisan serve` - Start Laravel development server
- `php artisan migrate` - Run database migrations
- `php artisan key:generate` - Generate application key
- `php artisan jwt:secret` - Generate JWT secret

## Architecture

### Database Configuration
The application uses multiple database connections:
- **sqlsrv_db1**: Primary database containing `users`, `Padron`, `UserSearchLogs` tables
- **sqlsrv_db2**: Secondary database containing `FOTOS_PRM_PRM` table for photos

All models explicitly define their database connection using `protected $connection = 'sqlsrv_db1';`

### Frontend Structure
- **Vue 2 + Vuex + Vue Router** SPA architecture
- Components are organized under `resources/js/`:
  - `pages/` - Route components (home, users, historials, auth pages)
  - `components/` - Reusable components (Navbar, Card, Button, etc.)
  - `layouts/` - Layout components (default, basic, error)
  - `store/modules/` - Vuex store modules for state management
  - `router/routes.js` - Route definitions
  - Alias `~` points to `resources/js/` directory

### Authentication Flow
- JWT-based authentication using `tymon/jwt-auth`
- User model implements `JWTSubject` interface
- API routes protected with `auth:api` middleware
- User types: `TYPE_ADMIN = 1`, `TYPE_GUEST = 2`

### Key Controllers
- **PadronController**: Handles citizen record searches, logs all searches, and fetches photos
- **UserController**: User CRUD operations (admin only)
- **LogController**: Search logs viewing functionality

### API Routes Structure
Protected routes (`auth:api`):
- User management endpoints
- Search endpoints
- Search logs viewing

Public routes (`guest:api`):
- Authentication (login, register, password reset)
- OAuth integration
- Public search endpoints

### Build Process
- Laravel Mix with Vue loader
- CSS extraction in production
- Version hashing for cache busting
- Build output in `public/dist/` directory