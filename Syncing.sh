#!/bin/bash

# sudo apt install libnotify-bin
# for the notifications to work

# Add to crontab at the very top: XDG_RUNTIME_DIR="/run/user/1000"
export DISPLAY=:0

# Declare the timestamp
get_timestamp() {
    date +%Y-%m-%d_%H%M%S
}

# Get script's directory name to use as relative path
script_dir=$(dirname "$(realpath "$0")")
echo "$script_dir"

# Link to private variables such as file paths
source "$script_dir/../0. Private/rClone-bysinc-workaround/var.sh"

# "$Setups" is the local path for the script, declared in "var.sh"
sync_lock="$Setups/rClone-bysinc-workaround/Locks/Sync.lock"
boot_lock="$Setups/rClone-bysinc-workaround/Locks/Boot-Sync.lock"
boot_ran_lock="$Setups/rClone-bysinc-workaround/Locks/Boot-Ran.lock"
logs="$Setups/rClone-bysinc-workaround/Logs"

# Path to the rClone bin (the "recycle_bin_root" is declared in the private variables "var.sh")
recycle_bin="$recycle_bin_root/rClone bin"

# Declare the sync/bisync flags
common_flags=(
    --transfers 64
    --checkers 48
    --create-empty-src-dirs
    --progress
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
			sleep 300
		elif [ -f "$boot_ran_lock" ]; then
			echo "Syncing: Past instance found, reloading in 5 minutes..."
			notify-send "Syncing" "Past instance found, reloading in 5 minutes..."
			mv "$boot_ran_lock" "$logs/Boot/Canceled/Canceled_Boot_$(get_timestamp).log"
			sleep 300
		# Start new syncing instance.
		elif [ ! -f "$sync_lock" ]; then
			# Notify that a new instance will start.
			echo "Syncing: Starting new instance..."
			notify-send "Syncing" "Starting new instance..."
			sleep 10
			# Check and prepare Boot Sync
			# Check if Boot Syncing is not already running
			if [ -f "$boot_lock" ] && [ $(ps aux | grep "Syncing.sh" | grep -v "grep" | wc -l) -ge 4 ]; then
				# Notify that the Boot Syncing is running already and abort
				echo "Syncing: Boot Sync already running, aborting."
				# DEBUG: Feedback for how many instances are being detected
				#echo $(( $(ps aux | grep "Syncing.sh" | grep -v "grep" | wc -l) ))
				#notify-send $(( $(ps aux | grep "Syncing.sh" | grep -v "grep" | wc -l) ))
				notify-send "Syncing" "Boot Sync already running, aborting."
				exit 0
			# Check if Boot Syncing was interrupted mid sync but no longer runs
			elif [ -f "$boot_lock" ] && ! [ $(ps aux | grep "Syncing.sh" | grep -v "grep" | wc -l) -ge 4 ]; then
				echo "Syncing: Active past instance found, reloading in 5 minutes..."
				# DEBUG: Feedback for how many instances are being detected
				#echo $(( $(ps aux | grep "Syncing.sh" | grep -v "grep" | wc -l) ))
				#notify-send $(( $(ps aux | grep "Syncing.sh" | grep -v "grep" | wc -l) ))
				notify-send "Syncing" "Active past instance found, reloading in 5 minutes..."
				mv "$boot_lock" "$logs/Boot/Canceled/Canceled_Boot_$(get_timestamp).log"
				sleep 300
			elif [ ! -f "$boot_lock" ]; then
				# Notify that the Boot Syncing will start
				echo "Syncing: Boot Sync starts in 30 seconds..."
				# DEBUG: Feedback for how many instances are being detected
				#echo $(( $(ps aux | grep "Syncing.sh" | grep -v "grep" | wc -l) ))
				notify-send "Syncing" "Boot Sync starts in 30 seconds..."
				sleep 30

				#
				# rclone sync | server -> local
				#

				while true; do

					dynamic_sync_server_local_flags=("${sync_server_local_flags[@]//PLACEHOLDER_TIMESTAMP/$recycle_bin/$(get_timestamp)}")

					# Check if the internet connection is available
					if ping -c 1 8.8.8.8 &> /dev/null; then

						# Mark that the Boot Syncing has started
						touch "$boot_lock"
						# Notify that the Boot Syncing starts
						echo "Syncing: Boot Sync started."
						notify-send "Syncing" "Boot Sync started."
						sleep 10

						# ============== THE SYNC ==============

						# Personal
						rclone sync "${common_flags[@]}" "${sync_flags[@]}" "${dynamic_sync_server_local_flags[@]}" "$Personal_remote" "$Persoanl_local" | while read line; do
							# Check for errors
							if [[ "$line" == *"ERROR"* || "$line" == *"Errors:"* ]]; then
								# Send a notification
								notify-send "Syncing Error:" "$line"
							fi
							echo "$line" >> "$boot_lock"
						done

						# Personal (resyncing the paths)
						rclone bisync --resync "${common_flags[@]}" "${bisync_flags[@]}" "$Persoanl_local" "$Personal_remote" | while read line; do
							# Check for errors
							if [[ "$line" == *".conflict"* || "$line" == *"ERROR"* || "$line" == *"Errors:"* ]]; then
								# Send a notification
								notify-send "Syncing Error:" "$line"
							fi
							echo "$line" >> "$boot_lock"
						done

						# ======================================

						while true; do
							# Check if the internet connection is available
							if ping -c 1 8.8.8.8 &> /dev/null; then

								# Personal/Public
								rclone bisync "${common_flags[@]}" "${bisync_flags[@]}" "$PersonalPb_remote" "$PersoanlPb_local" | while read line; do
									# Check for errors
									if [[ "$line" == *".conflict"* || "$line" == *"ERROR"* || "$line" == *"Errors:"* ]]; then
										# Send a notification
										notify-send "Syncing Error:" "$line"
									fi
									echo "$line" >> "$boot_lock"
								done

								while true; do
									# Check if the internet connection is available
									if ping -c 1 8.8.8.8 &> /dev/null; then

										# Dev
										rclone bisync "${common_flags[@]}" "${bisync_flags[@]}" "$Dev_remote" "$Dev_local" | while read line; do
											# Check for errors
											if [[ "$line" == *".conflict"* || "$line" == *"ERROR"* || "$line" == *"Errors:"* ]]; then
												# Send a notification
												notify-send "Syncing Error:" "$line"
											fi
											echo "$line" >> "$boot_lock"
										done

										while true; do
											# Check if the internet connection is available
											if ping -c 1 8.8.8.8 &> /dev/null; then

												# WORKSTATION
												rclone bisync "${common_flags[@]}" "${bisync_flags[@]}" "$WORKSTATION_remote" "$WORKSTATION_local" | while read line; do
													# Check for errors
													if [[ "$line" == *".conflict"* || "$line" == *"ERROR"* || "$line" == *"Errors:"* ]]; then
														# Send a notification
														notify-send "Syncing Error:" "$line"
													fi
													echo "$line" >> "$boot_lock"
												done

												# Mark that the Boot Syncing is complete
												mv "$boot_lock" "$logs/Boot/Boot_$(get_timestamp).log"
												touch "$boot_ran_lock"
												# Notify that the Boot Syncing is complete
												echo "Syncing: Boot Sync completed."
												notify-send "Syncing" "Boot Sync completed."
												sleep 10
												# Notify that the syncing cycle will begin in 10 minutes
												echo "Syncing: Cycle will begin in 10 minutes."
												notify-send "Syncing" "Cycle will begin in 10 minutes."
												# Mark that the syncing cycle will begin in 10 minutes
												sleep 600

												# Check if the boot command ran
												if [ ! -f "$boot_ran_lock" ]; then
													# Notify that the Boot Syncing did not ran and abort
													echo "Syncing: Boot Sync did not happen yet, reloading..."
													notify-send "Syncing" "Boot Sync did not happen yet, reloading..."
													sleep 10
												elif [ -f "$boot_ran_lock" ]; then
													# Remove the mark that boot ran did happen for future instances
													rm "$boot_ran_lock"

													while true; do

													# ==============================
													# Cycle begins now, in this loop
													# ==============================

													dynamic_sync_server_local_flags=("${sync_server_local_flags[@]//PLACEHOLDER_TIMESTAMP/$recycle_bin/$(get_timestamp)}")

														# Check if another instance has started in parallel
														if [ -f "$boot_lock" ] || [ -f "$boot_ran_lock" ]; then
															# Notify that another instance started
															echo "Syncing: Second instance detected, aborting."
															notify-send "Syncing" "Second instance detected, aborting."
															exit 0
														# Check if the internet connection is available
														elif ping -c 1 8.8.8.8 &> /dev/null; then
															if [ ! -f "$sync_lock" ]; then

																#
																# rclone sync | local -> server
																#

																# Mark that the syncing cycle will start
																touch "$sync_lock"
																# Notify that the syncing cycle will start
																echo "Syncing: Starting in 30 seconds..."
																#notify-send "Syncing" "Starting in 30 seconds..."
																# Give a 30 seconds response time
																sleep 30

																while true; do
																	# Check if the internet connection is available
																	if ping -c 1 8.8.8.8 &> /dev/null; then

																		# Notify that syncing local -> server will start
																		#echo "Syncing: Uploading on the server..."
																		#notify-send "Syncing" "Uploading on the server..."
																		#sleep 10

																		# Personal
																		#rclone sync "${common_flags[@]}" "${sync_flags[@]}" "${sync_local_server_flags[@]}" "$Persoanl_local" "$Personal_remote" | while read line; do
																			# Check for errors
																		#	if [[ "$line" == *"ERROR"* || "$line" == *"Errors:"* ]]; then
																		#		# Send a notification
																		#		notify-send "Syncing Error:" "$line"
																		#	fi
																		#	echo "$line" >> "$sync_lock"
																		#done

																		while true; do
																			# Check if the internet connection is available
																			#if ping -c 1 8.8.8.8 &> /dev/null; then

																				# Personal/Public
																				#rclone bisync "${common_flags[@]}" "${bisync_flags[@]}" "$PersoanlPb_local" "$PersonalPb_remote" | while read line; do
																					# Check for errors
																				#	if [[ "$line" == *".conflict"* || "$line" == *"ERROR"* || "$line" == *"Errors:"* ]]; then
																				#		# Send a notification
																				#		notify-send "Syncing Error:" "$line"
																				#	fi
																				#	echo "$line" >> "$sync_lock"
																				#done

																				while true; do
																					# Check if the internet connection is available
																					#if ping -c 1 8.8.8.8 &> /dev/null; then

																						# Dev
																						#rclone bisync "${common_flags[@]}" "${bisync_flags[@]}" "$Dev_local" "$Dev_remote" | while read line; do
																						#	# Check for errors
																						#	if [[ "$line" == *".conflict"* || "$line" == *"ERROR"* || "$line" == *"Errors:"* ]]; then
																						#		# Send a notification
																						#		notify-send "Syncing Error:" "$line"
																						#	fi
																						#	echo "$line" >> "$sync_lock"
																						#done

																						while true; do
																							# Check if the internet connection is available
																							#if ping -c 1 8.8.8.8 &> /dev/null; then

																								# WORKSTATION
																								#rclone bisync "${common_flags[@]}" "${bisync_flags[@]}" "$WORKSTATION_local" "$WORKSTATION_remote" | while read line; do
																								#	# Check for errors
																								#	if [[ "$line" == *".conflict"* || "$line" == *"ERROR"* || "$line" == *"Errors:"* ]]; then
																								#		# Send a notification
																								#		notify-send "Syncing Error:" "$line"
																								#	fi
																								#	echo "$line" >> "$sync_lock"
																								#done

																								# Notify that syncing local -> server was completed
																								#echo "Syncing: Server upload - done."
																								#notify-send "Syncing" "Server upload - done."
																								#sleep 10

																								#
																								# rclone sync | server -> local
																								#

																								while true; do
																									# Check if the internet connection is available
																									if ping -c 1 8.8.8.8 &> /dev/null; then

																										# Notify that syncing server -> local will start
																										echo "Syncing: Downloading from the server..."
																										#notify-send "Syncing" "Downloading from the server..."
																										sleep 10


																										# ============== THE SYNC ==============

																										# Personal (local backup / rClone Bin)
																										rclone sync "${common_flags[@]}" "${sync_flags[@]}" "${dynamic_sync_server_local_flags[@]}" "$Persoanl_local" "$Persoanl_local_backup" | while read line; do
																											# Check for errors
																											if [[ "$line" == *"ERROR"* || "$line" == *"Errors:"* ]]; then
																												# Send a notification
																												notify-send "Syncing Error:" "$line"
																											fi
																											echo "$line" >> "$sync_lock"
																										done

																										# Personal
																										rclone bisync "${common_flags[@]}" "${bisync_flags[@]}" "$Persoanl_local" "$Personal_remote" | while read line; do
																											# Check for errors
																											if [[ "$line" == *".conflict"* || "$line" == *"ERROR"* || "$line" == *"Errors:"* ]]; then
																												# Send a notification
																												notify-send "Syncing Error:" "$line"
																											fi
																											echo "$line" >> "$sync_lock"
																										done

																										# ======================================


																										while true; do
																											# Check if the internet connection is available
																											if ping -c 1 8.8.8.8 &> /dev/null; then

																												# Personal/Public
																												rclone bisync "${common_flags[@]}" "${bisync_flags[@]}" "$PersonalPb_remote" "$PersoanlPb_local" | while read line; do
																													# Check for errors
																													if [[ "$line" == *".conflict"* || "$line" == *"ERROR"* || "$line" == *"Errors:"* ]]; then
																														# Send a notification
																														notify-send "Syncing Error:" "$line"
																													fi
																													echo "$line" >> "$sync_lock"
																												done

																												while true; do
																													# Check if the internet connection is available
																													if ping -c 1 8.8.8.8 &> /dev/null; then

																														# Dev
																														rclone bisync "${common_flags[@]}" "${bisync_flags[@]}" "$Dev_remote" "$Dev_local" | while read line; do
																															# Check for errors
																															if [[ "$line" == *".conflict"* || "$line" == *"ERROR"* || "$line" == *"Errors:"* ]]; then
																																# Send a notification
																																notify-send "Syncing Error:" "$line"
																															fi
																															echo "$line" >> "$sync_lock"
																														done

																														while true; do
																															# Check if the internet connection is available
																															if ping -c 1 8.8.8.8 &> /dev/null; then

																																# WORKSTATION
																																rclone bisync "${common_flags[@]}" "${bisync_flags[@]}" "$WORKSTATION_remote" "$WORKSTATION_local" | while read line; do
																																	# Check for errors
																																	if [[ "$line" == *".conflict"* || "$line" == *"ERROR"* || "$line" == *"Errors:"* ]]; then
																																		# Send a notification
																																		notify-send "Syncing Error:" "$line"
																																	fi
																																	echo "$line" >> "$sync_lock"
																																done

																																# Notify that syncing server -> local was completed
																																echo "Syncing: Server download - done."
																																#notify-send "Syncing" "Server download - done."
																																sleep 10

																																break
																															else
																																# No internet connection
																																echo "No internet. Reloading in 1 minute."
																																notify-send "Syncing" "(Cycle - DOWN WORKSTATION) No internet. Retrying in 1 minute."
																																sleep 60
																															fi
																														done

																														break
																													else
																														# No internet connection
																														echo "No internet. Reloading in 1 minute."
																														notify-send "Syncing" "(Cycle - DOWN Dev) No internet. Retrying in 1 minute."
																														sleep 60
																													fi
																												done

																												break
																											else
																												# No internet connection
																												echo "No internet. Reloading in 1 minute."
																												notify-send "Syncing" "(Cycle - DOWN Personal/Public) No internet. Retrying in 1 minute."
																												sleep 60
																											fi
																										done

																										break
																									else
																										# No internet connection
																										echo "No internet. Reloading in 1 minute."
																										notify-send "Syncing" "(Cycle - DOWN Personal) No internet. Retrying in 1 minute."
																										sleep 60
																									fi
																								done

																								break
																							#else
																							#	# No internet connection
																							#	echo "No internet. Reloading in 1 minute."
																							#	notify-send "Syncing" "(Cycle - UP WORKSTATION) No internet. Retrying in 1 minute."
																							#	sleep 60
																							#fi
																						done

																						break
																					#else
																					#	# No internet connection
																					#	echo "No internet. Reloading in 1 minute."
																					#	notify-send "Syncing" "(Cycle - UP Dev) No internet. Retrying in 1 minute."
																					#	sleep 60
																					#fi
																				done

																				break
																			#else
																			#	# No internet connection
																			#	echo "No internet. Reloading in 1 minute."
																			#	notify-send "Syncing" "(Cycle - UP Personal/Public) No internet. Retrying in 1 minute."
																			#	sleep 60
																			#fi
																		done

																		break
																	else
																		# No internet connection
																		echo "No internet. Reloading in 1 minute."
																		notify-send "Syncing" "(Cycle - UP Personal) No internet. Retrying in 1 minute."
																		sleep 60
																	fi
																done

																# Mark that the syncing cycle was completed
																mv "$sync_lock" "$logs/Sync/Sync_$(get_timestamp).log"
																# Notify that the syncing cycle was completed
																echo "Syncing: Complete."
																#notify-send "Syncing" "Complete."
																# Give a 10 minutes cool-down before the next cycle
																sleep 600

															elif [ -f "$sync_lock" ]; then
																echo "Syncing: Second instance detected, aborting."
																notify-send "Syncing" "Second instance detected, aborting."
																exit 0
															fi
														else
															# No internet connection
															echo "No internet. Reloading in 1 minute."
															notify-send "Syncing" "(Cycle) No internet. Retrying in 1 minute."
															sleep 60
														fi
													done
												fi
											else
												# No internet connection
												echo "No internet. Reloading in 1 minute."
												notify-send "Syncing" "(Boot - Workstation) No internet. Retrying in 1 minute."
												sleep 60
											fi
										done
									else
										# No internet connection
										echo "No internet. Reloading in 1 minute."
										notify-send "Syncing" "(Boot - Dev) No internet. Retrying in 1 minute."
										sleep 60
									fi
								done
							else
								# No internet connection
								echo "No internet. Reloading in 1 minute."
								notify-send "Syncing" "(Boot - Personal/Public) No internet. Retrying in 1 minute."
								sleep 60
							fi
						done
					else
						# No internet connection
						echo "No internet. Reloading in 1 minute."
						notify-send "Syncing" "(Boot - Personal) No internet. Retrying in 1 minute."
						sleep 60
					fi
				done
			fi
		fi
	else
		# No internet connection
		echo "No internet. Reloading in 1 minute."
		notify-send "Syncing" "(Boot) No internet. Retrying in 1 minute."
		sleep 60
	fi
done
