# Function Reference

Generated: 2025-01-21
Last Updated: 2025-01-21

## src/auth/utils.js
getCurrentUser(): User | null ::line:15
validateToken(token: string): boolean ::line:42
hashPassword(password: string): Promise<string> ::line:67
comparePasswords(plain: string, hashed: string): Promise<boolean> ::line:89
generateJWT(userId: number): string ::line:112
::exports: getCurrentUser, validateToken, hashPassword, comparePasswords, generateJWT

## src/auth/middleware.js
requireAuth(req: Request, res: Response, next: NextFunction): void ::line:8
optionalAuth(req: Request, res: Response, next: NextFunction): void ::line:25
requireRole(role: string): Middleware ::line:41
::exports: requireAuth, optionalAuth, requireRole

## src/components/Button.jsx
Button(props: ButtonProps): JSX.Element ::line:12
::exports: default

## src/components/Card.tsx
Card(props: CardProps): JSX.Element ::line:8
CardHeader(props: HeaderProps): JSX.Element ::line:32
CardBody(props: BodyProps): JSX.Element ::line:45
CardFooter(props: FooterProps): JSX.Element ::line:58
::exports: Card, CardHeader, CardBody, CardFooter

## src/hooks/useAuth.js
useAuth(): AuthContext ::line:5
useCurrentUser(): User | null ::line:18
useLogin(): LoginFunction ::line:29
useLogout(): LogoutFunction ::line:42
::exports: useAuth, useCurrentUser, useLogin, useLogout

## src/utils/api.js
apiClient(config: AxiosConfig): Promise<Response> ::line:10
get(url: string, params?: object): Promise<any> ::line:25
post(url: string, data?: object): Promise<any> ::line:32
put(url: string, data?: object): Promise<any> ::line:39
del(url: string): Promise<any> ::line:46
::exports: apiClient, get, post, put, del

## src/utils/validation.js
isEmail(value: string): boolean ::line:3
isPhoneNumber(value: string): boolean ::line:8
isPostalCode(value: string): boolean ::line:15
validatePassword(password: string): ValidationResult ::line:22
validateUsername(username: string): ValidationResult ::line:35
::exports: isEmail, isPhoneNumber, isPostalCode, validatePassword, validateUsername

## src/models/User.js
User ::line:5
User.findById(id: number): Promise<User> ::line:12
User.findByEmail(email: string): Promise<User> ::line:28
User.create(data: UserData): Promise<User> ::line:44
User.update(id: number, data: Partial<UserData>): Promise<User> ::line:61
User.delete(id: number): Promise<boolean> ::line:78
::exports: default User