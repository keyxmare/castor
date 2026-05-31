<?php

declare(strict_types=1);

namespace App\Tests\Controller;

use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;

final class GreetingControllerTest extends WebTestCase
{
    public function testGreetingReturnsMessageAndIsoTimestamp(): void
    {
        $client = static::createClient();
        $client->request('GET', '/api/greeting');

        self::assertResponseIsSuccessful();
        self::assertResponseHeaderSame('Content-Type', 'application/json');

        $payload = json_decode((string) $client->getResponse()->getContent(), true);
        self::assertIsArray($payload);
        self::assertSame('Hello from Symfony', $payload['message']);
        self::assertIsString($payload['generatedAt']);
        self::assertNotFalse(
            \DateTimeImmutable::createFromFormat(\DateTimeInterface::ATOM, $payload['generatedAt']),
        );
    }
}
