# Samba ([upstream](https://github.com/dperson/samba))

## Hosting a Samba instance

```shell
docker run -it -p 139:139 -p 445:445 -d sgsunder/samba
```

to set local storage:

```shell
docker run -it --name samba -p 139:139 -p 445:445 \
           -v /path/to/directory:/mount \
           -d sgsunder/samba
```

### Configuration via environment variables
(fields in `[]` are optional, `<>` are required)

 * `CHARMAP` - Setup character mapping for file/directory names.
    * Format: `<from:to>`, character mappings separated by `,`
 * `GLOBAL_*` - Provide global option for `smb.conf`.
    * You can specify multiple of these, in the form
    `GLOBAL_1`, `GLOBAL_B`, `GLOBAL_FOO`, etc.
    * Example: `-g "log level = 2"`.
 * `IMPORT` - Import a bind mounted `smbpassword` file or Docker secret.
    * Format: `/path/to/smbpassword/file`.
 * `PERMISSIONS` - If set, set ownership and permissions on the shares.
 * `RECYCLE` - If set, disable recycle bin for shares.
 * `USER_*` - Setup a user.
    * Format: `<username;password>[;ID;group]`, seperated with semicolons.
    * Required: `username` and `password`.
    * Optional: `ID` for user.
    * Optional: `group` for user.
    * Example 1: `example1;badpass`
    * Example 2: `example2;badpass`
 * `SHARE_*` - Configure a share.
    * Format: `<name;/path>[;browse;readonly;guest;users;admins;writelist;comment]`,
    seperated with semicolons.
    * Required: `name` and `path`
    * The rest is optional, leave blank for defaults.
    * `browsable`: default `yes` or `no`.
    * `readonly`: default `yes` or `no`.
    * `guest`: allowed default `yes` or `no`.
    * `users`: allowed default `all` or list of allowed users.
    * `admins`: allowed default `none` or list of admin users.
    * `writelist`: list of users that can write to a read-only share.
    * `comment`: Description of share.
    * Example 1: `public;/share`
    * Example 2: `users;/srv;no;no;no;example1,example2`
    * Example 3: `example1 private;/example1;no;no;no;example1`
    * Example 4: `example2 private;/example2;no;no;no;example2`
 * `WIDELINKS` - If set, allow access wide symbolic links
 * `WORKGROUP` - Configure the workgroup (domain) samba should use.
 * `NMBD` - If set, start the 'nmbd' daemon to advertise the shares.
 * `SMB` - If set, disable SMB2 minimum version.
 * `TZ` - Set a timezone, IE `EST5EDT`
 * `PUID` - Set the UID for the samba server
 * `PGID` - Set the GID for the samba server

**NOTE**: if you enable nmbd (via `-n` or the `NMBD` environment variable), you
will also want to expose port 137 and 138 with `-p 137:137/udp -p 138:138/udp`.
