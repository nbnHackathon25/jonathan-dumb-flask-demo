import pytest
from app import app, VERSION


@pytest.fixture
def client():
    """Create a test client for the Flask app."""
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client


def test_version_endpoint(client):
    """Test the /version endpoint returns the correct version."""
    response = client.get('/version')
    assert response.status_code == 200
    data = response.get_json()
    assert 'version' in data
    assert data['version'] == VERSION


def test_status_endpoint(client):
    """Test the /status endpoint returns healthy status."""
    response = client.get('/status')
    assert response.status_code == 200
    data = response.get_json()
    assert 'status' in data
    assert data['status'] == 'healthy'
    assert 'message' in data


def test_hello_world_root(client):
    """Test the root / endpoint returns hello world message."""
    response = client.get('/')
    assert response.status_code == 200
    data = response.get_json()
    assert 'message' in data
    assert data['message'] == 'Hello, World!'


def test_hello_world_hello(client):
    """Test the /hello endpoint returns hello world message."""
    response = client.get('/hello')
    assert response.status_code == 200
    data = response.get_json()
    assert 'message' in data
    assert data['message'] == 'Hello, World!'


def test_greet_endpoint(client):
    """Test the /greet/<name> endpoint returns personalized greeting."""
    response = client.get('/greet/Alice')
    assert response.status_code == 200
    data = response.get_json()
    assert 'message' in data
    assert data['message'] == 'Hello, Alice!'
    assert 'greeted' in data
    assert data['greeted'] == 'Alice'
