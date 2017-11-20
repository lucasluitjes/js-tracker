const puppeteer = require('puppeteer');

(async () => {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();
  
  page.on('request', req => {
    if (req.resourceType === "script") {
      console.log(req.url);
    }
  });
  
  await page.goto(process.argv[2]);
  await browser.close();
})();