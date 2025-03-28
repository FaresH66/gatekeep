class Config:
    SECRET_KEY = '714c9cda7fac0cbbb097510eb70b6aeb'  # Generate a secure key (e.g., use secrets.token_hex(16))
    JWT_EXPIRATION = 3600          # Token expires in 1 hour (in seconds)