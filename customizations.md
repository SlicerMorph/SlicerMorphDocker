### Workspace changer background color
By default XFCE4 workspace changer background and foreground is identical, making it impossible to tell which workspace is active. 

As a workaround, append/create file at `~/.config/gtk-3.0/gtk.css` with contents:

```
wnck-pager:selected {
    background-color: DodgerBlue; }
wnck-pager:hover {
    background-color: gray; }
```
to have a gray colored background for the active workspace.

### disable screen saver 
xfce4 screensaver is enabled by default with 5 minutes of inteactivity. To disable create `~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-screensaver.xml` with contents:
```
<?xml version="1.0" encoding="UTF-8"?>

<channel name="xfce4-screensaver" version="1.0">
  <property name="saver" type="empty">
    <property name="mode" type="int" value="0"/>
    <property name="enabled" type="bool" value="false"/>
    <property name="idle-activation" type="empty">
      <property name="delay" type="int" value="60"/>
    </property>
  </property>
  <property name="lock" type="empty">
    <property name="enabled" type="bool" value="false"/>
    <property name="saver-activation" type="empty">
      <property name="delay" type="int" value="60"/>
    </property>
  </property>
</channel>
```
### create Slicer launcher
path to 3D icon within Slicer tree is `./lib/Slicer-5.6/qt-scripted-modules/Resources/SlicerWatermark.png`
1. create this folder `~/.config/xfce4/panel/launcher-21/Slicer.desktop` with contents
```
[Desktop Entry]
Version=1.0
Type=Application
Name=3D Slicer
Comment=
Exec=bash -ic '/home/exouser/Slicer/Slicer'
Icon=/home/exouser/Slicer/lib/Slicer-5.6/qt-scripted-modules/Resources/SlicerWatermark.png
Path=
Terminal=false
StartupNotify=false
```
2. change permission 775
3. This assumes Slicer is installed under `/home/exouser/Slicer`. if not modify paths accordingly. 


### Making XFCE4 default user interface
to replace gnome with xfce4, edit **/etc/vnc/xstartup** and:

replace line
`dbus-launch --exit-with-session gnome-session --session=ubuntu`

with 
`dbus-launch --exit-with-session startxfce4 --session=ubuntu`

and reboot the system. 


unfortunately this change does not preserved, even if we image a working system. [Suggested way](https://gitlab.com/exosphere/exosphere/-/issues/955) is to make the permanent changes to the exosphere in a fork, and point that to the ansible. Modified code that seems to work is below. This needs to be pasted to Boot Script tab of the Advanced Options in the the instance launch interface. 

```
#cloud-config
users:
  - default
  - name: exouser
    shell: /bin/bash
    groups: sudo, admin
    sudo: ['ALL=(ALL) NOPASSWD:ALL']{ssh-authorized-keys}
ssh_pwauth: true
package_update: true
package_upgrade: {install-os-updates}
packages:
  - git{write-files}
runcmd:
  - echo on > /proc/sys/kernel/printk_devkmsg || true  # Disable console rate limiting for distros that use kmsg
  - sleep 1  # Ensures that console log output from any previous command completes before the following command begins
  - >-
    echo '{"status":"running", "epoch": '$(date '+%s')'000}' | tee --append /dev/console > /dev/kmsg || true
  - chmod 640 /var/log/cloud-init-output.log
  - {create-cluster-command}
  - (which apt-get && apt-get install -y python3-venv) # Install python3-venv on Debian-based platforms
  - (which yum     && yum     install -y python3)      # Install python3 on RHEL-based platforms
  - |-
    python3 -m venv /opt/ansible-venv
    . /opt/ansible-venv/bin/activate
    pip install --upgrade pip
    pip install ansible-core
    ansible-pull \
      --url "https://github.com/muratmaga/exosphere.git" \
      --checkout "master" \
      --directory /opt/instance-config-mgt \
      -i /opt/instance-config-mgt/ansible/hosts \
      -e "{ansible-extra-vars}" \
      /opt/instance-config-mgt/ansible/playbook.yml
  - ANSIBLE_RETURN_CODE=$?
  - if [ $ANSIBLE_RETURN_CODE -eq 0 ]; then STATUS="complete"; else STATUS="error"; fi
  - sleep 1  # Ensures that console log output from any previous commands complete before the following command begins
  - >-
    echo '{"status":"'$STATUS'", "epoch": '$(date '+%s')'000}' | tee --append /dev/console > /dev/kmsg || true
```
