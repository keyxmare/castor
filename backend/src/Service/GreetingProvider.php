<?php

declare(strict_types=1);

namespace App\Service;

use App\Dto\GreetingResponse;
use Psr\Clock\ClockInterface;

final readonly class GreetingProvider
{
    public function __construct(private ClockInterface $clock) {}

    public function provide(): GreetingResponse
    {
        return new GreetingResponse(
            'Hello from Symfony',
            $this->clock->now(),
        );
    }
}
