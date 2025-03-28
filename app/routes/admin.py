from flask import Blueprint, render_template, jsonify, request
from ..utils import token_required
from .. import create_db_connection
import mysql.connector

admin_bp = Blueprint('admin', __name__, url_prefix='/admin')

@admin_bp.route('/', methods=['GET'])
@token_required
def admin_dashboard():
    if request.user_data['role'] != 'admin':
        return jsonify({'message': 'Unauthorized: Admin access required'}), 403
    return render_template('admin.html', user_id=request.user_data['user_id'], role=request.user_data['role'])

# List all users
@admin_bp.route('/users', methods=['GET'])
@token_required
def list_users():
    if request.user_data['role'] != 'admin':
        return jsonify({'message': 'Unauthorized'}), 403
    conn = create_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT id, name, email, role FROM users")
    users = cursor.fetchall()
    conn.close()
    return jsonify({'users': users}), 200

# Add a new user
@admin_bp.route('/users', methods=['POST'])
@token_required
def add_user():
    if request.user_data['role'] != 'admin':
        return jsonify({'message': 'Unauthorized'}), 403
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')
    name = data.get('name')
    role = data.get('role')

    import bcrypt
    hashed = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
    conn = create_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute(
            "INSERT INTO users (role, name, email, password_hash) VALUES (%s, %s, %s, %s)",
            (role, name, email, hashed)
        )
        conn.commit()
        return jsonify({'message': 'User added successfully'}), 201
    except mysql.connector.Error as err:
        return jsonify({'message': f'Error: {err}'}), 400
    finally:
        conn.close()

# Assign a car to a resident
@admin_bp.route('/cars', methods=['POST'])
@token_required
def assign_car():
    if request.user_data['role'] != 'admin':
        return jsonify({'message': 'Unauthorized'}), 403
    data = request.get_json()
    resident_id = data.get('resident_id')
    license_plate = data.get('license_plate')

    conn = create_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute(
            "INSERT INTO cars (resident_id, license_plate) VALUES (%s, %s)",
            (resident_id, license_plate)
        )
        conn.commit()
        return jsonify({'message': 'Car assigned successfully'}), 201
    except mysql.connector.Error as err:
        return jsonify({'message': f'Error: {err}'}), 400
    finally:
        conn.close()

# View system logs
@admin_bp.route('/logs', methods=['GET'])
@token_required
def view_logs():
    if request.user_data['role'] != 'admin':
        return jsonify({'message': 'Unauthorized'}), 403
    conn = create_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT id, user_id, event_type, details, timestamp FROM logs ORDER BY timestamp DESC LIMIT 50")
    logs = cursor.fetchall()
    conn.close()
    return jsonify({'logs': logs}), 200