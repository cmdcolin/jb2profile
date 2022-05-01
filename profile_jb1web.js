import puppeteer from 'puppeteer'
import fs from 'fs'
;(async () => {
  const browser = await puppeteer.launch()
  const page = await browser.newPage()
  await page.goto(process.argv[2])

  const params = new URL(process.argv[2]).searchParams
  const tracks = params.get('tracks')
  const n = tracks.split(',').length
  const nblocks = 4 * n
  await page.evaluate(() => {
    window.fps = []

    let LAST_FRAME_TIME = 0
    function measure(TIME) {
      window.fps.push(1 / ((performance.now() - LAST_FRAME_TIME) / 1000))
      LAST_FRAME_TIME = TIME
      window.requestAnimationFrame(measure)
    }
    window.requestAnimationFrame(measure)
  })
  await page.waitForFunction(
    nblocks => document.querySelectorAll('.canvas-track').length >= nblocks,
    { timeout: 300000 },
    nblocks,
  )

  const fps = await page.evaluate(() => JSON.stringify(window.fps))

  fs.writeFileSync(process.argv[3], fps)
  fs.writeFileSync(process.argv[4], JSON.stringify(await page.metrics()))

  await browser.close()
  process.exit(0)
})()