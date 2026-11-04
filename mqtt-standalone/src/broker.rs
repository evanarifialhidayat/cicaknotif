use rumqttd::{Broker, Config as BrokerConfig};
use std::error::Error;
use tokio::task;

pub async fn start_broker() -> Result<(), Box<dyn Error>> {
    let config_path = format!(
        "{}/rumqttd.toml",
        env!("CARGO_MANIFEST_DIR")
    );

    let config = config::Config::builder()
        .add_source(config::File::with_name(&config_path))
        .build()?;

    let config: BrokerConfig = config.try_deserialize()?;
    let mut broker = Broker::new(config);

    // Broker berjalan di task terpisah; jangan await task ini.
    let _broker_task = task::spawn_blocking(move || {
        if let Err(error) = broker.start() {
            eprintln!("Broker error: {error}");
        }
    });

    println!("Broker task sudah dimulai.");
    Ok(())
}