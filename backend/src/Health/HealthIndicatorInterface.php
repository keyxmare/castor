<?php

declare(strict_types=1);

namespace App\Health;

interface HealthIndicatorInterface
{
    public function isAvailable(): bool;
}
