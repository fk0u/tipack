// Sembunyikan jendela konsol tambahan di Windows (release)
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

fn main() {
    tipack_lib::run()
}
