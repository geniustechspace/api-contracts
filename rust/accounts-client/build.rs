fn main() -> Result<(), Box<dyn std::error::Error>> {
    tonic_build::configure()
        .build_server(false)
        .build_client(true)
        .out_dir("src/proto")
        .compile(
            &[
                "../../proto/accounts/v1/accounts.proto",
            ],
            &["../../proto"],
        )?;
    Ok(())
}