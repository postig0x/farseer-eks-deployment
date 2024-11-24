import os
from dotenv import load_dotenv

import ell
from ell.stores.sql import SQLiteStore
from openai import OpenAI

load_dotenv()
KEY = os.getenv("XAI_KEY")

# create xAI client
xai_client = OpenAI(
    api_key=KEY,
    base_url="https://api.x.ai/v1"
)

# initialize ell
ell.init(store='./ell', autocommit=True)

# add grok-beta model to ell
ell.config.register_model("grok-beta", xai_client)

# add stor

@ell.simple(model="grok-beta", temperature=0.7)
def explain_log(log: str) -> str:
    '''You are an expert in DevOps Engineering, architecting cloud infrastructure, and creating and deploying docker containers. You are tutoring the user to learn to read and understand logs efficiently.'''
    return f"Please explain each line of this log: {log}"

def read_log_from_file(filename):
    with open(filename, "r") as file:
        logs = file.readlines()
    return logs

log_file = read_log_from_file("./temp_ai_gen_logs/dolma_log3.txt")
log_explained = explain_log(log_file)

print(log_explained)
