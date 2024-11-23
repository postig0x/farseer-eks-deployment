import os
from dotenv import load_dotenv

import instructor
from pydantic import BaseModel, Field
from openai import OpenAI
from enum import Enum
from typing import List

load_dotenv()
KEY = os.getenv("XAI_KEY")

LOG_FILES = [
    '../prompt_eng/temp_ai_gen_logs/claude-ai.log',
    '../prompt_eng/temp_ai_gen_logs/dolma_log1.txt',
    '../prompt_eng/temp_ai_gen_logs/dolma_log2.txt',
    '../prompt_eng/temp_ai_gen_logs/dolma_log3.txt',
    '../prompt_eng/temp_ai_gen_logs/dolma_log4.txt',
    '../prompt_eng/temp_ai_gen_logs/dolma_log5.txt',
    '../prompt_eng/temp_ai_gen_logs/dolma_log6.txt',
]

def read_logfile(filename):
    with open(filename, "r") as file:
        log_list = file.readlines()
        logs = ''.join(filter(lambda line : line != '\n', log_list))
    return logs

logs = [read_logfile(file) for file in LOG_FILES]

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
xai_client = OpenAI(api_key=KEY, base_url="https://api.x.ai/v1")

def classify_log():