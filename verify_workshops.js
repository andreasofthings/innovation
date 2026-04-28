const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage({
    viewport: { width: 390, height: 844 },
    isMobile: true,
  });

  try {
    console.log('Navigating to http://localhost:8080');
    // Assuming the app is already running and bypasses login for testing or we are just taking a look
    await page.goto('http://localhost:8080', { waitUntil: 'networkidle' });

    // Wait for the app to load
    await page.waitForTimeout(5000);

    // Screenshot initial state (likely login)
    await page.screenshot({ path: 'initial_state.png' });
    console.log('Initial state screenshot saved.');

  } catch (e) {
    console.error('Error during UI verification:', e);
  } finally {
    await browser.close();
  }
})();
