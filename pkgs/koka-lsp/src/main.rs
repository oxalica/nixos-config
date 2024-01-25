/// SPDX-License-Identifier: MIT or Apache-2.0
///
/// This is a wrapper for `koka --language-server --lsport=PORT` to
/// direct TCP based LSP into stdio based ones.
///
/// Usage: `koka-lsp KOKA_PATH [ARGUMENTS...]`
///
/// Note that required arguments `--language-server` and `--lsport` will be automatically prepended
/// thus does not need to be specified manually.
use std::io;
use std::process::{Command, Stdio};
use std::sync::mpsc;

use anyhow::{ensure, Context, Result};

fn main() -> Result<()> {
    let mut args = std::env::args_os().skip(1).collect::<Vec<_>>();
    ensure!(!args.is_empty(), "USAGE: koka-lsp KOKA_PATH [ARGUMENTS...]");

    let listener =
        std::net::TcpListener::bind("127.0.0.1:0").context("failed to bind to 127.0.0.1:0")?;
    let local_port = listener
        .local_addr()
        .context("failed to get listen address")?
        .port();
    let (tx, rx) = mpsc::sync_channel(1);
    // This thread is detached since `accept` can block forever.
    std::thread::spawn({
        let tx = tx.clone();
        move || tx.send(listener.accept().context("failed to accept TCP connection"))
    });

    // Prepend.
    args.splice(
        1..1,
        [
            "--language-server".into(),
            format!("--lsport={local_port}").into(),
        ],
    );

    let mut child = Command::new(&args[0])
        .args(&args[1..])
        .stdin(Stdio::null())
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()
        .context("failed to start command")?;
    let ch_stdout = child.stdout.take().unwrap();
    let ch_stderr = child.stderr.take().unwrap();

    std::thread::scope::<_, anyhow::Result<()>>(|s| {
        s.spawn(move || {
            if let Err(err) = child.wait().context("failed to wait child").and_then(|st| {
                ensure!(st.success(), "child exited with {st}");
                Ok(())
            }) {
                let _ = tx.send(Err(err));
            }
        });

        fn spawn_copy<'s, 'e>(
            s: &'s std::thread::Scope<'s, 'e>,
            msg: &'static str,
            mut from: impl io::Read + Send + 's,
            mut to: impl io::Write + Send + 's,
        ) {
            s.spawn(move || {
                if let Err(err) = io::copy(&mut from, &mut to) {
                    eprintln!("failed to {msg}: {err}");
                }
            });
        }

        spawn_copy(s, "redirect stdout", ch_stdout, io::stderr());
        spawn_copy(s, "redirect stderr", ch_stderr, io::stderr());
        let (stream, _) = rx.recv().context("listener panicked")??;
        let stream_tx @ stream_rx = &stream;
        std::thread::scope(|s| {
            spawn_copy(s, "redirect TCP inbound", io::stdin(), stream_tx);
            spawn_copy(s, "redirect TCP outbound", stream_rx, io::stdout());
        });

        Ok(())
    })
}
