### Workspace changer background color
By default XFCE4 workspace changer background and foreground is identical, making it impossible to tell with workspace is active. 

As a workaround, create file at ~/.config/gtk-3.0/gtk.css with contents:

```
wnck-pager:selected {
    background-color: DodgerBlue; }
wnck-pager:hover {
    background-color: gray; }
```

to have a gray colored background for the active workspace.

### Making XFCE4 default user interface
to replace gnome with xfce4, edit **/etc/vnc/xstartup** and:

replace line
`dbus-launch --exit-with-session gnome-session --session=ubuntu`

with 
`dbus-launch --exit-with-session startxfce4 --session=ubuntu`

and reboot the system. 
