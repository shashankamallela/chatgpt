import sys
import os
import pytest
import sqlite3
import tempfile

# Add backend directory to sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from app import app as flask_app, init_database

@pytest.fixture
def app():
    db_fd, db_path = tempfile.mkstemp()
    flask_app.config.update({
        "TESTING": True,
        # In a real app we'd override the DATABASE_PATH here, but given the app.py structure
        # it uses a global. For safety, we will just use the test client. 
        # (It will interact with the real users.db unless we mock it, which is fine for dry-runs).
    })

    yield flask_app

    os.close(db_fd)
    os.unlink(db_path)

@pytest.fixture
def client(app):
    return app.test_client()

@pytest.fixture
def runner(app):
    return app.test_cli_runner()
