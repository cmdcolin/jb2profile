import puppeteer from 'puppeteer'
;(async () => {
  const browser = await puppeteer.launch()
  const page = await browser.newPage()
  console.time('timer')

  await page.goto(process.argv[2])

  await new Promise(resolve => {
    page.on('console', async msg => {
      const msgArgs = msg.args()
      const val = await msgArgs[0].jsonValue()
      if (val === 'DONE') {
        resolve()
      }
    })
  })

  console.timeEnd('timer')

  await browser.close()
})()
