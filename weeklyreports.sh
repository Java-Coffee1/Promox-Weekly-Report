#!/bin/bash

# Create the report file
report_file="/tmp/proxmox_weekly_report.txt"
echo "Proxmox Weekly Report - $(date)" > $report_file
echo "===============================" >> $report_file
echo "" >> $report_file

# Section: Critical Warnings (Failed tasks, full drives, etc.)
echo "### Critical Warnings ###" >> $report_file
echo "------------------------" >> $report_file

# Check for failed tasks (last 7 days)
echo "Checking for failed tasks..." >> $report_file
failed_tasks=$(journalctl -u pveproxy --since "7 days ago" | grep -i -E "fail|error|critical|warning")
if [ -n "$failed_tasks" ]; then
    echo "⚠️  Failed Tasks in the Last 7 Days:" >> $report_file
    echo "$failed_tasks" >> $report_file
else
    echo "No failed tasks detected." >> $report_file
fi
echo "" >> $report_file

# Drives close to full (threshold at 90%)
echo "Checking for drives close to full (>90% used)..." >> $report_file
close_to_full=$(df -h | awk '$5+0 >= 90 {print $0}')
if [ -n "$close_to_full" ]; then
    echo "⚠️  Drives Over 90% Full:" >> $report_file
    echo "$close_to_full" >> $report_file
else
    echo "No drives are close to full." >> $report_file
fi
echo "" >> $report_file

echo "------------------------" >> $report_file
echo "" >> $report_file

# Section: System Overview (General Information)
echo "### System Overview ###" >> $report_file
echo "----------------------" >> $report_file

# Add system status
echo "System Status:" >> $report_file
echo "--------------" >> $report_file
uptime >> $report_file
echo "" >> $report_file

# Disk usage
echo "Disk Usage:" >> $report_file
echo "-----------" >> $report_file
df -h >> $report_file
echo "" >> $report_file

# Memory usage
echo "Memory Usage:" >> $report_file
echo "-------------" >> $report_file
free -m >> $report_file
echo "" >> $report_file

# CPU usage
echo "CPU Usage:" >> $report_file
echo "----------" >> $report_file
top -bn1 | head -10 >> $report_file
echo "" >> $report_file

# Section: Logs (Optional, for detailed task logs)
# Uncomment if you'd like more details on the tasks
# echo "Proxmox Tasks Log (last 7 days):" >> $report_file
# journalctl -u pveproxy --since "7 days ago" >> $report_file
# echo "" >> $report_file

# Send email with the report
mail -s "⚠️ Proxmox Weekly Report: Important Alerts Inside" youremail@example.com < $report_file
