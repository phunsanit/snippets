#https://help.ubuntu.com/community/ManticUpgrades

sudo apt-get install ubuntu-release-upgrader-core

#

sudo do-release-upgrade -d


. Access the file with administrative privileges:

Open a terminal window (Ctrl+Alt+T).
Use the following command to edit the file with nano:
Bash
sudo nano /etc/update-manager/release-upgrades
ใช้โค้ดอย่างระมัดระวัง
Enter your password when prompted.
2. Modify the Prompt value:

Within the file, locate the line that says Prompt=.
If it's set to lts or never, change it to normal.
If the line is not present, add it manually:
Prompt=normal
3. Save the changes:

In nano, press Ctrl+O to save the file.
Press Enter to confirm the filename.
Press Ctrl+X to exit nano.
4. Verify the change:

Use this command to view the updated content:
Bash
cat /etc/update-manager/release-upgrades
ใช้โค้ดอย่างระมัดระวัง
You should see Prompt=normal in the output.
5. Check for updates:

Run the Software Updater application or use the command:
Bash
sudo apt update && sudo apt upgrade
ใช้โค้ดอย่างระมัดระวัง
If a new release is available, you'll be prompted to upgrade.
Additional notes:

Alternative text editors: You can use other text editors like vim or gedit if you prefer.
Graphical method: On Ubuntu Desktop, you can also change the Prompt value using the Software & Updates application (under "Updates").
LTS upgrades: If you want to upgrade only to LTS (Long Term Support) releases, set Prompt=lts instead.
Careful review: Always back up important data before initiating major system upgrades.