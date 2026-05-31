import AxeBuilder from '@axe-core/playwright'
import { expect, test } from '@playwright/test'

test('home page has no detectable accessibility violations', async ({ page }) => {
  await page.goto('/')
  await expect(page.getByRole('heading', { level: 1 })).toBeVisible()

  const { violations } = await new AxeBuilder({ page }).withTags(['wcag2a', 'wcag2aa']).analyze()

  expect(violations).toEqual([])
})
