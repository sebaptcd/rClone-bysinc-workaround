#!/bin/bash

# sudo apt install libnotify-bin
# for the notifications to work

# Add to crontab at the very top: XDG_RUNTIME_DIR="/run/user/1000"
export DISPLAY=:0

# Declare the timestamps
get_timestamp() {
    date +%Y-%m-%d_%H%M%S
}

get_secTimestamp() {
	date +%s
}

# Get script's directory name to use as relative path
script_dir=$(dirname "$(realpath "$0")")
echo "$script_dir"

# Link to private variables such as file paths
source "$script_dir/../0. Private/rClone-bysinc-workaround/var.sh"

# Declare the machine ID
machineID=$(cat $Setups/rClone-bysinc-workaround/machineID.txt)

# Pointing the sync control variables
syncControl_dir="${SyncControl_root}syncControl/"
syncControl_lock="${SyncControl_root}syncControl/syncTime.lock"
syncControl_local_lock="$Setups/rClone-bysinc-workaround/Locks/syncTime.lock"

# "$Setups" is the local path for the script, declared in "var.sh"
sync_lock="$Setups/rClone-bysinc-workaround/Locks/Sync.lock"
boot_lock="$Setups/rClone-bysinc-workaround/Locks/Boot-Sync.lock"
boot_ran_lock="$Setups/rClone-bysinc-workaround/Locks/Boot-Ran.lock"
logs="$Setups/rClone-bysinc-workaround/Logs"

# Path to the rClone bin (the "recycle_bin_root" is declared in the private variables "var.sh")
recycle_bin="$recycle_bin_root/rClone bin"

# Define the active syncing process
mark_active_sync() {
	while true; do
		# Mark that a syncing process has started on this machine
		echo "$(get_secTimestamp) $machineID" > $syncControl_local_lock
		rclone copy $syncControl_local_lock $syncControl_dir
		echo "syncControl mark updated on $(get_timestamp)"
		sleep 15
	done &
	# Define the process so it can be targeted later
	active_sync=$!
	echo "Process $active_sync defined."
}

# Declare the sync/bisync flags
common_flags=(
    --transfers 64
    --checkers 48
    --create-empty-src-dirs
    --progress
    --local-links
    --log-level INFO
)

sync_flags=(
	--update
)

sync_server_local_flags=(
	--backup-dir PLACEHOLDER_TIMESTAMP
)

sync_local_server_flags=(

)

bisync_flags=(
	--fix-case
	--force
	--recover
	--resilient
	--max-lock 600
)

while true; do
	# Check if the internet connection is available
	if ping -c 1 8.8.8.8 &> /dev/null; then
		# Check if Syncing is not already running or did not finish properly
		if [ -f "$sync_lock" ]; then
			echo "Syncing: Past instance found, reloading in 5 minutes..."
			notify-send "Syncing" "Past instance found, reloading in 5 minutes..."
			mv "$sync_lock" "$logs/Sync/Canceled/Canceled_Sync_$(get_timestamp).log"
			rm $syncControl_local_lock
			sleep 300
		elif [ -f "$boot_ran_lock" ]; then
			echo "Syncing: Past instance found, reloading in 5 minutes..."
			notify-send "Syncing" "Past instance found, reloading in 5 minutes..."
			mv "$boot_ran_lock" "$logs/Boot/Canceled/Canceled_Boot_$(get_timestamp).log"
			rm $syncControl_local_lock
			sleep 300
		# Start new syncing instance.
		elif [ ! -f "$sync_lock" ]; then
			# Check and prepare Boot Sync
			# Check if Boot Syncing is not already running
			if [ -f "$boot_lock" ] && [ $(ps aux | grep "Syncing.sh" | grep -v "grep" | wc -l) -ge 4 ]; then
				# Notify that the Boot Syncing is running already and abort
				echo "Syncing: Boot Sync already running, aborting."
				# DEBUG: Feedback for how many instances are being detected
				#echo $(( $(ps aux | grep "Syncing.sh" | grep -v "grep" | wc -l) ))
				#notify-send $(( $(ps aux | grep "Syncing.sh" | grep -v "grep" | wc -l) ))
				notify-send "Syncing" "Boot Sync already running, aborting. Possible false positive if hidden files are enabled. Hide them back and restart."
				exit 1
			# Check if Boot Syncing was interrupted mid sync but no longer runs
			elif [ -f "$boot_lock" ] && ! [ $(ps aux | grep "Syncing.sh" | grep -v "grep" | wc -l) -ge 4 ]; then
				echo "Syncing: Active past instance found, reloading in 5 minutes..."
				# DEBUG: Feedback for how many instances are being detected
				#echo $(( $(ps aux | grep "Syncing.sh" | grep -v "grep" | wc -l) ))
				#notify-send $(( $(ps aux | grep "Syncing.sh" | grep -v "grep" | wc -l) ))
				notify-send "Syncing" "Active past instance found, reloading in 5 minutes..."
				mv "$boot_lock" "$logs/Boot/Canceled/Canceled_Boot_$(get_timestamp).log"
				rm $syncControl_local_lock
				sleep 300
			elif [ ! -f "$boot_lock" ]; then
				# Notify that the Boot Syncing will start
				echo "Syncing: Starting new instance in 30 seconds..."
				# DEBUG: Feedback for how many instances are being detected
				#echo $(( $(ps aux | grep "Syncing.sh" | grep -v "grep" | wc -l) ))

				# Mark that the Boot Syncing has started
				touch "$boot_lock"
				notify-send "Syncing" "New instance marked, starting in 30 seconds..."

				# Give 30 seconds response time for any processes to detect the boot lock
				sleep 30

				# Check if rClone is up to date
				echo "Syncing: Checking and updating rClone..."
				rclone selfupdate --check 2>&1 | {
					# Read the first line
					read -r first_line
					echo "$first_line"
					first_line_version=$(echo $first_line | awk '{print $2}')
					echo $first_line_version

					# Read the second line
					read -r second_line
					echo "$second_line"
					second_line_version=$(echo $second_line | awk '{print $2}')
					echo $second_line_version

					if [[ "$first_line_version" == "$second_line_version" ]]; then
						echo "Latest version installed: $first_line_version"
					else
						notify-send "Syncing" "Update to $second_line_version available. Waiting 5 minutes to update..."
						sleep 300
					fi
				} >> >(tee -a "$boot_lock") 2>&1

				# Check and log if another syncing process is ongoing on another machine
				{
					while true; do
						# Stop the syncing if an ongoing process already exists on another machine
						if [ "$(rclone lsf $syncControl_lock)" == "syncTime.lock" ]; then
							# But first check if the lock is still active
							# Get the current date and time in seconds since epoch
							echo $(get_secTimestamp)
							# Read the time from syncTime.lock
							syncControl_lock_value=$(rclone cat $syncControl_lock)
							echo $syncControl_lock_value
							# Split the data to separate the machineID from the time
							syncControl_lock_time_value=$(echo $syncControl_lock_value | awk '{print $1}')
							echo $syncControl_lock_time_value
							# Calculate the difference in seconds
							time_difference=$(($(get_secTimestamp) - syncControl_lock_time_value))
							echo "Time difference is $time_difference"
							if [ $time_difference -lt 120 ]; then
								echo "Ongoing sync on another machine, waiting..."
								notify-send "Syncing" "Ongoing sync on another machine, waiting..."
								sleep 60
							# If the lock is not active, delete it.
							else
								rclone delete $syncControl_lock
								echo "Inactive sync lock found and deleted."
								notify-send "Syncing:" "Inactive sync lock found and deleted."
							fi
						# Mark that a syncing process has started on this machine
						else
							echo "No ongoing sync across machines."

							mark_active_sync

							break
						fi
					done
				} >> >(tee -a "$boot_lock") 2>&1

				# Notify that the Boot Syncing starts
				echo "Syncing: Boot Sync started."
				notify-send "Syncing" "Boot Sync started."
				sleep 10

				# ============== THE SYNC ==============

				# This variable instructs the script to replace "PLACEHOLDER_TIMESTAMP" in the "sync_server_local_flags" variable with "$recycle_bin/$(get_timestamp)"
				dynamic_sync_server_local_flags=("${sync_server_local_flags[@]//PLACEHOLDER_TIMESTAMP/$recycle_bin/$(get_timestamp)}")

				# Personal
				rclone sync "${common_flags[@]}" "${sync_flags[@]}" "${dynamic_sync_server_local_flags[@]}" "$Personal_remote" "$Persoanl_local" 2>&1 | while read line; do
					# Check for errors
					if [[ "$line" == *"ERROR"* || "$line" == *"Errors:"* ]]; then
						notify-send "Syncing Error:" "$line"
					fi
					echo "$line" >> "$boot_lock"
				done

				# Personal (resyncing the paths)
				rclone bisync --resync "${common_flags[@]}" "${bisync_flags[@]}" "$Persoanl_local" "$Personal_remote" 2>&1 | while read line; do
					# Check for errors
					if [[ "$line" == *".conflict"* || "$line" == *"ERROR"* || "$line" == *"Errors:"* ]]; then
						notify-send "Syncing Error:" "$line"
					fi
					echo "$line" >> "$boot_lock"
				done

				# ======================================

				# Personal/Public
				rclone bisync "${common_flags[@]}" "${bisync_flags[@]}" "$PersonalPb_remote" "$PersoanlPb_local" 2>&1 | while read line; do
					# Check for errors
					if [[ "$line" == *".conflict"* || "$line" == *"ERROR"* || "$line" == *"Errors:"* ]]; then
						notify-send "Syncing Error:" "$line"
					fi
					echo "$line" >> "$boot_lock"
				done

				# Dev
				rclone bisync "${common_flags[@]}" "${bisync_flags[@]}" "$Dev_remote" "$Dev_local" 2>&1 | while read line; do
					# Check for errors
					if [[ "$line" == *".conflict"* || "$line" == *"ERROR"* || "$line" == *"Errors:"* ]]; then
						notify-send "Syncing Error:" "$line"
					fi
					echo "$line" >> "$boot_lock"
				done

				# WORKSTATION
				rclone bisync "${common_flags[@]}" "${bisync_flags[@]}" "$WORKSTATION_remote" "$WORKSTATION_local" 2>&1 | while read line; do
					# Check for errors
					if [[ "$line" == *".conflict"* || "$line" == *"ERROR"* || "$line" == *"Errors:"* ]]; then
						notify-send "Syncing Error:" "$line"
					fi
					echo "$line" >> "$boot_lock"
				done

				# Mark that the syncing process has finished on this machine
				{
					echo "Process $active_sync confirmed for termination."
					kill $active_sync
					rm $syncControl_local_lock
					rclone delete $syncControl_lock
					echo "syncControl mark removed."
				} >> >(tee -a "$boot_lock") 2>&1

				# Mark that the Boot Syncing is complete
				mv "$boot_lock" "$logs/Boot/Boot_$(get_timestamp).log"
				touch "$boot_ran_lock"
				# Notify that the Boot Syncing is complete
				echo "Syncing: Boot Sync completed."
				notify-send "Syncing" "Boot Sync completed."
				sleep 5
				# Notify & mark that the syncing cycle will begin in 5 minutes
				echo "Syncing: Cycle will begin in 5 minutes."
				notify-send "Syncing" "Cycle will begin in 5 minutes."
				sleep 300

				# Check if the boot command ran
				if [ ! -f "$boot_ran_lock" ]; then
					# Notify that the Boot Syncing did not ran and reload
					echo "Syncing: Boot Sync did not happen yet, reloading..."
					notify-send "Syncing" "Boot Sync did not happen yet, reloading..."
					sleep 10
				elif [ -f "$boot_ran_lock" ]; then
					# Remove the mark that boot ran did happen for future instances
					rm "$boot_ran_lock"

					while true; do
						# Check if the internet connection is available
						if ping -c 1 8.8.8.8 &> /dev/null; then

							# ==============================
							# Cycle begins now, in this loop
							# ==============================

							# Check if another instance has started in parallel
							if [ -f "$boot_lock" ] || [ -f "$boot_ran_lock" ]; then
								# Notify that another instance started
								echo "Syncing: Second instance detected, aborting."
								notify-send "Syncing" "Second instance detected, aborting."
								exit 1
							elif [ -f "$sync_lock" ]; then
								echo "Syncing: Second instance detected, aborting."
								notify-send "Syncing" "Second instance detected, aborting."
								exit 1
							elif [ ! -f "$sync_lock" ]; then

								# Mark that the syncing cycle will start
								touch "$sync_lock"

								# Give 1 minute response time for any processes to detect the sync lock
								sleep 60

								# Check and log if another syncing process is ongoing on another machine
								{
									while true; do
										# Stop the syncing if an ongoing process already exists on another machine
										if [ "$(rclone lsf $syncControl_lock)" == "syncTime.lock" ]; then
											# But first check if the lock is still active
											# Get the current date and time in seconds since epoch
											echo $(get_secTimestamp)
											# Read the time from syncTime.lock
											syncControl_lock_value=$(rclone cat $syncControl_lock)
											echo $syncControl_lock_value
											# Split the data to separate the machineID from the time
											syncControl_lock_time_value=$(echo $syncControl_lock_value | awk '{print $1}')
											echo $syncControl_lock_time_value
											# Calculate the difference in seconds
											time_difference=$(($(get_secTimestamp) - syncControl_lock_time_value))
											echo "Time difference is $time_difference"
											if [ $time_difference -lt 120 ]; then
												echo "Ongoing sync on another machine, waiting..."
												notify-send "Syncing" "Ongoing sync on another machine, waiting..."
												sleep 60
											# If the lock is not active, delete it.
											else
												rclone delete $syncControl_lock
												echo "Inactive sync lock found and deleted."
												notify-send "Syncing:" "Inactive sync lock found and deleted."
											fi
										# Mark that a syncing process has started on this machine
										else
											echo "No ongoing sync across machines."

											mark_active_sync

											break
										fi
									done
								} >> >(tee -a "$sync_lock") 2>&1

								# Log that the syncing cycle will start
								echo "Syncing: Starting..."

								# ============== THE SYNC ==============

								# This variable instructs the script to replace "PLACEHOLDER_TIMESTAMP" in the "sync_server_local_flags" variable with "$recycle_bin/$(get_timestamp)"
								dynamic_sync_server_local_flags=("${sync_server_local_flags[@]//PLACEHOLDER_TIMESTAMP/$recycle_bin/$(get_timestamp)}")

								# Personal (local backup / rClone Bin)
								rclone sync "${common_flags[@]}" "${sync_flags[@]}" "${dynamic_sync_server_local_flags[@]}" "$Persoanl_local" "$Persoanl_local_backup" 2>&1 | while read line; do
									# Check for errors
									if [[ "$line" == *"ERROR"* || "$line" == *"Errors:"* ]]; then
										notify-send "Syncing Error:" "$line"
									fi
									echo "$line" >> "$sync_lock"
								done

								# Personal
								rclone bisync "${common_flags[@]}" "${bisync_flags[@]}" "$Persoanl_local" "$Personal_remote" 2>&1 | while read line; do
									# Check for errors
									if [[ "$line" == *".conflict"* || "$line" == *"ERROR"* || "$line" == *"Errors:"* ]]; then
										notify-send "Syncing Error:" "$line"
									fi
									echo "$line" >> "$sync_lock"
								done

								# ======================================

								# Personal/Public
								rclone bisync "${common_flags[@]}" "${bisync_flags[@]}" "$PersonalPb_remote" "$PersoanlPb_local" 2>&1 | while read line; do
									# Check for errors
									if [[ "$line" == *".conflict"* || "$line" == *"ERROR"* || "$line" == *"Errors:"* ]]; then
										notify-send "Syncing Error:" "$line"
									fi
									echo "$line" >> "$sync_lock"
								done

								# Dev
								rclone bisync "${common_flags[@]}" "${bisync_flags[@]}" "$Dev_remote" "$Dev_local" 2>&1 | while read line; do
									# Check for errors
									if [[ "$line" == *".conflict"* || "$line" == *"ERROR"* || "$line" == *"Errors:"* ]]; then
										notify-send "Syncing Error:" "$line"
									fi
									echo "$line" >> "$sync_lock"
								done

								# WORKSTATION
								rclone bisync "${common_flags[@]}" "${bisync_flags[@]}" "$WORKSTATION_remote" "$WORKSTATION_local" 2>&1 | while read line; do
									# Check for errors
									if [[ "$line" == *".conflict"* || "$line" == *"ERROR"* || "$line" == *"Errors:"* ]]; then
										notify-send "Syncing Error:" "$line"
									fi
									echo "$line" >> "$sync_lock"
								done

								# Mark that the syncing process has finished on this machine
								{
									echo "Process $active_sync confirmed for termination."
									kill $active_sync
									rm $syncControl_local_lock
									rclone delete $syncControl_lock
									echo "syncControl mark removed."
								} >> >(tee -a "$sync_lock") 2>&1

								# Mark that the syncing cycle was completed
								mv "$sync_lock" "$logs/Sync/Sync_$(get_timestamp).log"
								# Log that the syncing cycle was completed
								echo "Syncing: Complete."
								# Give a 5 minutes cool-down before the next cycle
								sleep 300
							fi
						else
							# No internet connection
							echo "No internet. Reloading in 1 minute."
							notify-send "Syncing" "(Cycle) No internet. Retrying in 1 minute."
							sleep 60
						fi
					done
				fi
			fi
		fi
	else
		# No internet connection
		echo "No internet. Reloading in 1 minute."
		notify-send "Syncing" "(Boot) No internet. Retrying in 1 minute."
		sleep 60
	fi
done
