fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Build configuration will be handled by buf generate
    // This file exists for compatibility with cargo build system
    println!("cargo:rerun-if-changed=../../proto/core/");
    Ok(())
}
