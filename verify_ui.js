const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage({
    viewport: { width: 390, height: 844 }, // iPhone 12 Pro size
    isMobile: true,
  });

  try {
    console.log('Navigating to http://localhost:8080');
    await page.goto('http://localhost:8080', { waitUntil: 'networkidle' });

    // Since we are not logged in, we should see the login screen.
    // We can't easily bypass login without mocking the AuthProvider state in the running app,
    // which is hard with 'flutter run'.
    // But we can check if the login screen is there.
    await page.screenshot({ path: 'login_screen.png' });
    console.log('Login screen screenshot saved.');

  } catch (e) {
    console.error('Error during UI verification:', e);
  } finally {
    await browser.close();
  }
})();
