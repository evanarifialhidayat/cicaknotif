use sysinfo::System;
// use std::time::{SystemTime, UNIX_EPOCH};
use chrono::{Local};

pub fn get_ram_report(system: &mut System) -> String {
    system.refresh_memory();
    let total = system.total_memory();
    let available = system.available_memory();
    let used = total.saturating_sub(available);
    let usage_percent = if total > 0 {
        used as f64 / total as f64 * 100.0
    } else {
        0.0
    };
    let now = Local::now().format("%d-%b-%Y").to_string();
    let computer_name = std::env::var("COMPUTERNAME").unwrap_or_else(|_| "Unknown".to_string());
    // let now = SystemTime::now().duration_since(UNIX_EPOCH).unwrap_or_default().as_secs();

    format!(
        "MONITORING DIVACE..\n\
         Komputer          : {}\n\
         Unix timestamp    : {}\n\
         Total RAM         : {:.2} GB\n\
         RAM Terpakai      : {:.2} GB\n\
         RAM Tersedia      : {:.2} GB\n\
         Penggunaan RAM    : {:.2}%\n",
        computer_name,
        now,
        format_gb(total),
        format_gb(used),
        format_gb(available),
        usage_percent
    )
}

fn format_gb(bytes: u64) -> f64 {
    bytes as f64 / 1_073_741_824.0
}