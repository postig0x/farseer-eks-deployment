"use client"

import { useState } from 'react'
import ReactMarkdown from 'react-markdown'
import { Button } from "@/components/ui/button"
import { Textarea } from "@/components/ui/textarea"
import { simulateErrorAnalysis } from '../utils/simulateErrorAnalysis'
import { Loader2 } from 'lucide-react'

export default function DevOpsErrorAnalyzer() {
  const [logs, setLogs] = useState('')
  const [analysis, setAnalysis] = useState<{ markdown: string } | null>(null)
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const handleSubmit = async () => {
    setIsLoading(true)
    setError(null)
    try {
      const result = await simulateErrorAnalysis(logs)
      setAnalysis(result)
    } catch (err) {
      setError('An error occurred while analyzing the logs. Please try again.')
      console.error(err)
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <div className="min-h-screen bg-background py-8 px-4 sm:px-6 lg:px-8">
      <div className="max-w-3xl mx-auto">
        <h1 className="text-2xl font-bold text-center mb-8 text-foreground">DevOps Error Analyzer: Log Debugger</h1>
        <div className="space-y-6">
          <div>
            <label htmlFor="logs" className="block text-sm font-medium text-foreground mb-2">
              Paste your error logs here:
            </label>
            <Textarea
              id="logs"
              placeholder="Enter your logs..."
              value={logs}
              onChange={(e) => setLogs(e.target.value)}
              rows={10}
              className="w-full resize-none border-foreground/20"
            />
          </div>
          <div className="flex justify-center">
            <Button 
              onClick={handleSubmit} 
              disabled={isLoading || logs.trim() === ''}
              className="w-full sm:w-auto"
            >
              {isLoading ? (
                <>
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                  Analyzing...
                </>
              ) : (
                'Analyze Error'
              )}
            </Button>
          </div>
          {error && (
            <div className="text-red-500 text-center">{error}</div>
          )}
          {analysis && (
            <div className="mt-8">
              <h2 className="text-xl font-semibold mb-4 text-foreground">Error Analysis Results</h2>
              <div className="prose dark:prose-invert max-w-none">
                <ReactMarkdown>{analysis.markdown}</ReactMarkdown>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}

