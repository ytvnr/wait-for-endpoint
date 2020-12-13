@test "google should be immediately found" {
  run ./wait-for-endpoint.sh --quiet google.com -- echo 'success'

  [ "$status" -eq 0 ]
  [ "$output" = "success" ]
}

@test "google with 411 status for PUT request should start command" {
  run ./wait-for-endpoint.sh --quiet --status=411 --http-method=PUT google.com -- echo 'success'

  [ "$status" -eq 0 ]
  [ "$output" = "success" ]
}

@test "nonexistent server should not start command" {
  run ./wait-for-endpoint.sh -t 1 -i 1 noserver:9999 -- echo 'success'

  [ "$status" -ne 0 ]
  [ "$output" != "success" ]
}