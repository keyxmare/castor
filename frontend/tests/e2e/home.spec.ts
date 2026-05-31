import { expect, test } from '@playwright/test'

test('home page renders the API greeting and a healthy status', async ({ page }) => {
  await page.goto('/')

  await expect(page.getByRole('heading', { level: 1 })).toBeVisible()
  await expect(page.getByText('Hello from Symfony')).toBeVisible()
  await expect(page.locator('[data-status="ok"]')).toBeVisible()
})

test('home page switches between assistant tabs', async ({ page }) => {
  await page.goto('/')

  const codexTab = page.getByRole('tab', { name: 'Codex' })
  await codexTab.click()

  await expect(codexTab).toHaveAttribute('aria-selected', 'true')
  await expect(page.getByText('skill castor-init')).toBeVisible()
})
