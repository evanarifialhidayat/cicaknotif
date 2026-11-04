mod broker;
mod config;
mod mqtt_client;
mod monitor_client;

use std::error::Error;
use tokio::time::{sleep, Duration};

#[tokio::main]
async fn main() -> Result<(), Box<dyn Error>> {
    println!("Starting Mints MQTT...");
    println!("Broker : {}:{}", config::BROKER_HOST, config::BROKER_PORT);
    println!("Topic  : {}", config::DEFAULT_TOPIC);

    broker::start_broker().await?;

    // Tunggu broker mulai aktif.
    sleep(Duration::from_secs(1)).await;

    let (client, eventloop) = mqtt_client::connect().await?;

    // Jalankan event loop agar koneksi MQTT tetap diproses.
    tokio::spawn(async move {
        if let Err(err) = mqtt_client::receive_messages(eventloop).await {
            eprintln!("MQTT event loop berhenti: {err}");
        }
    });

    // Kirim teks terus-menerus setiap 5 detik.
    mqtt_client::publish_messages(client).await;

    Ok(())
}