#!/bin/bash

# Arch Maintenance Script
# Inspired by: https://fernandocejas.com/blog/engineering/2022-03-30-arch-linux-system-maintance/

# Function to run a command safely
run_safe() {
  echo -e "\n🛠️ Running: $*\n"
  "$@" || echo "⚠️ Command failed: $*"
}

echo -e "\n🌐 Updating System Packages..."
run_safe paru -Syu --noconfirm
run_safe flatpak update -y
run_safe rustup update

echo -e "\n🧹 Cleaning Package Caches..."
run_safe paru -Scc --noconfirm
run_safe cargo cache -a
run_safe flatpak uninstall --unused -y

echo -e "\n🗑️ Removing Orphan Packages..."
orphans=$(paru -Qtdq)
if [[ -n "$orphans" ]]; then
  run_safe paru -Rns $orphans
else
  echo "No orphans found."
fi

echo -e "\n📦 Generating Package Lists..."
mkdir -p ~/system-reports
run_safe bash -c 'paru -Qei | awk "/^Name/{name=\$3} /^Installed Size/{print \$4\$5, name}" | sort -h > ~/system-reports/all-packages.txt'
run_safe bash -c 'paru -Qim | awk "/^Name/{name=\$3} /^Installed Size/{print \$4\$5, name}" | sort -h > ~/system-reports/aur-packages.txt'

echo -e "\n📂 Cleaning User Cache (aggressively)..."
run_safe rm -rf ~/.cache/*

echo -e "\n🗃️ Vacuuming Journal Logs..."
run_safe sudo journalctl --vacuum-time=7d --vacuum-size=500M

echo -e "\n✅ Maintenance Complete!"

