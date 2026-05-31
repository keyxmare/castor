<?php

declare(strict_types=1);

namespace App\Dto;

final readonly class GreetingResponse
{
    public function __construct(
        public string $message,
        public \DateTimeImmutable $generatedAt,
    ) {}
}
