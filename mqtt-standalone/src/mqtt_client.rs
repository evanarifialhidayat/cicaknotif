use rumqttc::{
    AsyncClient, Event, EventLoop, MqttOptions, Packet, QoS,
};

use std::error::Error;
use std::time::Duration;
use tokio::time::sleep;

use crate::config::*;

use sysinfo::System;
use crate::monitor_client::get_ram_report;

pub async fn connect() -> Result<(AsyncClient, EventLoop), Box<dyn Error>> {
    let mut options = MqttOptions::new(
        CLIENT_ID, 
        MQTT_CLIENT_HOST, 
        BROKER_PORT
    );
    options.set_keep_alive(Duration::from_secs(KEEP_ALIVE));
    let (client, eventloop) = AsyncClient::new(options, 10);
    client.subscribe(DEFAULT_TOPIC, QoS::AtLeastOnce).await?;
    println!("Subscribe ke topic: {}", DEFAULT_TOPIC);
    Ok((client, eventloop))
}

pub async fn publish_messages(client: AsyncClient) {
    let mut system = System::new();
    loop {
        let message = get_ram_report(&mut system);
        match client.publish(DEFAULT_TOPIC, QoS::AtLeastOnce,false, message.clone(),).await
        {
            Ok(_) => {
                 println!("Laporan RAM berhasil dikirim: {}",  message.chars().count());
            }
            Err(e) => {
                 eprintln!("Gagal publish laporan RAM: {}", e);
            }
        }
        sleep(Duration::from_secs(PUBLISH_INTERVAL)).await;
    }
}

pub async fn receive_messages(
    mut eventloop: EventLoop,
) -> Result<(), Box<dyn Error>> {
    loop {
        match eventloop.poll().await {
            Ok(Event::Incoming(Packet::Publish(msg))) => {
                println!(
                    "{}",
                    String::from_utf8_lossy(&msg.payload)
                );
            }

            Ok(_) => {}

            Err(e) => {
                eprintln!("MQTT error: {}", e);
                sleep(Duration::from_secs(1)).await;
            }
        }
    }
}