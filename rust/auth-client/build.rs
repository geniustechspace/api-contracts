fn main() -> Result<(), Box<dyn std::error::Error>> {
    tonic_build::configure()
        .build_server(false)
        .build_client(true)
        .out_dir("src/proto")
        .compile(
            &[
                "../../proto/auth/v1/auth.proto",
            ],
            &["../../proto"],
        )?;
    Ok(())
}
