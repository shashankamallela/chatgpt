import pytest

# Generating 10 Video test cases
VIDEO_CASES = [i for i in range(1, 11)]

@pytest.mark.parametrize("video_id", VIDEO_CASES)
def test_get_videos(client, video_id):
    """
    Test the /videos endpoint.
    """
    response = client.get('/videos')
    assert response.status_code == 200
    data = response.get_json()
    assert 'videos' in data

@pytest.mark.parametrize("video_id", VIDEO_CASES)
def test_upload_video_validation(client, video_id):
    """
    Test /videos/upload validation.
    """
    # Simply testing without file data to expect a 400
    response = client.post('/videos/upload')
    assert response.status_code == 400
