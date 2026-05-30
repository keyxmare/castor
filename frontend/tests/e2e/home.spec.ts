import { expect, test } from '@playwright/test'

test('home page renders the API greeting and a healthy status', async ({ page }) => {
  await page.goto('/')

  await expect(page.getByRole('heading', { level: 1 })).toBeVisible()
  await expect(page.getByText('Hello from Symfony')).toBeVisible()
  await expect(page.locator('[data-status="ok"]')).toBeVisible()
})
