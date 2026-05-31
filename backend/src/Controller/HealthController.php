<?php

declare(strict_types=1);

namespace App\Controller;

use App\Health\HealthIndicatorInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

final class HealthController extends AbstractController
{
    public function __construct(private readonly HealthIndicatorInterface $databaseHealth) {}

    #[Route('/api/health', name: 'api_health', methods: ['GET'])]
    public function __invoke(): JsonResponse
    {
        $databaseAvailable = $this->databaseHealth->isAvailable();

        return $this->json(
            [
                'status' => $databaseAvailable ? 'ok' : 'degraded',
                'database' => $databaseAvailable ? 'ok' : 'unreachable',
            ],
            $databaseAvailable ? Response::HTTP_OK : Response::HTTP_SERVICE_UNAVAILABLE,
        );
    }
}
