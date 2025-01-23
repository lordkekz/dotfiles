// Based on: https://gist.github.com/fragsalat/d55cc7a88ed56a97b89c2e13362a58a8

use log::{debug, error};
use std::net::{TcpListener, SocketAddr, TcpStream, Shutdown};
use std::thread::{spawn, JoinHandle};
use std::io::{Read, Write};

fn pipe(incoming: &mut TcpStream, outgoing: &mut TcpStream) -> Result<(), String> {
    let mut buffer = [0; 1024];
    loop {
        match incoming.read(&mut buffer) {
            Ok(bytes_read) => {
                // Socket is disconnected => Shutdown the other socket as well
                if bytes_read == 0 {
                    let _ = outgoing.shutdown(Shutdown::Both);
                    break;
                }
                if outgoing.write(&buffer[..bytes_read]).is_ok() {
                    let _ = outgoing.flush();
                }
            },
            Err(error) => return Err(format!("Could not read data: {}", error))
        }
    }
    Ok(())
}

fn proxy_connection(mut incoming: TcpStream, target: &SocketAddr) -> Result<(), String> {
    debug!("Client connected from: {:#?}", incoming.peer_addr());

    let mut outgoing = TcpStream::connect(target)
        .map_err(|error| format!("Could not establish connection to {}: {}", target, error))?;

    let mut incoming_clone = incoming.try_clone().map_err(|e| e.to_string())?;
    let mut outgoing_clone = outgoing.try_clone().map_err(|e| e.to_string())?;

    // Pipe for- and backward asynchronously
    let forward = spawn(move || pipe(&mut incoming, &mut outgoing));
    let backward = spawn(move || pipe(&mut outgoing_clone, &mut incoming_clone));

    debug!("Proxying data...");
    let _ = forward.join().map_err(|error| format!("Forward failed: {:?}", error))?;
    let _ = backward.join().map_err(|error| format!("Backward failed: {:?}", error))?;

    debug!("Socket closed");

    Ok(())
}

fn proxy(local_port: u16, target_addr: SocketAddr) -> JoinHandle<()> {
    let listener = TcpListener::bind(SocketAddr::from(([0, 0, 0, 0], local_port))).unwrap();
    // One thread per port listener
    spawn(move || {
        for socket in listener.incoming() {
            let socket = match socket {
                Ok(socket) => socket,
                Err(error) => {
                    error!("Could not handle connection: {}", error);
                    return;
                }
            };
            // One thread per connection
            spawn(move || {
                if let Err(error) = proxy_connection(socket, &target_addr) {
                    error!("{}", error);
                }
            });
        }
    })
}

struct Mapping {
  local_port: u16,
  target_address: String
}

fn start_proxies(mappings: Vec<Mapping>) {
    let mut handles: Vec<JoinHandle<()>> = Vec::new();
    for mapping in mappings {
        let _ = &handles.push(proxy(
            mapping.local_port,
            mapping.target_address.parse::<SocketAddr>().unwrap()
        ));
    }

    for handle in handles {
        let _ = handle.join();
    }
}

fn main() {
  let mappings = vec![Mapping { local_port: 25565, target_address: "100.80.80.2:25566".to_string()}];

  start_proxies(mappings);
}
