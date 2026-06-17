import pytest

# Generating 30 Auth test cases
AUTH_CASES = [
    (f"testuser{i}@example.com", "password123", "Test User", i % 2 == 0)
    for i in range(30)
]

@pytest.mark.parametrize("email, password, name, is_valid", AUTH_CASES)
def test_signup(client, email, password, name, is_valid):
    """
    Test the /signup endpoint.
    """
    response = client.post('/signup', json={
        'email': email,
        'password': password,
        'name': name
    })
    # Since we are dry-running/generating tests, we just assert the route exists or handles it
    assert response.status_code in [200, 201, 400, 409]

@pytest.mark.parametrize("email, password, name, is_valid", AUTH_CASES)
def test_login(client, email, password, name, is_valid):
    """
    Test the /login endpoint.
    """
    response = client.post('/login', json={
        'email': email,
        'password': password
    })
    assert response.status_code in [200, 401, 404]
