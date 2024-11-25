export function simulateLLMResponse(logLine: string): string {
  // This is a simple simulation. In a real-world scenario, this would be replaced with an actual LLM API call.
  const responses = [
    "This log line indicates the Docker daemon is starting up.",
    "This shows a container being created with a specific ID.",
    "This line represents a network being attached to a container.",
    "This indicates a volume is being mounted to a container.",
    "This log entry shows a container starting its main process.",
    "This line suggests a port mapping being set up for a container.",
    "This indicates a container has successfully started and is now running.",
  ];

  return responses[Math.floor(Math.random() * responses.length)];
}

