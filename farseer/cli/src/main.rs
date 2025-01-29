use clap::Parser; // arg parsing
use reqwest::Client;
use serde::{Deserialize, Serialize}; // json
use std::error::Error;

#[derive(Parser, Debug)]
#[command(name = "farseer")]
#[command(author = "cloudbandits | postig0x")]
#[command(version = "1.0")]
#[command(about = "devops log analysis cli tool", long_about = None)]
struct Args {
    /// log path or log text to analyze
    #[arg(short, long)]
    log: String,

    /// API endpoint (default: http://localhost:8000)
    #[arg(short, long, default_value = "http://localhost:8000")]
    endpoint: String,
}

#[derive(Debug, Serialize)]
struct LogRequest {
    log: String,
}

#[derive(Debug, Deserialize)]
struct LogResponse {
    output: String,
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn Error>> {
    // Box - smart pointer that allocates memory on the heap
    // automatically deallocates memory when the box goes out of scope
    // good for data that may not have fixed size at compile time
    // dyn - dynamically dispatched Error trait
    let args = Args::parse();
    let client = Client::new();

    // check if input is a file path
    let log_content = if std::path::Path::new(&args.log).exists() {
        std::fs::read_to_string(&args.log)?
    } else {
        args.log
    };

    // first: check if backend service is healthy
    let health_url = format!("{}/health", args.endpoint);
    let health_response = client.get(&health_url).send().await?;
    
    if !health_response.status().is_success() {
        eprintln!("Service is not healthy. Please check if the API is running.");
        std::process::exit(1);
    }

    // send log analysis request
    let log_url = format!("{}/api/log", args.endpoint);
    let response = client
        .post(&log_url)
        .json(&LogRequest { log: log_content })
        .send()
        .await?;

    if response.status().is_success() {
        let log_response: LogResponse = response.json().await?;
        println!("{}", log_response.output);
    } else {
        eprintln!("Error: {}", response.status());
        if let Ok(error_text) = response.text().await {
            eprintln!("Error details: {}", error_text);
        }
    }

    Ok(())
}