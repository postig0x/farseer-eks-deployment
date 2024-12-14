interface ErrorAnalysis {
  markdown: string;
}

export async function simulateErrorAnalysis(logs: string): Promise<ErrorAnalysis> {
  try {
    const response = await fetch('/api/log', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ log: logs }),
    });

    if (!response.ok) {
      throw new Error('Failed to analyze logs');
    }

    const data = await response.json();
    return {
      markdown: data.output,
    };
  } catch (error) {
    console.error('Error analyzing logs:', error);
    return {
      markdown: 'An error occurred while analyzing the logs. Please try again.',
    };
  }
}

