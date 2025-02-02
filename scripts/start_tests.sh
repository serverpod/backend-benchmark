#!/bin/bash

# Script name: run_docker_build_and_run.sh
#!/bin/bash


#!/bin/bash
#!/bin/bash



# Save the current directory
dir=$(pwd)

# Flag to check if the script is found
found=0

# Loop through the current and parent directories
while true; do
  # Check if the script exists in the current directory
  if [[ -f "$dir/internal_scripts/set_required_envs.sh" ]]; then
    # Script found, execute it
    echo "Found script at $dir/internal_scripts/set_required_envs.sh"
    . "$dir/internal_scripts/set_required_envs.sh"
    found=1
    break
  else
    # Move to the parent directory
    parentdir=$(dirname "$dir")
    # Check if we have reached the root directory
    if [[ "$dir" == "$parentdir" ]]; then
      break
    fi
    dir=$parentdir
  fi
done

# Check if script was not found
if [[ $found -eq 0 ]]; then
  echo "Script not found."
  exit 1
fi


cd ..
# Find all 'docker_build_and_run.sh' files and store them in an array
scripts=($(find . -name 'docker_build_and_run.sh'))

# Get total number of scripts and multiply by 2 for the two test types
total_scripts=$((${#scripts[@]} * 2))

# Initialize a counter
counter=1

# Define the test types
test_types=("db_test" "no_db_test")

for script in "${scripts[@]}"; do
    for test_type in "${test_types[@]}"; do
        # Calculate total remaining runtime
        remaining_tests=$((total_scripts - counter + 1))
        total_remaining_seconds=$((remaining_tests * LOCUST_RUNTIME))
        minutes=$((total_remaining_seconds / 60))
        seconds=$((total_remaining_seconds % 60))

        echo "Running script $counter out of $total_scripts: $script with test_type=$test_type"
        echo "Estimated remaining time: $minutes minutes, $seconds seconds"
        
        export test_type=$test_type
        bash "$script"
        echo "Finished running: $script with test_type=$test_type"

        # Increment the counter
        ((counter++))
        echo "Sleeping for 5 seconds..."
        sleep 5
    done
done
cd scripts/graphs
bash create_graphs.sh