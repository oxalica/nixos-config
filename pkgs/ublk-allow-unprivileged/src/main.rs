// SPDX-License-Identifier: MIT or Apache-2.0
// Modified from: https://github.com/ublk-org/libublk-rs/blob/357359bd228031ff1c6765c5a5769f68bdd0fc2e/utils/ublk_user_id_rs.rs

fn main() {
    let s = std::env::args().nth(1).expect("missing argument");
    assert!(
        s.starts_with("ublkb") || s.starts_with("ublkc"),
        "unexpected device",
    );
    let id = s[5..].parse::<i32>().expect("invalid id");

    let ctrl = libublk::ctrl::UblkCtrl::new_simple(id, 0).expect("failed to open control device");
    let dinfo = &ctrl.dev_info;
    if (dinfo.flags & libublk::sys::UBLK_F_UNPRIVILEGED_DEV as u64) != 0 {
        std::os::unix::fs::lchown(
            format!("/dev/{s}"),
            Some(dinfo.owner_uid),
            Some(dinfo.owner_gid),
        )
        .expect("failed to lchown");
    } else {
        // Not applicatable.
        std::process::exit(-1);
    }
}
