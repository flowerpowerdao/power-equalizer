#!/bin/bash

# Get current time in seconds since Unix epoch
current_time=$(date +%s)

# Convert offset in minutes to seconds
offset_in_minutes=$1
offset_in_seconds=$((offset_in_minutes * 60))

# Calculate new timestamp in seconds since Unix epoch
new_timestamp=$((current_time + offset_in_seconds))

# Convert new timestamp to nanoseconds
new_timestamp_ns=$((new_timestamp * 1000000000))

# Print the new timestamp in nanoseconds
echo $new_timestamp_ns
