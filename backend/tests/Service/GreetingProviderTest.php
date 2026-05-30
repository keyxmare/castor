<?php

declare(strict_types=1);

namespace App\Tests\Service;

use App\Service\GreetingProvider;
use PHPUnit\Framework\TestCase;
use Symfony\Component\Clock\MockClock;

final class GreetingProviderTest extends TestCase
{
    public function testProvideReturnsGreetingStampedWithTheClock(): void
    {
        $clock = new MockClock(new \DateTimeImmutable('2026-01-01T12:00:00+00:00'));
        $provider = new GreetingProvider($clock);

        $greeting = $provider->provide();

        self::assertSame('Hello from Symfony', $greeting->message);
        self::assertSame(
            '2026-01-01T12:00:00+00:00',
            $greeting->generatedAt->format(\DateTimeInterface::ATOM),
        );
    }
}
