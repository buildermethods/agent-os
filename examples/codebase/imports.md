# Import Reference

Generated: 2025-01-21
Last Updated: 2025-01-21

## Import Aliases

### Webpack/Vite Aliases
@/components -> src/components
@/hooks -> src/hooks
@/utils -> src/utils
@/models -> src/models
@/auth -> src/auth
@/api -> src/api
@/store -> src/store
@/styles -> src/styles

### TypeScript Path Mappings
~/components/* -> src/components/*
~/hooks/* -> src/hooks/*
~/utils/* -> src/utils/*
~/types/* -> src/types/*

## Module Exports

### Authentication
src/auth/utils.js: { getCurrentUser, validateToken, hashPassword, comparePasswords, generateJWT }
src/auth/middleware.js: { requireAuth, optionalAuth, requireRole }
src/auth/constants.js: { TOKEN_EXPIRY, REFRESH_EXPIRY, AUTH_ERRORS }

### Components
src/components/Button.jsx: default Button
src/components/Card.tsx: { Card, CardHeader, CardBody, CardFooter }
src/components/Modal.jsx: default Modal
src/components/Form/index.js: { Form, FormField, FormError, FormSubmit }
src/components/Layout.jsx: default Layout
src/components/Navigation.jsx: default Navigation

### Hooks
src/hooks/useAuth.js: { useAuth, useCurrentUser, useLogin, useLogout }
src/hooks/useApi.js: default useApi
src/hooks/useFetch.js: default useFetch
src/hooks/useForm.js: default useForm
src/hooks/useDebounce.js: default useDebounce

### Utils
src/utils/api.js: { apiClient, get, post, put, del }
src/utils/validation.js: { isEmail, isPhoneNumber, isPostalCode, validatePassword, validateUsername }
src/utils/format.js: { formatDate, formatCurrency, formatPhoneNumber }
src/utils/storage.js: { getItem, setItem, removeItem, clear }

### Models
src/models/User.js: default User
src/models/Product.js: default Product
src/models/Order.js: default Order
src/models/Cart.js: default Cart

### Store (Redux/Zustand)
src/store/index.js: default store
src/store/slices/authSlice.js: { authSlice, authActions }
src/store/slices/cartSlice.js: { cartSlice, cartActions }
src/store/slices/uiSlice.js: { uiSlice, uiActions }

### Types (TypeScript)
src/types/auth.ts: { User, AuthState, LoginCredentials, RegisterData }
src/types/api.ts: { ApiResponse, ApiError, PaginatedResponse }
src/types/components.ts: { ButtonProps, CardProps, ModalProps }

## NPM Package Imports

### React Ecosystem
react: { useState, useEffect, useContext, useMemo, useCallback, useRef }
react-dom: { render, createPortal }
react-router-dom: { BrowserRouter, Route, Link, useNavigate, useParams }

### State Management
redux: { createStore, combineReducers, applyMiddleware }
@reduxjs/toolkit: { createSlice, configureStore, createAsyncThunk }
zustand: create

### HTTP/API
axios: default axios
fetch: native fetch API

### Validation
yup: { object, string, number, boolean, array }
zod: { z }

### UI Libraries
@mui/material: { Button, TextField, Dialog, Card }
antd: { Button, Input, Modal, Card }
tailwindcss: utility classes only