const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();

  // Set viewport to a common mobile size
  await page.setViewportSize({ width: 390, height: 844 });

  try {
    // Navigate to the app
    await page.goto('http://localhost:3000');

    // Wait for the app to load. Assuming login is bypassed or already handled in dev mode.
    // In our case, we might need to simulate login if it's required.
    // Based on memory, we use a mock login or it's already authenticated in this environment?
    // Let's try to find the menu button and open the drawer.

    await page.waitForTimeout(5000); // Wait for Flutter to bootstrap

    // Take a screenshot of the home screen
    await page.screenshot({ path: 'home_screen.png' });

    // Click on Menu (last destination in NavigationBar)
    // Flutter uses semantics, which might be hard to target directly with CSS selectors.
    // We can try to click by position or use aria-labels if available.
    await page.click('flt-semantics[aria-label="Menu"]');
    await page.waitForTimeout(1000);

    // Take a screenshot of the drawer
    await page.screenshot({ path: 'drawer.png' });

    // Click on "Contacts" in the drawer
    await page.click('flt-semantics[aria-label="Contacts"]');
    await page.waitForTimeout(2000);

    // Take a screenshot of the Contact Management screen
    await page.screenshot({ path: 'contacts_screen.png' });

    console.log('Screenshots taken successfully');
  } catch (e) {
    console.error('Error during UI verification:', e);
  } finally {
    await browser.close();
  }
})();
