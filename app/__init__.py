from flask import Flask
from .config import Config
import mysql.connector

def create_db_connection():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="",
        database="gatekeeping_db"
    )

def create_app():
    app = Flask(__name__, static_folder='../static', template_folder='../templates')
    app.config.from_object(Config)

    # Register blueprints
    from .routes.auth import auth_bp
    from .routes.main import main_bp
    app.register_blueprint(auth_bp, url_prefix='/api')
    app.register_blueprint(main_bp)

    return app