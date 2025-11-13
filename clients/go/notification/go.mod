module github.com/geniustechspace/api-contracts/gen/go/notification

go 1.23

require (
	google.golang.org/grpc v1.68.1
	google.golang.org/protobuf v1.35.2
	github.com/envoyproxy/protoc-gen-validate v1.1.0
	github.com/geniustechspace/api-contracts/gen/go/core v0.1.0
)

// Local development - replace with actual path
replace github.com/geniustechspace/api-contracts/gen/go/core => ../core
