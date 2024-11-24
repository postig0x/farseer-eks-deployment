# Farseer

Building and Deploying a Highly Available Agentic System with Log-Reading Capabilities

## Purpose

### Supported Logs

- Web Server
- System
- Application
- Docker Containers
- Event

### Log Classification Schema

Needs to be looked over. Do we need all of these? Can we remove some? Are any fields redundant? Poorly described/explained?

- **TIMESTAMP**
  - **Description**: Indicates the date and time when the log entry was created.
  - **Example**: `2024-11-22T12:00:01Z`

- **LOG_LEVEL**
  - **Description**: Indicates the severity of the log message (e.g., DEBUG, INFO, WARN, TRACE, ERROR, CRITICAL).
  - **Example**: `ERROR`

- **MESSAGE**
  - **Description**: The content of the log message, describing the event or issue.
  - **Example**: `Configuration file not found: /etc/myapp/config.yaml`

- **ROOT CAUSE**
  - **Description**: A brief explanation of the underlying issue that led to the log entry (optional).
  - **Example**: `The specified configuration file does not exist.`

- **LOCATION**
  - **Description**: The file(s) or component(s) related to the log message (optional).
  - **Example**: `/etc/myapp/config.yaml`

- **SUGGESTION**
  - **Description**: Recommended actions to resolve the issue, if applicable (optional).
  - **Example**: `Ensure the configuration file exists and has the correct permissions.`

- **SOURCE**
  - **Description**: The origin of the log entry, such as the application name, service, or server.
  - **Example**: `nginx`, `myapp`, `sshd`

- **PROCESS_ID**
  - **Description**: The ID of the process that generated the log entry (optional).
  - **Example**: `1234`

- **EVENT**
  - **Description**: A description of the event related to the log entry(optional).
  - **Example**: `Failed login attempt`

- **RESPONSE_CODE**
  - **Description**: HTTP response code for web server logs (optional).
  - **Example**: `404`

### Example Log Entries Using the Schema

#### Web Server Log

```log
TIMESTAMP: 2024-11-22T12:00:01Z
LOG_LEVEL: INFO
MESSAGE: "GET /index.html HTTP/1.1"
ROOT CAUSE: 
LOCATION: /var/log/nginx/access.log
SUGGESTION: 
SOURCE: nginx
USER: 
IP_ADDRESS: 192.168.1.1
PROCESS_ID: 
EVENT_ID: 
RESPONSE_CODE: 200
```

#### System Log

```log
TIMESTAMP: Nov 22 12:00:01
LOG_LEVEL: ERROR
MESSAGE: "CPU0: Temperature above threshold, cpu clock throttled"
ROOT CAUSE: "Overheating due to high CPU usage."
LOCATION: /var/log/syslog
SUGGESTION: "Check CPU usage and cooling system."
SOURCE: kernel
USER: 
IP_ADDRESS: 
PROCESS_ID: 
EVENT_ID: 
RESPONSE_CODE: 
```

#### Application Log

```log
TIMESTAMP: 2024-11-22 12:00:01
LOG_LEVEL: ERROR
MESSAGE: "User login failed for user: admin"
ROOT CAUSE: "Invalid credentials provided."
LOCATION: /app/authentication.py
SUGGESTION: "Verify user credentials."
SOURCE: myapp
USER: admin
IP_ADDRESS: 192.168.1.100
PROCESS_ID: 
EVENT_ID: 
RESPONSE_CODE: 
```

#### Docker Container Log

```log
TIMESTAMP: 2024-11-22T12:00:01Z
LOG_LEVEL: DEBUG
MESSAGE: "Starting up..."
ROOT CAUSE: 
LOCATION: /app/startup.sh
SUGGESTION: 
SOURCE: myapp-container
USER: 
IP_ADDRESS: 
PROCESS_ID: 5678
EVENT_ID: 
RESPONSE_CODE: 
```

#### Event Log

```log
TIMESTAMP: Nov 22 12:00:01
LOG_LEVEL: INFO
MESSAGE: "An account failed to log on."
ROOT CAUSE: "User attempted to log in with incorrect credentials."
LOCATION: /var/log/security.log
SUGGESTION: "Check user account status."
SOURCE: Microsoft-Windows-Security-Auditing
USER: admin
IP_ADDRESS: 192.168.
```
