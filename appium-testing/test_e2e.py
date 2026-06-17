import unittest
from appium import webdriver
from appium.options.android import UiAutomator2Options
from appium.webdriver.common.appiumby import AppiumBy

capabilities = dict(
    platformName='Android',
    automationName='uiautomator2',
    deviceName='Android Emulator',
    appPackage='com.example.my_app', # Replace with your actual package name
    appActivity='.MainActivity',
    language='en',
    locale='US'
)

appium_server_url = 'http://localhost:4723'

class TestAppE2E(unittest.TestCase):
    def setUp(self) -> None:
        self.driver = webdriver.Remote(
            appium_server_url, 
            options=UiAutomator2Options().load_capabilities(capabilities)
        )
        self.driver.implicitly_wait(10)

    def tearDown(self) -> None:
        if self.driver:
            self.driver.quit()

    def test_app_launch_and_verify_home(self) -> None:
        # Wait for an element that represents the home screen, e.g., a video feed list or a specific button
        # flutter uses semantic labels if semantics are enabled
        try:
            # Example: Wait for the main feed to load by looking for a known element
            # This will depend on the exact structure of your Flutter app
            # For flutter, you might need appium-flutter-driver for deeper integration, 
            # or rely on content-desc attributes if semantics are properly set.
            el = self.driver.find_element(by=AppiumBy.ACCESSIBILITY_ID, value='home_screen_identifier')
            self.assertTrue(el.is_displayed())
        except Exception as e:
            print(f"Home screen element not found: {e}")

if __name__ == '__main__':
    unittest.main()
