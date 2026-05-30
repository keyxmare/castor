<?php

declare(strict_types=1);

namespace App\Tests\Controller;

use App\Health\DatabaseHealthIndicator;
use App\Health\HealthIndicatorInterface;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Symfony\Component\HttpFoundation\Response;

final class HealthControllerTest extends WebTestCase
{
    public function testHealthReportsOkWhenDatabaseIsReachable(): void
    {
        $client = static::createClient();
        $client->request('GET', '/api/health');

        self::assertResponseIsSuccessful();
        self::assertResponseHeaderSame('Content-Type', 'application/json');

        $payload = json_decode((string) $client->getResponse()->getContent(), true);
        self::assertIsArray($payload);
        self::assertSame('ok', $payload['status']);
        self::assertSame('ok', $payload['database']);
    }

    public function testHealthReportsDegradedWhenDatabaseIsUnreachable(): void
    {
        $client = static::createClient();
        static::getContainer()->set(DatabaseHealthIndicator::class, new class implements HealthIndicatorInterface {
            public function isAvailable(): bool
            {
                return false;
            }
        });

        $client->request('GET', '/api/health');

        self::assertResponseStatusCodeSame(Response::HTTP_SERVICE_UNAVAILABLE);

        $payload = json_decode((string) $client->getResponse()->getContent(), true);
        self::assertIsArray($payload);
        self::assertSame('degraded', $payload['status']);
        self::assertSame('unreachable', $payload['database']);
    }
}
