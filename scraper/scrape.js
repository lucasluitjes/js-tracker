const puppeteer = require('puppeteer');
const crypto = require('crypto');
const hash = crypto.createHash('sha256');

hash.on('readable', () => {
  const data = hash.read();
  if (data) {
    console.log(data.toString('hex'));
    // Prints:
    //   6a2da20943931e9834fc12cfe5bb47bbd9ae43489a30726962b576f4e3993e50
  }
});

hash.write('some data to hash');
hash.end();

(async () => {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();
  
  page.on('request', req => {
    if (req.resourceType === "script") {
      console.log("REQ: " + req.url);
    }
  });

  page.on('response', resp => {
    if (resp.request().resourceType === "script") {
      resp.buffer(buf => {
        let hash = crypto.createHash('sha256');

        hash.on('readable', () => {
          let data = hash.read();
          if (data) {
            // never gets called (something with promises surely)
            console.log("RESP: " + resp.request().url + " (" + data.toString('hex') + ")");
          }
        });

        hash.write(buf);
        hash.end();
      });
    }
  });

  await page.goto(process.argv[2]);
  await browser.close();
})();