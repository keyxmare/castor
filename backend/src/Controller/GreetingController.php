<?php

declare(strict_types=1);

namespace App\Controller;

use App\Service\GreetingProvider;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\Routing\Attribute\Route;

final class GreetingController extends AbstractController
{
    public function __construct(private readonly GreetingProvider $greetingProvider) {}

    #[Route('/api/greeting', name: 'api_greeting', methods: ['GET'])]
    public function __invoke(): JsonResponse
    {
        return $this->json($this->greetingProvider->provide());
    }
}
