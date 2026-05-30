<?php

declare(strict_types=1);

namespace App\Health;

use Doctrine\DBAL\Connection;

final readonly class DatabaseHealthIndicator implements HealthIndicatorInterface
{
    public function __construct(private Connection $connection) {}

    public function isAvailable(): bool
    {
        try {
            $this->connection->executeQuery('SELECT 1');

            return true;
        } catch (\Throwable) {
            return false;
        }
    }
}
