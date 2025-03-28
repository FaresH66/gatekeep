from flask import Blueprint, request, jsonify
from app import create_db_connection
from ..utils import token_required
import bcrypt
import jwt
import datetime
from ..config import Config

auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')

    conn = create_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT id, role, email, password_hash FROM users WHERE email = %s", (email,))
    user = cursor.fetchone()
    conn.close()

    if user and bcrypt.checkpw(password.encode('utf-8'), user['password_hash'].encode('utf-8')):
        token = jwt.encode(
            {
                'user_id': user['id'],
                'role': user['role'],
                'exp': datetime.datetime.utcnow() + datetime.timedelta(seconds=Config.JWT_EXPIRATION)
            },
            Config.SECRET_KEY,
            algorithm='HS256'
        )
        return jsonify({'message': 'Login successful', 'token': token, 'role': user['role'], 'user_id': user['id']}), 200
    return jsonify({'message': 'Invalid credentials'}), 401

@auth_bp.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')
    name = data.get('name')
    role = data.get('role')

    hashed = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
    conn = create_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute(
            "INSERT INTO users (role, name, email, password_hash) VALUES (%s, %s, %s, %s)",
            (role, name, email, hashed)
        )
        conn.commit()
        return jsonify({'message': 'User registered'}), 201
    except mysql.connector.Error as err:
        return jsonify({'message': f'Error: {err}'}), 400
    finally:
        conn.close()

# Example protected route
@auth_bp.route('/protected', methods=['GET'])
@token_required
def protected():
    return jsonify({'message': f'Hello, user {request.user_data["user_id"]} ({request.user_data["role"]})'})