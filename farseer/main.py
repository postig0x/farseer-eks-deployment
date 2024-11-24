import asyncio
import os
from dotenv import load_dotenv

import instructor
from pydantic import BaseModel, Field
from openai import OpenAI

from datetime import datetime
from enum import Enum
from typing import Optional, List

load_dotenv()
KEY = os.getenv("XAI_KEY")

LOG_FILES = [
    '../ell_test/temp_ai_gen_logs/claude-ai.log',
    '../ell_test/temp_ai_gen_logs/dolma_log1.txt',
    '../ell_test/temp_ai_gen_logs/dolma_log2.txt',
    '../ell_test/temp_ai_gen_logs/dolma_log3.txt',
    '../ell_test/temp_ai_gen_logs/dolma_log4.txt',
    '../ell_test/temp_ai_gen_logs/dolma_log5.txt',
    '../ell_test/temp_ai_gen_logs/dolma_log6.txt',
]

def read_logfile(filename):
    with open(filename, "r") as file:
        log_list = file.readlines()
        logs = ''.join(filter(lambda line : line != '\n', log_list))
    return logs

# Default response from an LLM is:
# TIMESTAMP = "indicated date and time when the log entry was created"
# LOG LEVEL = "XXXX indicates that this is an information/debugging/error message"
# MESSAGE = "The container with ID XXXX is starting"

# we want to create an object model for TIMESTAMP, LOG_LEVEL, and MESSAGE
# we want to supply descriptions of each MESSAGE in more detail, let's ask for 2 sentence responses about MESSAGE?

# types of logs:
# docker logs
# web server logs
# system logs
# app logs
# security logs
# event logs
# custom logs

# create xAI client
xai_client = instructor.from_openai(
    OpenAI(
        api_key=KEY,
        base_url="https://api.x.ai/v1"
        )
    )

class LogLevelModel(str, Enum):
    DEBUG = "DEBUG"
    INFO = "INFO"
    WARN = "WARN"
    TRACE = "TRACE"
    ERROR = "ERROR"
    FATAL = "FATAL"

class LogEntryClassification(BaseModel):
    timestamp: datetime = Field(
        default_factory=datetime.utcnow,
        description="Indicates the date and time when the log entry was created."
    )
    source: str = Field(
        description="The origin of the log entry, such as the application name, service, or server."
    )
    log_level: LogLevelModel
    message: str = Field(description="The content of the log entry")
    root_cause: Optional[str] = Field(
        default=None,
        description="A brief explanation of the underlying issue that led to the log entry (optional)."
    )
    location: Optional[str] = Field(
        default=None,
        description="The file(s) or component(s) related to the log message (optional)."
    )
    suggestion: Optional[str] = Field(
        default=None,
        description="Recommended actions to resolve the issue, if applicable (optional)."
    )
    process_id: Optional[int] = Field(
        default=None,
        description="The ID of the process that generated the log entry (optional)."
    )
    event: Optional[str] = Field(
        default=None,
        description="A description of the event related to the log entry(optional).",
    )
    response_code: Optional[int] = Field(
        default=None,
        description="HTTP response code for web server logs (optional)."
    )


async def classify_log_entry(log_entry: str) -> LogEntryClassification:
    try:
        response = xai_client.chat.completions.create(
            model="grok-beta",
            response_model=LogEntryClassification,
            temperature=0,
            # max_retries=3, # we don't want this right now
            messages=[
                {
                    "role": "system",
                    "content": "You are an expert in DevOps Engineering, architecting cloud infrastructure, and creating and deploying docker containers. You are tutoring the user to learn to read and understand logs efficiently. Analyze the following log file and extract the requested information for each line in the file."
                }, {
                    "role": "user",
                    "content": log_entry
                }
            ],
        )
        classifications = []
        for log_line in response:
            if log_line:
                print(log_line)
                classifications.append(log_line)
            else:
                print('empty log line')

        if not classifications:
            print('no valid classifications generated')

        return classifications
    except Exception as e:
        print(f"Error: {str(e)}")
        raise

async def main():
    try:
        logs = [read_logfile(file) for file in LOG_FILES]
        results = await classify_log_entry(logs[0])

        print('len', len(results))
        print('results:', results)
        with open('xai_instructor_test.txt', "w") as file:
            for result in results:
                file.write(result.model_dump_json(indent=2) + "\n\n")
                print('writing result to file:', result)
    except Exception as e:
        print("error in main:", e)

if __name__ == "__main__":
    asyncio.run(main())
