const puppeteer = require('puppeteer');

(async () => {
  console.log("Starting puppeteer...");
  const browser = await puppeteer.launch({
    headless: "new"
  });
  const page = await browser.newPage();

  page.on('console', msg => console.log('BROWSER CONSOLE:', msg.text()));
  page.on('pageerror', error => console.log('BROWSER ERROR:', error.message));

  console.log("Navigating to http://localhost:5173 ...");
  try {
    await page.goto('http://localhost:5173', { waitUntil: 'networkidle0', timeout: 10000 });
  } catch (err) {
    console.log("Navigation timeout or error:", err.message);
  }

  // Wait a bit to ensure React renders and error boundary catches
  await new Promise(r => setTimeout(r, 2000));

  console.log("Checking for Error Boundary text...");
  try {
    const errorText = await page.evaluate(() => {
      const p = document.querySelector('pre');
      return p ? p.innerText : "No <pre> tag found. App might not have crashed!";
    });
    console.log("ERROR BOUNDARY OUTPUT:", errorText);
  } catch (e) {
    console.log("Could not find error boundary element:", e.message);
  }

  await browser.close();
})();
