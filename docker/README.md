# Docker implementation

This folder contains the dockerfiles necessary to containerize the farseer app as frontend and backend images.

## Setup

There is a `.env` file required here for `XAI_KEY`. `docker compose up` (build) uses the .env file to set the environment variable listed in `compose.yml`

## Frontend Config

`frontend/next.config.mjs` needed to be configured to fix routing issues to the backend when attempting to make a network call. Refer to that file for clarity.


