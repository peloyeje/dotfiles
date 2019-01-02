## macOS

Tested on High Sierra (10.13) and Mojave (10.14)

#### How to use

1. Reboot in Recovery mode
2. Disable [SIP](https://en.wikipedia.org/wiki/System_Integrity_Protection) : `csrutil disable; reboot`
3. Customize variables in `vars.sh`
4. Run the `install.sh` script
5. Reboot in Recovery mode and `csrutil enable; reboot`
6. Enjoy !
